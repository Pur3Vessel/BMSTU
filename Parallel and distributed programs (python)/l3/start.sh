#!/bin/bash
export OMP_NUM_THREADS=1
TIMEFORMAT="время выполнения %lR"
time {
    ./l3
}

export OMP_NUM_THREADS=2
TIMEFORMAT="время выполнения %lR"
time {
    ./l3
}

export OMP_NUM_THREADS=4
TIMEFORMAT="время выполнения %lR"
time {
    ./l3
}

export OMP_NUM_THREADS=8
TIMEFORMAT="время выполнения %lR"
time {
    ./l3
}

export OMP_NUM_THREADS=16
TIMEFORMAT="время выполнения %lR"
time {
    ./l3
}