import threading
from time import sleep

n = 10
s = []
r = []
lock = threading.Lock()

class MyThread(threading.Thread):
    def __init__(self, name):
        super().__init__(name=name)

    def run(self):
        if self.name == 'A':
            print('A start')
            for i in range(n):
                s.append(i)
                sleep(1)
            print('A finish')
        if self.name == 'B':
            print('B start')
            for i in range(n):
                if len(s) == 0:
                    sleep(1)
                else:
                    t = s.pop()
                    r.append(t * t)
            print('B finish')
        if self.name == 'C':
            print('C start')
            for i in range(n):
                if len(s) == 0:
                    sleep(1)
                else:
                    t = s.pop()
                    r.append(t / 3)
            print('C finish')
        if self.name == 'D':
            print('D start')
            for i in range(n):
                if len(r) == 0:
                    print('In R there are not elements')
                    sleep(1)
                else:
                    print(r.pop())
            print('D finish')


A = MyThread('A')
B = MyThread('B')
C = MyThread('C')
D = MyThread('D')

threads = [A, B, C, D]
for thread in threads:
    thread.start()
for thread in threads:
    thread.join()