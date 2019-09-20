import cx_Oracle as db
import sys

def get_connection(dbname='extadb'):
    """
    :return: database connection cursor
    """
    with open('/home/hofman/.dbp.txt', 'r') as f:
        dbpwd = f.read().strip()
        conn = db.connect('hofman/%s@%s' % (dbpwd, dbname))
        return conn
    return None


def exec_query(query, cursor):
    try:
        c = cursor.execute(query)
        return c
    except Exception as e:
        print("Query \n%s\n failed!" % query)
        print(e)
        sys.exit(1)


def get_all_sta_chan(aff_net, cursor):
    """
    returns all sta_chan pairs for a given aff_net
    :return:
    """
    query = """SELECT DISTINCT s.sta, i.chan 
               FROM static.stanet s 
               JOIN static.sitechan i 
               ON s.sta=i.sta 
               WHERE i.chan IN ('BDF','BH1','BH2','BHE','BHN','BHZ','EDH','EDE','EHN',
                                'EHZ','HHE','HHN','HHZ','MH1','MH2','MHE','MHN','MHZ',
                                'SH1','SH2','SHE','SHN','SHZ') AND 
                  s.net='%s' 
               ORDER BY s.sta, i.chan
    """ % aff_net
    c = exec_query(query, cursor)
    return c.fetchall()