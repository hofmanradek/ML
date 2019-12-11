"""
Tool for reading data from wfdisc files
Author: Radek Hofman, Jan 2018
conversion from s3 to f4 by Dima Bobrov
"""

import numpy as np
from pprint import pprint
import sys
import math
import os
from datetime import datetime as dt
import matplotlib.pyplot as plt
from dbtools import get_connection, exec_query
import asyncio


BYTES_PER_SAMPLE = {'t4': 4, 's3': 3, 's4': 4}


def wfdisc_rows_to_dicts(rows):
    """
    transfors row tuples returned from wfdisc table into a list of dicts
    :param rows: raw rows as retunrd from db
    :return: list of dicts representing rows so we can get column values by name, not index
    """
    ret = []
    keys = ('sta', 'chan', 'time', 'wfid', 'chanid', 'jdate', 'endtime', 'nsamp', 'samprate',\
            'calib', 'calper', 'instype', 'segtype', 'datatype', 'clip', 'dir', 'dfile', 'foff',\
            'commid', 'lddate')
    for row in rows:
        d = {keys[i]: row[i] for i in range(len(keys))}
        d['_duration'] = d['endtime']-d['time']  # out own field - with _
        ret.append(d)

    return ret


def convert_raw_data(raw_data, datatype, mult=1.):
    """
    converst raw data read from a wfdisc file to numpy floats
    :param raw_data:
    :param datatype:
    :return:
    """
    bytes_per_sample = BYTES_PER_SAMPLE.get(datatype, None)
    n = round(raw_data.size / float(bytes_per_sample))

    if datatype == 't4':
        ret = np.ndarray(shape=(n,), dtype='>f4', buffer=raw_data)
    elif datatype == 's3':  # this crazy operation is from Dima Bobrov
        buf = np.hstack((np.zeros((n, 1), dtype='uint8'), raw_data.reshape(n, -1))).ravel()
        ret = np.ndarray(shape=(n,), dtype='>i4', buffer=buf)
        ret[np.where(ret >= 0x800000)] -= 0x1000000
    elif datatype == 's4':
        ret = np.ndarray(shape=(n,), dtype='>i4', buffer=raw_data)
    else:
        print('Unknown datatype, exiting...')
        sys.exit(1)

    return ret*mult


def get_wfdisc_entry_query(sta, chan, t1, t2):
    """
    compiles a query for getting a wfdisc entry
    :param sta: station
    :param chan: channel
    :param t1: start of desired interval
    :param t2: end of desired interval
    :return: query for select of all relevant wfdisc files

    Name     Null?    Type
    -------- -------- ------------
    STA      NOT NULL VARCHAR2(6)
    CHAN     NOT NULL VARCHAR2(8)
    TIME     NOT NULL FLOAT(53)
    WFID     NOT NULL NUMBER(10)
    CHANID            NUMBER(8)
    JDATE             NUMBER(8)
    ENDTIME           FLOAT(53)
    NSAMP             NUMBER(8)
    SAMPRATE          FLOAT(24)
    CALIB             FLOAT(24)
    CALPER            FLOAT(24)
    INSTYPE           VARCHAR2(6)
    SEGTYPE           VARCHAR2(1)
    DATATYPE          VARCHAR2(2)
    CLIP              VARCHAR2(1)
    DIR               VARCHAR2(64)
    DFILE             VARCHAR2(32)
    FOFF              NUMBER(10)
    COMMID            NUMBER(10)
    LDDATE            DATE
    """
    query = """
SELECT * 
FROM idcx.wfdisc  
    """
    query += """WHERE              
 sta='%s' AND
 chan='%s' AND
 (
""" % (sta, chan)
    # CASE1 the interval starts in a wfdisc file and ends in another - start part, possible middle part adn end part
    query += """  ((time<=%f AND %f<endtime AND %f>endtime) OR
   (time>%f AND %f>=endtime) OR
   (time<%f AND %f<=endtime AND time>%f))
  """ % (t1, t1, t2, t1, t2, t2, t2, t1)
    query += """OR
"""
    # CASE2 the whole interval is in a single wfdisc file
    query += """  ((time<=%f AND %f<=endtime) AND (time<=%f AND %f<=endtime)) 
""" % (t1, t1, t2, t2)

    query += """ )
ORDER BY sta, chan, time, foff 
"""
    return query


async def fetch_wfdisc_entries(sta, chan, t1, t2, cursor):
    """
    gets a wfdist entry(entrie) for given time, endtime
    :return: a list of wfdisc dictionaries - wfdicts
    """
    query = get_wfdisc_entry_query(sta, chan, t1, t2)
    c = exec_query(query, cursor)
    wfdicts = wfdisc_rows_to_dicts(c.fetchall())
    return wfdicts


