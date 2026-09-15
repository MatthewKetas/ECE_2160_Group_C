#define _POSIX_C_SOURCE 200809L

#include "critter_io.h"
#include "../../../../Utils/SenseHat/sense_hat_environment.h"

#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <time.h>
#include <unistd.h>

/* A05: Single-threaded Pilot owns the sensor until explicit shutdown. */
static sense_hat_environment_t sensor = {.hts_fd = -1, .pressure_fd = -1};
#define CRITTER_PATH_CAPACITY 4096U
#define CRITTER_SCAN_LIMIT 4096U

int critter_io_close(void)
{
    return sense_hat_environment_close(&sensor);
}

static int critter_read_sense_hat_environment(sense_hat_environment_reading_t *reading)
{
    if (reading == NULL)
        return -1;
    if (!sensor.initialized &&
        sense_hat_environment_init(&sensor, "/dev/i2c-1", SENSE_HAT_HTS_ODR_12_5_HZ,
                                   SENSE_HAT_PRESSURE_ODR_25_HZ) != 0)
        return -1;
    if (sense_hat_environment_read(&sensor, reading) == 0 &&
        isfinite(reading->temperature_c) && fabs(reading->temperature_c) <= CRITTER_NUMERIC_LIMIT)
        return 0;
    /* A05: Already failing; a cleanup failure cannot become success. */
    (void)critter_io_close();
    return -1;
}

static int critter_open_regular(const char *path, int flags)
{
    if (path == NULL || path[0] == '\0')
        return -1;
    /* A06/H04: Open first, inspect that descriptor; reject special files and leaf symlinks. */
    int fd = open(path, flags | O_NONBLOCK | O_NOFOLLOW, 0600);
    if (fd < 0)
        return -1;
    struct stat info;
    if (fstat(fd, &info) != 0 || !S_ISREG(info.st_mode))
    {
        (void)close(fd); /* Already returning failure; never retry close. */
        return -1;
    }
    return fd;
}

static int critter_parse_number(const char *text, double *value)
{
    if (text == NULL || value == NULL)
        return -1;
    char *end;
    /* A07: strtod reports overflow; scanf numeric overflow has no safe contract. */
    errno = 0;
    double parsed = strtod(text, &end);
    if (end == text || errno == ERANGE || !isfinite(parsed) || fabs(parsed) > CRITTER_NUMERIC_LIMIT)
        return -1;
    if (*end != ',' && *end != '\0' && *end != '\n' && *end != '\r')
        return -1;
    *value = parsed;
    return 0;
}

/* A23: Keep bounded parsing separate from replay position and stream ownership. */
static int critter_scan_data(FILE *file, double *value)
{
    if (file == NULL || value == NULL)
        return -1;
    char buffer[256];
    /* U02: At most 4096 bounded records per acquisition; EOF is failure. */
    for (size_t row = 0U; row < CRITTER_SCAN_LIMIT && fgets(buffer, sizeof(buffer), file) != NULL; ++row)
    {
        if (strchr(buffer, '\n') == NULL && !feof(file))
            return -1; /* A07: Do not interpret a fragment of an oversized row. */
        const char *comma = strchr(buffer, ',');
        if (comma != NULL && critter_parse_number(comma + 1, value) == 0)
            return 0;
    }
    return -1;
}

