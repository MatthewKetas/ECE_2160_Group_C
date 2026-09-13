#define _POSIX_C_SOURCE 200809L

#include "critter_io.h"

#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <math.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <time.h>
#include <unistd.h>



#ifndef PATH_MAX
#define PATH_MAX 4096
#endif



#define CRITTER_IO_MAX_IO_ITERS      4096U   
#define CRITTER_IO_MAX_READ_STEPS    1000000U  
#define CRITTER_IO_MAX_LINES         1000000U  
#define CRITTER_IO_MAX_EINTR_RETRIES 1024U   

#include "../../../../Utils/SenseHat/sense_hat_environment.h"



static int critter_write_all(int fd, const char *data, size_t length)
{
    size_t written = 0U;
    size_t guard;
 
    for (guard = 0U; (written < length) && (guard < CRITTER_IO_MAX_IO_ITERS); ++guard)
    {
        ssize_t n = write(fd, data + written, length - written);
        if (n < 0)
        {
            if (errno == EINTR)
                continue;
            return -1;
        }
        written += (size_t)n;
    }
 
    return (written == length) ? 0 : -1;
}



typedef struct
{
    int    fd;
    char   chunk[512];
    size_t chunk_len;
    size_t chunk_pos;
    int    at_eof;
} critter_line_reader_t;
 
static void critter_line_reader_open(critter_line_reader_t *reader, int fd)
{
    reader->fd = fd;
    reader->chunk_len = 0U;
    reader->chunk_pos = 0U;
    reader->at_eof = 0;
}
 

static int critter_line_reader_next(critter_line_reader_t *reader, char *out, size_t out_size)
{
    size_t out_len = 0U;
    int saw_any = 0;
    size_t step;
 
    if (reader == NULL || out == NULL || out_size == 0U)
        return -1;
 
    for (step = 0U; step < CRITTER_IO_MAX_READ_STEPS; ++step)
    {
        size_t scan;
 
        if (reader->chunk_pos >= reader->chunk_len)
        {
            ssize_t n;
 
            if (reader->at_eof)
                break;
 
            n = read(reader->fd, reader->chunk, sizeof(reader->chunk));
            if (n < 0)
            {
                if (errno == EINTR)
                    continue;
                return -1;
            }
            if (n == 0)
            {
                reader->at_eof = 1;
                break;
            }
 
            reader->chunk_len = (size_t)n;
            reader->chunk_pos = 0U;
        }
 
        for (scan = 0U;
             (reader->chunk_pos < reader->chunk_len) && (scan < sizeof(reader->chunk));
             ++scan)
        {
            char c = reader->chunk[reader->chunk_pos];
            reader->chunk_pos += 1U;
            saw_any = 1;
 
            if (c == '\n')
            {
                out[out_len] = '\0';
                return 1;
            }
 
            if (out_len + 1U < out_size)
            {
                out[out_len] = c;
                out_len += 1U;
            }
        }
    }
 
    if (saw_any)
    {
        out[out_len] = '\0';
        return 1;
    }
 
    return 0;
}

static int critter_read_sense_hat_environment(double *temperature_c,
                                              double *humidity_percent,
                                              double *pressure_hpa)
{
    static sense_hat_environment_t sensor = {0};
    static bool initialized = false;
    sense_hat_environment_reading_t reading = {0};

    if (!initialized)
    {
        if (sense_hat_environment_init(&sensor, "/dev/i2c-1",
                                      SENSE_HAT_HTS_ODR_1_HZ,
                                      SENSE_HAT_PRESSURE_ODR_1_HZ) != 0)
        {
            return -1;
        }
        initialized = true;
    }

    if (sense_hat_environment_read(&sensor, &reading) == 0)
    {
        if (temperature_c != NULL)
            *temperature_c = reading.temperature_c;
        if (humidity_percent != NULL)
            *humidity_percent = reading.humidity_percent;
        if (pressure_hpa != NULL)
            *pressure_hpa = reading.pressure_hpa;
        return 0;
    }

    sense_hat_environment_close(&sensor);
    initialized = false;
    return -1;
}

static int critter_read_sense_hat_temperature(double *temperature_c)
{
    if (temperature_c == NULL)
        return -1;

    return critter_read_sense_hat_environment(temperature_c, NULL, NULL);
}

static int critter_read_data_temperature(double *temperature_c)
{
    static bool initialized = false;
    static double last_value = 20.0;
    const char *path = getenv("CRITTER_DATA_FILE");
    int fd;
    double value = 0.0;
    char line[256];
    critter_line_reader_t reader;
    int status;
    size_t line_index;
 
    if (temperature_c == NULL)
        return -1;
 
    if (path == NULL || path[0] == '\0')
    {
        path = "Development/Data/temperature_samples.csv";
    }
 
    fd = open(path, O_RDONLY);
    if (fd < 0)
    {
        if (initialized)
        {
            *temperature_c = last_value;
            return 0;
        }
        return -1;
    }
 
    critter_line_reader_open(&reader, fd);
 
    for (line_index = 0U; line_index < CRITTER_IO_MAX_LINES; ++line_index)
    {
        status = critter_line_reader_next(&reader, line, sizeof(line));
        if (status != 1)
            break;
 
        if (strchr(line, ',') == NULL)
            continue;
 
        if (sscanf(line, "%*[^,],%lf", &value) == 1)
        {
            close(fd);
            initialized = true;
            last_value = value;
            *temperature_c = value;
            return 0;
        }
    }
 
    close(fd);
 
    if (initialized)
    {
        *temperature_c = last_value;
        return 0;
    }
 
    return -1;
}

