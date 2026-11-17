#include "replay_sensor.h"
#include "sense_hat_environment.h"

/* Replace the Linux sensor driver at its public boundary for this benchmark. */
static sense_hat_environment_reading_t replay_reading;

void replay_set_sample(const critter_sample_t *sample)
{
    replay_reading.temperature_c = sample->temperature_c;
    replay_reading.humidity_percent = sample->humidity_percent;
    replay_reading.pressure_hpa = sample->pressure_hpa;
}

int sense_hat_environment_init(sense_hat_environment_t *sensor,
                               const char *device,
                               sense_hat_hts_odr_t temperature_rate,
                               sense_hat_pressure_odr_t pressure_rate)
{
    (void)device;
    (void)temperature_rate;
    (void)pressure_rate;
    sensor->initialized = true;
    return 0;
}

int sense_hat_environment_read(sense_hat_environment_t *sensor,
                               sense_hat_environment_reading_t *reading)
{
    if (!sensor->initialized)
        return -1;
    *reading = replay_reading;
    return 0;
}

void sense_hat_environment_close(sense_hat_environment_t *sensor)
{
    sensor->initialized = false;
}