static int critter_read_data_temperature(double *temperature_c)
{
    static char previous_path[CRITTER_PATH_CAPACITY];
    static off_t position = 0;
    static ino_t inode = 0;
    static dev_t device = 0;
    const char *path = getenv("CRITTER_DATA_FILE");
    /* U01: getenv was already guarded; this was not an EXP33-C defect. */
    if (path == NULL || path[0] == '\0')
        path = "Development/CritterProduct/Pilot/Data/temperature_samples.csv";
    if (temperature_c == NULL || strlen(path) >= sizeof(previous_path))
        return -1;
    int fd = critter_open_regular(path, O_RDONLY);
    if (fd < 0)
        return -1; /* A08: Never report a cached value after source failure. */
    struct stat info;
    if (fstat(fd, &info) != 0)
    {
        (void)close(fd);
        return -1;
    }
    if (strcmp(path, previous_path) != 0 || inode != info.st_ino || device != info.st_dev || position > info.st_size)
        position = 0;
    /* A08: Advance through replay records instead of reopening at row one. */
    (void)memcpy(previous_path, path, strlen(path) + 1U);
    inode = info.st_ino;
    device = info.st_dev;
    FILE *file = fdopen(fd, "r");
    if (file == NULL)
    {
        (void)close(fd);
        return -1;
    }
    int status = -1;
    double value = 0.0;
    if (fseeko(file, position, SEEK_SET) == 0 && critter_scan_data(file, &value) == 0)
    {
        position = ftello(file);
        status = position < 0 ? -1 : 0;
    }
    /* U03/A09: Read/close failures invalidate the result on every exit path. */
    if (ferror(file))
        status = -1;
    if (fclose(file) != 0)
        status = -1;
    if (status == 0)
        *temperature_c = value;
    return status;
}

static int critter_read_cpu_temperature(double *temperature_c)
{
    if (temperature_c == NULL)
        return -1;
    int fd = critter_open_regular("/sys/class/thermal/thermal_zone0/temp", O_RDONLY);
    if (fd < 0)
        return -1;
    FILE *file = fdopen(fd, "r");
    if (file == NULL)
    {
        (void)close(fd);
        return -1;
    }
    char buffer[64];
    double raw = 0.0;
    int status = -1;
    /* A10: Bounded numeric input, checked conversion and checked close. */
    if (fgets(buffer, sizeof(buffer), file) != NULL &&
        (strchr(buffer, '\n') != NULL || feof(file)) &&
        critter_parse_number(buffer, &raw) == 0)
        status = 0;
    if (ferror(file))
        status = -1;
    if (fclose(file) != 0)
        status = -1;
    if (status == 0)
        *temperature_c = raw / 1000.0;
    return status;
}

static int critter_resolve_executable_directory(char *buffer, size_t buffer_size)
{
    if (buffer == NULL || buffer_size < 2U || buffer_size > CRITTER_PATH_CAPACITY)
        return -1;
    ssize_t length = readlink("/proc/self/exe", buffer, buffer_size - 1U);
    /* U04/A11: Reject truncated readlink output; no narrowing size-to-int comparison. */
    if (length < 0 || (size_t)length >= buffer_size - 1U)
        return -1;
    buffer[(size_t)length] = '\0';
    char *slash = strrchr(buffer, '/');
    if (slash == NULL)
        return -1;
    slash[slash == buffer ? 1 : 0] = '\0';
    return 0;
}

static int critter_open_default_output(const char *filename)
{
    char app_dir[CRITTER_PATH_CAPACITY];
    if (filename == NULL || strchr(filename, '/') != NULL ||
        critter_resolve_executable_directory(app_dir, sizeof(app_dir)) != 0)
        return -1;
    int app_fd = open(app_dir, O_RDONLY | O_DIRECTORY | O_NOFOLLOW);
    if (app_fd < 0)
        return -1;
    /* U05/H04: Anchor creation and opening to directory descriptors; no stat/mkdir race. */
    int data_fd = -1;
    if (mkdirat(app_fd, "Data", 0700) == 0 || errno == EEXIST)
        data_fd = openat(app_fd, "Data", O_RDONLY | O_DIRECTORY | O_NOFOLLOW);
    if (close(app_fd) != 0)
    {
        if (data_fd >= 0)
            (void)close(data_fd);
        return -1;
    }
    if (data_fd < 0)
        return -1;
    int fd = openat(data_fd, filename, O_WRONLY | O_APPEND | O_CREAT | O_NONBLOCK | O_NOFOLLOW, 0600);
    if (close(data_fd) != 0)
    {
        if (fd >= 0)
            (void)close(fd);
        return -1;
    }
    return fd;
}

