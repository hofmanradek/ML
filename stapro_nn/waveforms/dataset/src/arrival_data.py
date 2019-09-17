import numpy as np
import cx_Oracle
from dbtools import exec_query, get_connection


REG_P = ('Pn', 'Pg')
REG_S = ('Sn', 'Lg', 'Rg')
TEL_P = ('P', 'PKP', 'PKPbc', 'PcP', 'PKPab', 'pP', 'PP', 'PKKPbc', 'ScP', 'SKPbc',
         'PKhKP', 'PKiKP', 'PKP2', 'Pdiff', 'SKP', 'pPKP', 'PKKPab', 'pPKPbc', 'PKKP',
         'SKKPbc', 'PKP2bc', 'P3KPbc', 'sP', 'SKPab', 'P4KPbc', 'PKP2ab', 'pPKPab', 'P3KP',
         'SKKP', 'SKiKP', 'SKKPab', 'SKKS', 'P4KP', 'SP')
NOISE = ()

LEB_PHASES = (REG_P, REG_S, TEL_P, NOISE)
LEB_PHASE_LABELS = ('P', 'S', 'T', 'N')




def get_arids_Query(sta, wave_types, conn, days_back, retime_thr=2.):
    """
    REG_P
    return all arrival ids to be processed
    :return:
    """
    query = """select a.arid, a.sta, la.time, a.iphase, l.phase 
               from leb.assoc l, leb.arrival la, idcx.arrival a 
               where a.arid=l.arid 
                 and l.arid=la.arid 
                 and abs(a.time - la.time) <= %3.2f 
                 and l.phase in %s 
                 and l.sta='%s' 
                 and l.lddate > sysdate - %d   
    """ % (retime_thr, str(wave_types), sta, days_back)
    c = exec_query(query, conn.cursor())
    arids = c.fetchall()
    return arids


def get_non_noise(sta, days_back, conn):
    """
    gets arids for queries 1 - 3
    :return:
    """
    ret = []

    for i, type_family in enumerate(LEB_PHASES[:-1]):
        print("getting arids for %s" % (LEB_PHASE_LABELS[i]) )
        ret += list(get_arids_Query(sta, type_family, conn, days_back, retime_thr=2.))

    return ret


def get_noise(sta, days_back, conn):
    """
    get arids for query 4
    :return:
    """
    print("getting arids for %s" % (LEB_PHASE_LABELS[-1]))
    query = """select a.arid, a.sta, a.time, a.iphase, a.iphase 
               from idcx.arrival a 
               where a.iphase='N' 
                 and a.sta='%s' 
                 and a.lddate > sysdate - %d 
                 and a.arid not in (select distinct arid from leb.assoc)
    """ % (sta, days_back)
    c = exec_query(query, conn.cursor())
    arids = c.fetchall()
    return arids


def get_arrival_data(sta, conn, days_back=730):
    """
    :param sta:
    :param days_back:
    :return:
    """
    ret = []
    ret += get_non_noise(sta, days_back, conn)
    ret += get_noise(sta, days_back, conn)
    return ret





def populate_data(arids, conn, clear=True):
    """

    :param arids:
    :param cursor:
    :param clear: purge all old data?
    :return:
    """

    for arid in arids:
        get_waveform_for_arid(arid, conn, tbefore=0.5, tafter=4.5)






def get_waveform_for_arid(arid, conn, tbefore=0.5, tafter=4.5):
    """
    extract waveform data of given lenght before and after an arrival
    :param tbefore: time before arrival in sec
    :param tafter: time after arrival in sec
    :param arid:
    :return:
    """




    ret = np.array()
    query = """
    select 
    
    """

    return ret


def main(conn, conn_udb):
    """

    :return:
    """
    sta = 'LPAZ'
    adata = get_arrival_data(sta, conn, days_back=730)
    populate_data(adata, conn, clear=True)


if __name__ == '__main__':
    conn = get_connection(dbname='extadb')
    conn_udb = get_connection(dbname='udb')

    main(conn, conn_udb)


    #arids = get_arids_Query('LPAZ', REG_S, days_back=730)

    #print(len(arids))
    #arids = get_non_noise('LPAZ', days_back=730)
    #arids = get_noise('LPAZ', days_back=730)
    #print(arids)
    #print(len(arids))
    #print(arids)
    #get_waveform_for_arid(arid, cursor, tbefore=0.5, tafter=4.5)

    #cur.executemany("insert into cx_pets (id, name, owner, type) values (:1, :2, :3, :4)", rows)
    #con.commit()