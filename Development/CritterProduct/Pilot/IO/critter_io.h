#ifndef CRITTER_IO_H
#define CRITTER_IO_H

#include "../critter_types.h"

#ifdef __cplusplus
extern "C" {
#endif

int critter_io_get_temperature(double *temperature_c, critter_temperature_source_t *source);
int critter_io_get_temperature_from_source(double *temperature_c, critter_temperature_source_t source);
int critter_io_read_sample(critter_sample_t *sample);
/* A05: Single-threaded owner must close the persistent sensor at shutdown. */
int critter_io_close(void);
int critter_io_save_sample(const critter_sample_t *sample);
int critter_io_save_metrics(const critter_window_summary_t *summary,
                           const critter_analysis_result_t *analysis,
                           size_t reads_attempted,
                           size_t valid_samples,
                           size_t rejected_samples,
                           size_t outlier_count,
                           double sample_rate_hz);

#ifdef __cplusplus
}
#endif

#endif
