#include "critter_memory.h"

#include <math.h>
#include <stdlib.h>
#include <string.h>

static int critter_is_valid_sample(const critter_sample_t *sample)
{
    if (sample == NULL)
        return 0;

    if (!isfinite(sample->timestamp_s) || sample->timestamp_s <= 0.0)
        return 0;

    if (!isfinite(sample->temperature_c))
        return 0;

    if (sample->source < TEMPERATURE_SOURCE_SENSE_HAT || sample->source > TEMPERATURE_SOURCE_CPU)
        return 0;

    if (sample->has_humidity && (!isfinite(sample->humidity_percent) || sample->humidity_percent < 0.0 || sample->humidity_percent > 100.0))
        return 0;

    if (sample->has_pressure && (!isfinite(sample->pressure_hpa) || sample->pressure_hpa <= 0.0))
        return 0;

    return 1;
}

static double critter_median(double *values, size_t count)
{
    size_t i;
    size_t j;
    double temp;

    if (count == 0)
        return 0.0;

    for (i = 0; (i < count) && (i < CRITTER_MEMORY_MAX_SAMPLES); ++i)
    {
        for (j = i + 1; (j < count) && (j < CRITTER_MEMORY_MAX_SAMPLES); ++j)
        {
            if (values[j] < values[i])
            {
                temp = values[i];
                values[i] = values[j];
                values[j] = temp;
            }
        }
    }

    if (count % 2 == 0)
        return (values[count / 2 - 1] + values[count / 2]) / 2.0;

    return values[count / 2];
}

static double critter_stddev(const double *values, size_t count, double mean)
{
    double variance = 0.0;
    size_t i;

    if (count == 0)
        return 0.0;

    for (i = 0; (i < count) && (i < CRITTER_MEMORY_MAX_SAMPLES); ++i)
    {
        double diff = values[i] - mean;
        variance += diff * diff;
    }

    variance /= (double)count;
    return sqrt(variance);
}

static int critter_add_in_ring(critter_memory_t *memory, const critter_sample_t *sample)
{
    size_t index;

    if (memory == NULL || sample == NULL)
        return -1;

    index = memory->head;
    memory->buffer[index] = *sample;
    memory->head = (memory->head + 1U) % memory->capacity;

    if (memory->count < memory->capacity)
    {
        memory->count += 1U;
    }

    return 0;
}

static int critter_detect_outlier(const critter_memory_t *memory, const critter_sample_t *sample)
{
    size_t valid_count;
    size_t window_size;
    size_t i;
    double *temperatures;
    double median;
    double mad;
    double threshold;

    if (memory == NULL || sample == NULL)
        return 0;

    if (memory->scratch == NULL)
        return 0;


    valid_count = memory->count;
    if (valid_count < 3U)
        return 0;

    window_size = valid_count;
    temperatures = memory->scratch;

    for (i = 0; (i < window_size) && (i < CRITTER_MEMORY_MAX_SAMPLES); ++i)
    {
        size_t idx = (memory->head + memory->capacity - window_size + i) % memory->capacity;
        temperatures[i] = memory->buffer[idx].temperature_c;
    }

    median = critter_median(temperatures, window_size);
    for (i = 0; (i < window_size) && (i < CRITTER_MEMORY_MAX_SAMPLES); ++i)
    {
        temperatures[i] = fabs(temperatures[i] - median);
    }
    mad = critter_median(temperatures, window_size);
    threshold = 3.0 * mad + 0.5;

    if (fabs(sample->temperature_c - median) > threshold)
    {
        return 1;
    }

    return 0;
}

int critter_memory_init(critter_memory_t *memory, size_t capacity)
{
    if (memory == NULL || capacity == 0U || capacity > CRITTER_MEMORY_MAX_SAMPLES)
        return -1;

    memset(memory, 0, sizeof(*memory));
    memory->capacity = capacity;
    memory->buffer = (critter_sample_t *)calloc(capacity, sizeof(critter_sample_t));
    if (memory->buffer == NULL)
        return -1;

    memory->scratch = (double *)calloc(capacity, sizeof(double));
    if (memory->scratch == NULL)
    {
        free(memory->buffer);
        memory->buffer = NULL;
        return -1;


    }

    return 0;
}

