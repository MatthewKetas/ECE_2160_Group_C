#ifndef CRITTER_MEMORY_H
#define CRITTER_MEMORY_H

#include "../critter_types.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct
{
    /* A02: Fixed ownership and a verifiable upper bound, matching the Pilot window. */
    critter_sample_t buffer[CRITTER_MEMORY_MAX_CAPACITY];
    size_t capacity;
    size_t head;
    size_t count;
    size_t total_received_samples;
    size_t total_valid_samples;
    size_t total_rejected_samples;
    size_t total_outliers;
    double last_timestamp_s;
} critter_memory_t;

int critter_memory_init(critter_memory_t *memory, size_t capacity);
void critter_memory_free(critter_memory_t *memory);
int critter_memory_add_sample(critter_memory_t *memory, const critter_sample_t *sample);
int critter_memory_build_summary(const critter_memory_t *memory, critter_window_summary_t *summary);

#ifdef __cplusplus
}
#endif

#endif
