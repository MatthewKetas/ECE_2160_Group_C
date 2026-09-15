#ifndef SENSE_HAT_ENVIRONMENT_H
#define SENSE_HAT_ENVIRONMENT_H

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum
{
    SENSE_HAT_HTS_ODR_1_HZ = 1,
    SENSE_HAT_HTS_ODR_7_HZ = 2,
    SENSE_HAT_HTS_ODR_12_5_HZ = 3
} sense_hat_hts_odr_t;

typedef enum
{
    SENSE_HAT_PRESSURE_ODR_1_HZ = 1,
    SENSE_HAT_PRESSURE_ODR_7_HZ = 2,
    SENSE_HAT_PRESSURE_ODR_12_5_HZ = 3,
    SENSE_HAT_PRESSURE_ODR_25_HZ = 4
} sense_hat_pressure_odr_t;

typedef struct
{
    double temperature_c;
    double humidity_percent;
    double pressure_hpa;
} sense_hat_environment_reading_t;

typedef struct
{
    int hts_fd;
    int pressure_fd;
    bool initialized;

    double t0_c;
    double t1_c;
    int16_t t0_out;
    int16_t t1_out;

    double h0_percent;
    double h1_percent;
    int16_t h0_out;
    int16_t h1_out;
} sense_hat_environment_t;

/* Initialize an unowned handle; close a live handle before reinitialization. */
int sense_hat_environment_init(sense_hat_environment_t *sensor,
                               const char *i2c_device,
                               sense_hat_hts_odr_t hts_odr,
                               sense_hat_pressure_odr_t pressure_odr);

/* Close the I2C descriptors and reset the utility state. */
int sense_hat_environment_close(sense_hat_environment_t *sensor);

/* Change the continuous output data rate after initialization. */
int sense_hat_environment_set_hts_odr(const sense_hat_environment_t *sensor,
                                      sense_hat_hts_odr_t odr);
int sense_hat_environment_set_pressure_odr(const sense_hat_environment_t *sensor,
                                           sense_hat_pressure_odr_t odr);

/* Individual measurements. */
int sense_hat_environment_read_temperature(const sense_hat_environment_t *sensor,
                                           double *temperature_c);
int sense_hat_environment_read_humidity(const sense_hat_environment_t *sensor,
                                        double *humidity_percent);
int sense_hat_environment_read_pressure(const sense_hat_environment_t *sensor,
                                        double *pressure_hpa);

/* Required temperature; unavailable optional measurements are NAN. */
int sense_hat_environment_read(const sense_hat_environment_t *sensor,
                               sense_hat_environment_reading_t *reading);

#ifdef __cplusplus
}
#endif

#endif
