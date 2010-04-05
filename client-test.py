import eventlet
import sys


def request(f, cmd):
    f.write(cmd+"\n")
    f.flush()
    return f.readline()

def test_1():
    conn = eventlet.connect( ('127.0.0.1', 19292) )
    f = conn.makefile()

    print request(f, "GET foo")

def test_2(n=100*1000):
    conn = eventlet.connect( ('127.0.0.1', 19292) )
    f = conn.makefile()

    for _ in xrange(n):
        request(f, "GET foo")

def test_3():
    pool = eventlet.GreenPool()
    for _ in xrange(10):
        pool.spawn(test_2, 10*1000)
    pool.waitall()

def test_4():
    pool = eventlet.GreenPool()
    for _ in xrange(200):
        pool.spawn(test_2, 500)
    pool.waitall()

def test_set_nil_1():
    conn = eventlet.connect( ('127.0.0.1', 19292) )
    f = conn.makefile()

    print request(f, "SET foo n:")

def test_set_nil_2(n=100*1000):
    conn = eventlet.connect( ('127.0.0.1', 19292) )
    f = conn.makefile()

    for _ in xrange(n):
        request(f, "SET foo n:")

def test_set_bytes_1():
    conn = eventlet.connect( ('127.0.0.1', 19292) )
    f = conn.makefile()

    print request(f, "SET foo b:3bar")

def test_set_bytes_2(n=100*1000):
    conn = eventlet.connect( ('127.0.0.1', 19292) )
    f = conn.makefile()

    for _ in xrange(n):
        request(f, "SET foo b:3bar")


def main():
    fun = globals()[sys.argv[1]]
    fun()

if __name__ == '__main__':
    main()
