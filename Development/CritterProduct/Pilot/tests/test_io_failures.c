#define _POSIX_C_SOURCE 200809L
#ifdef NDEBUG
#undef NDEBUG
#endif
#include <assert.h>
#include <errno.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

static int fail_write = 0;
static int fail_close = 0;
static int injected_fprintf(FILE *file, const char *format, ...) __attribute__((format(printf, 2, 3)));
static int injected_fprintf(FILE *file, const char *format, ...)
{
    if (fail_write)
    {
        errno = ENOSPC;
        return -1;
    }
    va_list arguments;
    va_start(arguments, format);
    int result = vfprintf(file, format, arguments);
    va_end(arguments);
    return result;
}
static int injected_fclose(FILE *file)
{
    int result = fclose(file);
    return fail_close ? EOF : result;
}
/* Test-only interposition: exercise real writer/reader branches deterministically. */
#define fprintf injected_fprintf
#define fclose injected_fclose
#include "../IO/critter_io.c"
#undef fprintf
#undef fclose

int main(void)
{
    char path[] = "/tmp/critter-faults-XXXXXX";
    int fd = mkstemp(path);
    assert(fd >= 0 && close(fd) == 0);
    assert(setenv("CRITTER_OUTPUT_FILE", path, 1) == 0);
    assert(setenv("CRITTER_METRICS_FILE", path, 1) == 0);
    critter_sample_t sample = {.timestamp_s = 1.0, .temperature_c = 20.0, .source = TEMPERATURE_SOURCE_DATA};
    critter_window_summary_t summary = {.sample_count = 1U, .retained_ratio = 1.0};
    critter_analysis_result_t analysis = {0};
    fail_write = 1;
    assert(critter_io_save_sample(&sample) == -1); /* Header failure. */
    assert(critter_io_save_metrics(&summary, &analysis, 1U, 1U, 0U, 0U, 1.0) == -1);
    fail_write = 0;
    assert(critter_io_save_sample(&sample) == 0);
    fail_write = 1;
    assert(critter_io_save_sample(&sample) == -1); /* Existing file: row failure. */
    assert(critter_io_save_metrics(&summary, &analysis, 1U, 1U, 0U, 0U, 1.0) == -1);
    fail_write = 0;
    fail_close = 1;
    assert(critter_io_save_sample(&sample) == -1);
    assert(critter_io_save_metrics(&summary, &analysis, 1U, 1U, 0U, 0U, 1.0) == -1);
    assert(setenv("CRITTER_DATA_FILE", path, 1) == 0);
    double temperature = 123.0;
    assert(critter_io_get_temperature_from_source(&temperature, TEMPERATURE_SOURCE_DATA) == -1);
    assert(temperature == 123.0); /* Failed close cannot publish output. */
    fail_close = 0;
    assert(unlink(path) == 0);
    puts("injected header, row, close and read-close failures passed");
    return 0;
}
