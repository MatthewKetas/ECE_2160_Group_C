#!/bin/sh
# Run on the Pi. Build only; never run experiments or change device settings.
set -eu
cd "$(dirname "$0")/.."

gcc -std=c11 -O0 -Wall -Wextra -I Development/CritterProduct/Pilot \
    PowerAssessment/IO/IO_main.c \
    Development/CritterProduct/Pilot/IO/critter_io.c \
    Utils/SenseHat/sense_hat_environment.c \
    -lm -o PowerAssessment/IO/IO

gcc -std=c11 -O0 -Wall -Wextra -I Development/CritterProduct/Pilot \
    PowerAssessment/mem/Mem_main.c \
    Development/CritterProduct/Pilot/Memory/critter_memory.c \
    -lm -o PowerAssessment/mem/Mem

gcc -std=c11 -O0 -Wall -Wextra -I Development/CritterProduct/Pilot \
    PowerAssessment/comp/Compute_main.c \
    Development/CritterProduct/Pilot/Computation/critter_computation.c \
    -lm -o PowerAssessment/comp/Compute

printf 'Built PowerAssessment/IO/IO, PowerAssessment/mem/Mem, PowerAssessment/comp/Compute\n'
