#include "critter_memory.h"

#include <float.h>
#include <math.h>

/* A01: Check ring invariants before any indexing or remainder operation. */
static int critter_memory_valid(const critter_memory_t *memory)
{
    return memory != NULL && memory->capacity > 0U &&
           memory->capacity <= CRITTER_MEMORY_MAX_CAPACITY &&
           memory->head < memory->capacity && memory->count <= memory->capacity;
}

static double critter_median(double *values, size_t count)
{
    if (values == NULL || count == 0U || count > CRITTER_MEMORY_MAX_CAPACITY)
        return NAN;
    for (size_t i = 0U; i < count; ++i)
    {
        for (size_t j = i + 1U; j < count; ++j)
        {
            if (values[j] < values[i])
            {
                /* S01: A swap temporary belongs only to this block. */
                double temp = values[i];
                values[i] = values[j];
                values[j] = temp;
            }
        }
    }
    /* H01: Halve before adding to avoid an overflowing midpoint. */
    if (count % 2U == 0U)
        return values[count / 2U - 1U] / 2.0 + values[count / 2U] / 2.0;
    return values[count / 2U];
}

/* S03: Statistics only read the supplied values. */
static double critter_stddev(const double *values, size_t count, double mean)
{
    if (values == NULL || count == 0U || count > CRITTER_MEMORY_MAX_CAPACITY || !isfinite(mean))
        return NAN;
    double variance = 0.0;
    for (size_t i = 0U; i < count; ++i)
    {
        double diff = values[i] - mean;
        variance += diff * diff;
    }
    variance /= (double)count;
    /* H01: Numeric sample bounds make the sum finite and sqrt's domain valid. */
    if (!isfinite(variance) || variance < 0.0)
        return NAN;
    return sqrt(variance);
}

static size_t critter_ring_index(const critter_memory_t *memory, size_t offset)
{
    /* A01: Caller validates state; capacity <= 100 bounds this arithmetic. */
    return (memory->head + memory->capacity - memory->count + offset) % memory->capacity;
}

static int critter_detect_outlier(const critter_memory_t *memory, const critter_sample_t *sample)
{
    if (!critter_memory_valid(memory) || sample == NULL)
        return -1;
    size_t count = memory->count;
    if (count < 3U)
        return 0;
    /* U13: Fixed stack workspace replaces allocation during acquisition. */
    double temperatures[CRITTER_MEMORY_MAX_CAPACITY];
    for (size_t i = 0U; i < count; ++i)
        temperatures[i] = memory->buffer[critter_ring_index(memory, i)].temperature_c;
    double median = critter_median(temperatures, count);
    for (size_t i = 0U; i < count; ++i)
        temperatures[i] = fabs(temperatures[i] - median);
    double mad = critter_median(temperatures, count);
    if (!isfinite(median) || !isfinite(mad))
        return -1;
    return fabs(sample->temperature_c - median) > 3.0 * mad + 0.5;
}

int critter_memory_init(critter_memory_t *memory, size_t capacity)
{
    if (memory == NULL)
        return -1;
    /* A02: Embedded storage has no allocation product, ownership leak or failed-allocation state. */
    *memory = (critter_memory_t){0};
    if (capacity == 0U || capacity > CRITTER_MEMORY_MAX_CAPACITY)
        return -1;
    memory->capacity = capacity;
    return 0;
}

void critter_memory_free(critter_memory_t *memory)
{
    if (memory != NULL)
        *memory = (critter_memory_t){0};
}

int critter_memory_add_sample(critter_memory_t *memory, const critter_sample_t *sample)
{
    if (!critter_memory_valid(memory) || sample == NULL)
        return -1;
    /* A03: Bound lifetime counters, including their exact conversion to double. */
    if (memory->total_received_samples >= CRITTER_MAX_SAMPLE_TOTAL ||
        memory->total_valid_samples > memory->total_received_samples ||
        memory->total_rejected_samples > memory->total_received_samples ||
        memory->total_outliers > memory->total_valid_samples)
        return -1;
    memory->total_received_samples += 1U;
    /* H02: Reject backward/duplicate times before changing the retained history. */
    if (!critter_sample_valid(sample) || sample->timestamp_s <= memory->last_timestamp_s)
    {
        memory->total_rejected_samples += 1U;
        return -1;
    }
    int is_outlier = critter_detect_outlier(memory, sample);
    if (is_outlier < 0)
    {
        memory->total_rejected_samples += 1U;
        return -1;
    }
    memory->total_valid_samples += 1U;
    memory->last_timestamp_s = sample->timestamp_s;
    if (is_outlier != 0)
    {
        memory->total_outliers += 1U;
        return 0;
    }
    memory->buffer[memory->head] = *sample;
    memory->head = (memory->head + 1U) % memory->capacity;
    if (memory->count < memory->capacity)
        memory->count += 1U;
    return 0;
}

int critter_memory_build_summary(const critter_memory_t *memory, critter_window_summary_t *summary)
{
    if (!critter_memory_valid(memory) || summary == NULL || memory->count == 0U ||
        memory->total_received_samples < memory->count ||
        memory->total_received_samples > CRITTER_MAX_SAMPLE_TOTAL)
        return -1;
    /* U14: Fixed workspace; memset never allocated memory in the original. */
    double temperatures[CRITTER_MEMORY_MAX_CAPACITY];
    critter_window_summary_t built = {0};
    size_t count = memory->count;
    built.min_temperature_c = DBL_MAX;
    built.max_temperature_c = -DBL_MAX;
    built.sample_count = count;
    built.valid_sample_count = count;
    built.outlier_count = memory->total_outliers;
    for (size_t i = 0U; i < count; ++i)
    {
        /* S02: Index is local to the only loop that uses it. */
        size_t index = critter_ring_index(memory, i);
        critter_sample_t sample = memory->buffer[index];
        if (!critter_sample_valid(&sample) || (i > 0U && sample.timestamp_s <= built.last_timestamp_s))
            return -1;
        temperatures[i] = sample.temperature_c;
        /* H01: Online mean preserves constant windows without sum overflow. */
        built.mean_temperature_c += (sample.temperature_c - built.mean_temperature_c) / (double)(i + 1U);
        if (sample.temperature_c < built.min_temperature_c)
            built.min_temperature_c = sample.temperature_c;
        if (sample.temperature_c > built.max_temperature_c)
            built.max_temperature_c = sample.temperature_c;
        built.sample_count_by_source[sample.source] += 1U;
        /* A04: Initialize source once; mixed histories must stay mixed. */
        if (i == 0U)
        {
            built.source = sample.source;
            built.first_timestamp_s = sample.timestamp_s;
            built.first_temperature_c = sample.temperature_c;
        }
        else if (built.source != sample.source)
            built.source = TEMPERATURE_SOURCE_UNKNOWN;
        built.last_timestamp_s = sample.timestamp_s;
        built.latest_temperature_c = sample.temperature_c;
    }
    built.median_temperature_c = critter_median(temperatures, count);
    built.stddev_temperature_c = critter_stddev(temperatures, count, built.mean_temperature_c);
    /* S09: Validate the actual denominator, rather than repeat count > 0. */
    built.retained_ratio = (double)count / (double)memory->total_received_samples;
    if (!isfinite(built.stddev_temperature_c))
        return -1;
    *summary = built;
    return 0;
}
