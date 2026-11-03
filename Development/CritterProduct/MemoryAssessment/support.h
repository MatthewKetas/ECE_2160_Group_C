#ifndef ASSESS_SUPPORT_H
#define ASSESS_SUPPORT_H
#include <stddef.h>
#include "sense_hat_environment.h"
typedef struct {
    sense_hat_environment_t sensor;
    bool sensor_ready;
    bool data_ready;
    double last_value;
} assessment_io_context_t;
extern assessment_io_context_t *assessment_io_state;
void *assessment_malloc(size_t n);
void *assessment_calloc(size_t n, size_t size);
void assessment_free(void *p);
void assessment_probe_report(void);
#endif