static FILE *critter_open_csv(const char *environment, const char *filename, const char *header)
{
    if (environment == NULL || filename == NULL || header == NULL)
        return NULL;
    const char *path = getenv(environment);
    /* U06/U09/U10: Eliminate truncating copies and filename appends entirely. */
    int fd = (path != NULL && path[0] != '\0') ?
        critter_open_regular(path, O_WRONLY | O_APPEND | O_CREAT) : critter_open_default_output(filename);
    if (fd < 0)
        return NULL;
    struct stat info;
    if (fstat(fd, &info) != 0 || !S_ISREG(info.st_mode))
    {
        (void)close(fd);
        return NULL;
    }
    FILE *file = fdopen(fd, "a");
    if (file == NULL)
    {
        (void)close(fd);
        return NULL;
    }
    /* U07/U11: Descriptor size replaces ftell; header errors reach the caller. */
    if (info.st_size == 0 && fprintf(file, "%s", header) < 0)
    {
        (void)fclose(file); /* Already returning failure. */
        return NULL;
    }
    return file;
}

static const char *critter_source_name(critter_temperature_source_t source)
{
    switch (source)
    {
        case TEMPERATURE_SOURCE_SENSE_HAT: return "sense_hat";
        case TEMPERATURE_SOURCE_DATA: return "data";
        case TEMPERATURE_SOURCE_CPU: return "cpu";
        default: return "unknown";
    }
}

int critter_io_get_temperature_from_source(double *temperature_c, critter_temperature_source_t source)
{
    if (temperature_c == NULL)
        return -1;
    if (source == TEMPERATURE_SOURCE_SENSE_HAT)
    {
        sense_hat_environment_reading_t reading;
        if (critter_read_sense_hat_environment(&reading) != 0)
            return -1;
        *temperature_c = reading.temperature_c;
        return 0;
    }
    if (source == TEMPERATURE_SOURCE_DATA)
        return critter_read_data_temperature(temperature_c);
    if (source == TEMPERATURE_SOURCE_CPU)
        return critter_read_cpu_temperature(temperature_c);
    return -1;
}

int critter_io_read_sample(critter_sample_t *sample)
{
    if (sample == NULL)
        return -1;
    critter_sample_t acquired = {0};
    sense_hat_environment_reading_t reading;
    /* A12: Acquire once; a second sensor read previously bypassed fallback on failure. */
    if (critter_read_sense_hat_environment(&reading) == 0)
    {
        acquired.temperature_c = reading.temperature_c;
        acquired.humidity_percent = reading.humidity_percent;
        acquired.pressure_hpa = reading.pressure_hpa;
        acquired.has_humidity = isfinite(reading.humidity_percent) && reading.humidity_percent >= 0.0 && reading.humidity_percent <= 100.0;
        acquired.has_pressure = isfinite(reading.pressure_hpa) && reading.pressure_hpa > 0.0 && reading.pressure_hpa <= CRITTER_NUMERIC_LIMIT;
        acquired.source = TEMPERATURE_SOURCE_SENSE_HAT;
    }
    else if (critter_read_data_temperature(&acquired.temperature_c) == 0)
        acquired.source = TEMPERATURE_SOURCE_DATA;
    else if (critter_read_cpu_temperature(&acquired.temperature_c) == 0)
        acquired.source = TEMPERATURE_SOURCE_CPU;
    else
        return -1;
    struct timespec timestamp;
    if (clock_gettime(CLOCK_REALTIME, &timestamp) != 0)
        return -1;
    acquired.timestamp_s = (double)timestamp.tv_sec + (double)timestamp.tv_nsec / 1.0e9;
    if (!critter_sample_valid(&acquired))
        return -1;
    *sample = acquired;
    return 0;
}

int critter_io_get_temperature(double *temperature_c, critter_temperature_source_t *source)
{
    if (temperature_c == NULL || source == NULL)
        return -1;
    critter_sample_t sample;
    if (critter_io_read_sample(&sample) != 0)
        return -1;
    *temperature_c = sample.temperature_c;
    *source = sample.source;
    return 0;
}