void critter_memory_free(critter_memory_t *memory)
{
    if (memory == NULL)
        return;

    free(memory->buffer);
    memory->buffer = NULL;
    free(memory->scratch);
    memory->scratch = NULL;
    memory->capacity = 0U;
    memory->head = 0U;
    memory->count = 0U;
}

int critter_memory_add_sample(critter_memory_t *memory, const critter_sample_t *sample)
{
    int is_outlier;

    if (memory == NULL || sample == NULL)
        return -1;

    memory->total_received_samples += 1U;

    if (!critter_is_valid_sample(sample))
    {
        memory->total_rejected_samples += 1U;
        return -1;
    }

    memory->total_valid_samples += 1U;
    is_outlier = critter_detect_outlier(memory, sample);
    if (is_outlier)
    {
        memory->total_outliers += 1U;
        return 0;
    }

    if (critter_add_in_ring(memory, sample) != 0)
        return -1;

    memory->last_timestamp_s = sample->timestamp_s;
    return 0;
}

int critter_memory_build_summary(const critter_memory_t *memory,
                                 critter_window_summary_t *summary)
{
    size_t i;
    size_t count;
    double *temperatures;
    double mean;
    double min_temp;
    double max_temp;

    if ((memory == NULL) || (summary == NULL) || (memory->count == 0U))
    {
        return -1;
    }

    if (memory->total_received_samples == 0U)
    {
        return -1;
    }

    if (memory->scratch == NULL)
     {
        return -1;
     }

    count = memory->count;

    memset(summary, 0, sizeof(*summary));

    temperatures = memory->scratch;


    min_temp =
        memory->buffer[(memory->head + memory->capacity - count) %
                       memory->capacity].temperature_c;

    max_temp = min_temp;
    mean = 0.0;

    summary->first_timestamp_s =
        memory->buffer[(memory->head + memory->capacity - count) %
                       memory->capacity].timestamp_s;

    summary->last_timestamp_s =
        memory->buffer[(memory->head + memory->capacity - 1U) %
                       memory->capacity].timestamp_s;

    summary->source = TEMPERATURE_SOURCE_UNKNOWN;
    summary->sample_count = count;
    summary->valid_sample_count = count;
    summary->outlier_count = memory->total_outliers;

    for (i = 0U; (i < count) && (i < CRITTER_MEMORY_MAX_SAMPLES); ++i)
    {
        size_t index;

        index = (memory->head + memory->capacity - count + i) %
                memory->capacity;

        temperatures[i] = memory->buffer[index].temperature_c;
        mean += temperatures[i];

        if (temperatures[i] < min_temp)
        {
            min_temp = temperatures[i];
        }

        if (temperatures[i] > max_temp)
        {
            max_temp = temperatures[i];
        }

        if ((memory->buffer[index].source >= TEMPERATURE_SOURCE_SENSE_HAT) &&
            (memory->buffer[index].source <= TEMPERATURE_SOURCE_CPU))
        {
            summary->sample_count_by_source[
                memory->buffer[index].source] += 1U;
        }

        if (summary->source == TEMPERATURE_SOURCE_UNKNOWN)
        {
            summary->source = memory->buffer[index].source;
        }
        else if (summary->source != memory->buffer[index].source)
        {
            summary->source = TEMPERATURE_SOURCE_UNKNOWN;
        }
    }

    mean /= (double)count;

    summary->min_temperature_c = min_temp;
    summary->max_temperature_c = max_temp;
    summary->mean_temperature_c = mean;
    summary->median_temperature_c = critter_median(temperatures, count);
    summary->stddev_temperature_c =
        critter_stddev(temperatures, count, mean);

    summary->latest_temperature_c =
        memory->buffer[(memory->head + memory->capacity - 1U) %
                       memory->capacity].temperature_c;

    summary->retained_ratio =
        (double)count / (double)memory->total_received_samples;

    return 0;
}