def get_samperates(wfdicts):
    """
    from all entries in wfdict extracts samprates
    :param wfdicts:
    :return:
    """
    return [wfd['samprate'] for wfd in wfdicts]


async def read_waveforms_from_files(t1, t2, wfdict, calib):
    """
    reads waveform data from wfdisc files
    :return index: position of the first data item relative to t1
    :return nsamp: number of returned samples
    :return subdata: vector of data starting at index
    """
    path = os.path.join(wfdict['dir'], wfdict['dfile'])
    offset = wfdict['foff']
    samprate = wfdict['samprate']
    time = wfdict['time']
    endtime = wfdict['endtime']
    datatype = wfdict['datatype']
    calib_fact = wfdict['calib'] if calib else 1.   # calibrate if NOT raw
    bytes_per_sample = BYTES_PER_SAMPLE.get(datatype, None)

    # we set start and end time in this particular wfdisc file w.r.t t1 and t2
    tstart = time if t1 <= time else t1
    tend = endtime if t2 >= endtime else t2 - 1/samprate  # the last sample is the real end...

    print(offset, wfdict['datatype'], path)

    real_offset = round(offset+(tstart-time)*samprate*bytes_per_sample)

    with open(path, 'rb') as f:
        # we calculate sample start and sample end for this particular wfdisc file
        startsample = (tstart - time) * samprate
        endsample = (tend - time) * samprate
        nsamp = endsample - startsample + 1   # this must be calculated, sometimes we read not of all samples
        # we seek to the beginning of current station/channel
        f.seek(real_offset)
        # read raw data into numpy uint8 ndarray
        raw_data = np.fromfile(f, dtype='uint8', count=round(nsamp*bytes_per_sample))

    # convert to floats given its particular type
    subdata = convert_raw_data(raw_data, datatype, mult=calib_fact)
    index = (tstart - t1) * samprate
    return round(index), round(nsamp), subdata, calib_fact


async def get_waveform_data(sta, chan, t1, t2, cursor, calib=True):
    """
    crates a numpy array with samples
    :param sta: station
    :param chan: channel
    :param t1: start of desired interval
    :param t2: end of desired interval
    :param cursor: (oracle) db cursor
    :return: numpy array with samples
    """
    wfdicts = await fetch_wfdisc_entries(sta, chan, t1, t2, cursor)
    samprates = get_samperates(wfdicts)

    if not samprates:
        return np.array(()), 0, 0

    if max(samprates) == min(samprates):  # all wfdisc have the same samprate
        sr = samprates[0]
        data = np.zeros(math.ceil((t2-t1)*sr))
        for wfdict in wfdicts:
            # now we must calculate which samples will be occupied by the retrieved data from each wfdisc file
            index, nsamp, subdata, calib_fact = await read_waveforms_from_files(t1, t2, wfdict, calib)
            # put data chunk in place
            data[index:index+nsamp] = subdata
    else:
        print('Samprates differ, exiting...')
        print(samprates)
        sys.exit(1)
    return data, sr, calib_fact


def ts(*date):
    """
    wotks in py3
    :param datetime:
    :return: timestamp from datetime
    """
    #print(dt(*date), dt(*date).timestamp())
    return dt(*date).timestamp()


def vizualize(data, show=True, save=False, filename=None, xlabel=None, ylabel=None, title=None):
    """
    makes a simple plot of data
    :param data: data to plot
    :return: None
    """
    fig = plt.figure(figsize=(16,3))
    ax = fig.add_subplot(111)
    ax.plot(data, lw=1)
    ax.set_xlim(0, len(data))
    plt.grid()
    if xlabel: ax.set_xlabel(xlabel)
    if ylabel: ax.set_ylabel(ylabel)
    if title: ax.set_title(title)
    plt.tight_layout()
    if save: plt.savefig(filename if filename else 'plt.pdf')
    if show: plt.show()


if __name__ == "__main__":
    cursor = get_connection(dbname='repodb').cursor()
    sta = 'AK01'
    chan = 'BHZ'
    data, sr, calib_fact = get_waveform_data(sta, chan, ts(2018,1,1,23,59,50), ts(2018,1,3,0,0,10), cursor, calib=True)
    vizualize(data, show=True, xlabel='samples', ylabel=sta+' '+chan, title='Calibrated')

    #data = get_waveform_data(sta, chan, ts(2018,1,1,23,59,50), ts(2018,1,2,0,0,10), cursor, calib=False)
    #vizualize(data, xlabel='samples', ylabel=sta + ' ' + chan, title='Not Calibrated')



