from mpi4py import MPI
import numpy as np
from math import sin, pi


comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()
N = 1024
epsilon = 0.00001
tau = 0.1/N
if rank == 0:
    A = np.empty(shape=(N, N), dtype='d')
    u = np.empty(shape=(N, 1), dtype='d')
    x = np.zeros(shape=(N, 1), dtype='d')
    b = np.empty(shape=(N, 1), dtype='d')
    for i in range(N):
        for j in range(N):
            if i == j:
                A[i][j] = 2.0
            else:
                A[i][j] = 1.0
    for i in range(N):
        u[i] = sin((2 * pi * i) / N)
    b = A @ u
else:
    b = None
    x = None
    A = None
    u = None
b = comm.bcast(b, root=0)

x = comm.bcast(x, root=0)


part = np.empty(shape=(N//size, N), dtype='d')
comm.Scatter(A, part, root=0)

"""
part_y = part @ x
y = None
if rank == 0:
    y = np.empty(shape=(N, 1), dtype='d')
comm.Gather(part_y, y, root=0)
comm.Barrier()
y = comm.bcast(y, root=0)
comm.Barrier()
y = y - b
y = tau * y
x = x - y
print(rank, len(y), x)
"""
start = MPI.Wtime()
while True:
    part_y = part @ x
    y = None
    if rank == 0:
        y = np.empty(shape=(N, 1), dtype='d')
    comm.Gather(part_y, y, root=0)
    y = comm.bcast(y, root=0)
    y = y - b
    if (np.linalg.norm(y) / np.linalg.norm(b)) < epsilon:
        break
    if rank == 0:
        x = x - tau * y
    x = comm.bcast(x, root=0)
finish = MPI.Wtime()
print(finish - start)

