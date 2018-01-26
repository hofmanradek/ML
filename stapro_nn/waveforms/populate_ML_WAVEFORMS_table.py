import cx_Oracle
import numpy as np
import read_wfdisc
import dbtools
import pickle
import struct
import codecs
import struct
import matplotlib.pyplot as plt
import sys


def get_arrival_waveforms(connection, arid, chan=None):
    #returns waveforms for all three channels for a given arrival
    query = "select * from ml_waveforms where arid=%d" % arid
    if chan:
        query += "and chan='%s'" % chan
    cursor = connection.cursor()
    ret = cursor.execute(query)
    data = ret.fetchall()


    print('Fetched %d waveforms' % len(data))


    ret = []

    for dat in data:
        dat = list(dat)
        nsamp = dat[7]
        waveform = np.array(struct.unpack('%sf' % nsamp, codecs.decode(dat[9], 'hex_codec')))
        dat[9] = waveform
        print(dat)
        ret.append(dat)

    return ret


def get_all_arrivals(sta, cursor, query_app=""):
    #gets all arids available in ML_WAVEFORMS table
    query = "select f.arid, f.time from ML_FEATURES f join ML_WAVEFORMS w on f.arid=w.arid where f.sta='%s'" % sta
    query += " "+query_app
    print(query)
    ret = dbtools.exec_query(query, cursor)
    #arrivals = ret.fetchall()
    #return arrivals[:]
    return cursor


def get_all_arrivals1(sta, cursor, query_app=""):
    #gets all arids available in ML_WAVEFORMS table
    query = "select arid, time from ML_FEATURES where sta='%s'" % sta
    query += " "+query_app
    print(query)
    ret = cursor.execute(query)
    #arrivals = ret.fetchall()
    #return arrivals[:]
    return cursor


def get_channels(arid, cursor):
    #gets channels for given arid
    query = "select chan from ML_WAVEFORMS where arid=%d" % arid
    ret = cursor.execute(query)
    chans = ret.fetchall()
    return chans


def populate_ML_WAVEFORMS(connection_udb, connection_extadb, sta, query_app=""):
    """
    populates ML_WAVEFORMS table containing waveforms for respective arrivals

    CREATE TABLE ML_WAVEFORMS
    (
      WAVEFORMID        NUMBER(10,0) NOT NULL,
      ARID              NUMBER(10,0) NOT NULL,
      STA               VARCHAR2(8) NOT NULL,
      CHAN              VARCHAR2(8) NOT NULL,
      SAMPRATE          FLOAT(24)   NOT NULL,
      STARTTIME         FLOAT(53)  NOT NULL,
      ENDTIME           FLOAT(53)  NOT NULL,
      NSAMP             NUMBER(8),
      SAMPLES           floatArray, --calibrated
      FILTSAMPLES       floatArray, --calibrated and filtered by passband filter between FILTLO, FILTHI
      FILTLO            FLOAT(24),
      FILTHI            FLOAT(24),
      CONSTRAINT ML_WAVEFORM_PK PRIMARY KEY (WAVEFORMID),
      CONSTRAINT FK_ML_FEATURE FOREIGN KEY (ARID) REFERENCES ML_FEATURES (ARID)
    ) ENABLE PRIMARY KEY USING INDEX;

    """
    #get all arrivals from ML_FEATURES table
    cursor_udb = connection_udb.cursor()
    cursor_extadb = connection_extadb.cursor()


    print(cursor_udb.arraysize)

    arrivals_curr = get_all_arrivals(sta, cursor_udb, query_app=query_app)

    #while True:

    arrivals = arrivals_curr.fetchall()

    print("Fetched %d arrivals" % len(arrivals))

    samples_before = 80  # 2s before
    samples_after  = 320  # 8s after

    time_before = 2.
    time_after = 8.

    for arid, time in arrivals:
        #get channels for given arid
        chans = get_channels(arid, cursor_udb)
        print('Channels:', chans)
        #get waveform for each channel
        for chan in chans:

            chan = chan[0]
            print('Processing chan %s for arid=%d' % (chan, arid))
            #starttime = time - samples_before/samprate
            #endtime = time + samples_after/samprate
            starttime = time - time_before
            endtime = time + time_after

            data, samprate, calib_fact = read_wfdisc.get_waveform_data(sta,
                                                     chan,
                                                     starttime,
                                                     endtime,
                                                     cursor_extadb,
                                                     calib=True)

            data = list(data)
            nsamp = len(data)
            samples =  struct.pack('%sf' % nsamp, *data)
            samples_hex = samples.hex()
            query = """UPDATE ml_waveforms 
                       SET samprate=:samprate,
                           starttime=:starttime,
                           endtime=:endtime,
                           nsamp=:nsamp,
                           samples=:samples,
                           calib=:calib 
                       WHERE arid=:arid
                         AND chan=:chan
            """
            cursor_udb.execute(query, {'arid': arid,
                                   'chan': chan,
                                   'samprate': samprate,
                                   'starttime': starttime,
                                   'endtime': endtime,
                                   'nsamp': nsamp,
                                   'samples': samples_hex,
                                   'calib': calib_fact})

        connection_udb.commit()  # we commit after all channels for one arrival


    cursor_udb.close()
    cursor_extadb.close()


def test_extraction():
    """just a test..."""
    arid = 125801379
    data = get_arrival_waveforms(connection_udb, arid, chan=None)

    nchan = len(data)
    fig = plt.figure()
    for fi, dat in enumerate(data):
        ax = fig.add_subplot(nchan, 1, fi + 1)
        ax.plot(dat[9])
        ax.set_ylabel('%s %s' % (dat[2], dat[3]))
        if fi==0: ax.set_title('Arrival %d (time %3.3f-%3.3f)' % (dat[1],dat[5],dat[6]))
    plt.show()


if __name__ == '__main__':
    import os
    #os.environ["NLS_LANG"] = ".AL32UTF8"
    import cx_Oracle as db
    with open('/home/hofman/.dbp.txt', 'r') as f:
        dbpwd = f.read().strip()
        connection_udb = db.connect('hofman/%s@%s' % (dbpwd, 'udb')) #, encoding = "UTF-8", nencoding = "UTF-8")
        connection_extadb = db.connect('hofman/%s@%s' % (dbpwd, 'extadb'))


    #populate_ML_WAVEFORMS(connection_udb, connection_extadb, 'LPAZ', query_app="and cphase='S'")
    #populate_ML_WAVEFORMS(connection_udb, connection_extadb, 'LPAZ', query_app="and cphase='P'")
    #populate_ML_WAVEFORMS(connection_udb, connection_extadb, 'LPAZ', query_app="and f.cphase='T' and w.samples is null and w.calib is null and f.source not in ('H')")
    #populate_ML_WAVEFORMS(connection_udb, connection_extadb, 'LPAZ', query_app="and f.cphase='N'")
    test_extraction()