static int critter_read_cpu_temperature(double *temperature_c)
{
    int fd;
    int raw_millicelsius = 0;
    char buffer[64];
    ssize_t n = -1;
    size_t retry;
 
    if (temperature_c == NULL)
        return -1;
 
    fd = open("/sys/class/thermal/thermal_zone0/temp", O_RDONLY);
    if (fd < 0)
        return -1;
 
    for (retry = 0U; retry < CRITTER_IO_MAX_EINTR_RETRIES; ++retry)
    {
        n = read(fd, buffer, sizeof(buffer) - 1U);
        if (!(n < 0 && errno == EINTR))
            break;
    }
 
    close(fd);
 
    if (n <= 0)
        return -1;
 
    buffer[n] = '\0';
 
    if (sscanf(buffer, "%d", &raw_millicelsius) != 1)
        return -1;
 
    *temperature_c = (double)raw_millicelsius / 1000.0;
    return 0;
}

static int critter_resolve_executable_directory(char *buffer, size_t buffer_size)
{
    char exe_path[PATH_MAX];
    ssize_t length;
    char *slash;

    if (buffer == NULL || buffer_size == 0U)
        return -1;

    length = readlink("/proc/self/exe", exe_path, sizeof(exe_path) - 1U);
    if (length < 0)
        return -1;

    exe_path[length] = '\0';
    slash = strrchr(exe_path, '/');
    if (slash == NULL)
        return -1;

    *slash = '\0';

    if (snprintf(buffer, buffer_size, "%s", exe_path) >= (int)buffer_size)
        return -1;

    return 0;
}

static int critter_resolve_runtime_data_path(char *buffer, size_t buffer_size)
{
    char app_dir[PATH_MAX];
    int written;

    if (buffer == NULL || buffer_size == 0U)
        return -1;

    if (critter_resolve_executable_directory(app_dir, sizeof(app_dir)) != 0)
        return -1;

    written = snprintf(buffer, buffer_size, "%s/Data/temperature_samples.csv", app_dir);
    if (written < 0 || (size_t)written >= buffer_size)
        return -1;

    return 0;
}

static int critter_ensure_runtime_data_directory(void)
{
    char app_dir[PATH_MAX];
    char data_dir[PATH_MAX];
    struct stat info;

    if (critter_resolve_executable_directory(app_dir, sizeof(app_dir)) != 0)
        return -1;

    if (snprintf(data_dir, sizeof(data_dir), "%s/Data", app_dir) >= (int)sizeof(data_dir))
        return -1;

    if (stat(data_dir, &info) != 0)
    {
        if (mkdir(data_dir, 0777) != 0 && errno != EEXIST)
            return -1;
    }
    else if (!S_ISDIR(info.st_mode))
    {
        return -1;
    }

    return 0;
}

int critter_io_get_temperature_from_source(double *temperature_c, critter_temperature_source_t source)
{
    if (temperature_c == NULL)
        return -1;

    switch (source)
    {
        case TEMPERATURE_SOURCE_SENSE_HAT:
            return critter_read_sense_hat_temperature(temperature_c);
        case TEMPERATURE_SOURCE_DATA:
            return critter_read_data_temperature(temperature_c);
        case TEMPERATURE_SOURCE_CPU:
            return critter_read_cpu_temperature(temperature_c);
        default:
            return -1;
    }
}

int critter_io_get_temperature(double *temperature_c, critter_temperature_source_t *source)
{
    if (temperature_c == NULL || source == NULL)
        return -1;

    if (critter_io_get_temperature_from_source(temperature_c, TEMPERATURE_SOURCE_SENSE_HAT) == 0)
    {
        *source = TEMPERATURE_SOURCE_SENSE_HAT;
        return 0;
    }

    if (critter_io_get_temperature_from_source(temperature_c, TEMPERATURE_SOURCE_DATA) == 0)
    {
        *source = TEMPERATURE_SOURCE_DATA;
        return 0;
    }

    if (critter_io_get_temperature_from_source(temperature_c, TEMPERATURE_SOURCE_CPU) == 0)
    {
        *source = TEMPERATURE_SOURCE_CPU;
        return 0;
    }

    return -1;
}

int critter_io_read_sample(critter_sample_t *sample)
{
    double temperature_c = 0.0;
    critter_temperature_source_t source = TEMPERATURE_SOURCE_UNKNOWN;
    double humidity = 0.0;
    double pressure = 0.0;

    if (sample == NULL)
        return -1;

    if (critter_io_get_temperature(&temperature_c, &source) != 0)
        return -1;

    if (source == TEMPERATURE_SOURCE_SENSE_HAT)
    {
        if (critter_read_sense_hat_environment(&temperature_c, &humidity, &pressure) != 0)
            return -1;
        sample->has_humidity = true;
        sample->has_pressure = true;
    }
    else
    {
        sample->has_humidity = false;
        sample->has_pressure = false;
    }

    sample->timestamp_s = (double)time(NULL);
    sample->temperature_c = temperature_c;
    sample->source = source;
    sample->humidity_percent = humidity;
    sample->pressure_hpa = pressure;

    return 0;
}

fclose(file);