int critter_io_save_sample(const critter_sample_t *sample)
{
    /* H03: Reject invalid samples before publishing them to disk. */
    if (!critter_sample_valid(sample))
        return -1;
    /* A13: Replay input is immutable; output has its own configuration. */
    FILE *file = critter_open_csv("CRITTER_OUTPUT_FILE", "temperature_samples.csv",
        "timestamp_s,temperature_c,humidity_percent,pressure_hpa,source,has_humidity,has_pressure\n");
    if (file == NULL)
        return -1;
    int written = fprintf(file, "%.6f,%.6f,%.6f,%.6f,%s,%d,%d\n",
        sample->timestamp_s, sample->temperature_c,
        sample->has_humidity ? sample->humidity_percent : 0.0,
        sample->has_pressure ? sample->pressure_hpa : 0.0,
        critter_source_name(sample->source), sample->has_humidity ? 1 : 0, sample->has_pressure ? 1 : 0);
    /* U08: Check close even when the row write has already failed. */
    int closed = fclose(file);
    return written < 0 || closed != 0 ? -1 : 0;
}

int critter_io_save_metrics(const critter_window_summary_t *summary,
                           const critter_analysis_result_t *analysis,
                           size_t reads_attempted, size_t valid_samples,
                           size_t rejected_samples, size_t outlier_count, double sample_rate_hz)
{
    /* H05: Validate exported counts and all numeric fields actually serialized. */
    if (summary == NULL || analysis == NULL || !isfinite(sample_rate_hz) || sample_rate_hz < 0.0 ||
        valid_samples > reads_attempted || rejected_samples != reads_attempted - valid_samples || outlier_count > valid_samples ||
        !isfinite(summary->retained_ratio) || summary->retained_ratio < 0.0 || summary->retained_ratio > 1.0 ||
        summary->sample_count == 0U || summary->sample_count > valid_samples ||
        !isfinite(summary->min_temperature_c) || !isfinite(summary->max_temperature_c) ||
        !isfinite(summary->mean_temperature_c) || !isfinite(summary->median_temperature_c) ||
        !isfinite(summary->stddev_temperature_c) || summary->stddev_temperature_c < 0.0 ||
        !isfinite(analysis->analysis_timestamp_s) || !isfinite(analysis->current_temperature_c) ||
        !isfinite(analysis->predicted_temperature_c) || !isfinite(analysis->trend_c_per_s) ||
        !isfinite(analysis->rate_of_change_c_per_s))
        return -1;
    FILE *file = critter_open_csv("CRITTER_METRICS_FILE", "collection_metrics.csv",
        "timestamp_s,reads_attempted,valid_samples,rejected_samples,outlier_count,sample_rate_hz,retained_ratio,summary_count,min_temperature_c,max_temperature_c,mean_temperature_c,median_temperature_c,stddev_temperature_c,source,current_temperature_c,predicted_temperature_c,trend_c_per_s,rate_of_change_c_per_s,likely_hvac_active,likely_heating,likely_cooling,stable\n");
    if (file == NULL)
        return -1;
    /* A14: This unannotated metrics row write also needs error propagation. */
    int written = fprintf(file,
        "%.6f,%zu,%zu,%zu,%zu,%.6f,%.6f,%zu,%.6f,%.6f,%.6f,%.6f,%.6f,%s,%.6f,%.6f,%.6f,%.6f,%d,%d,%d,%d\n",
        analysis->analysis_timestamp_s, reads_attempted, valid_samples, rejected_samples,
        outlier_count, sample_rate_hz, summary->retained_ratio, summary->sample_count,
        summary->min_temperature_c, summary->max_temperature_c, summary->mean_temperature_c,
        summary->median_temperature_c, summary->stddev_temperature_c, critter_source_name(summary->source),
        analysis->current_temperature_c, analysis->predicted_temperature_c, analysis->trend_c_per_s,
        analysis->rate_of_change_c_per_s, analysis->likely_hvac_active ? 1 : 0,
        analysis->likely_heating ? 1 : 0, analysis->likely_cooling ? 1 : 0, analysis->stable ? 1 : 0);
    /* U12: A flush failure during close must never be reported as success. */
    int closed = fclose(file);
    return written < 0 || closed != 0 ? -1 : 0;
}
