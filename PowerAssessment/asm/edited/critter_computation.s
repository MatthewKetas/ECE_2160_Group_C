	.arch armv8-a
	.file	"critter_computation.c"
// GNU C11 (Debian 14.2.0-19) version 14.2.0 (aarch64-linux-gnu)
//	compiled by GNU C version 14.2.0, GMP version 6.3.0, MPFR version 4.2.1, MPC version 1.3.1, isl version isl-0.27-GMP

// warning: MPFR header version 4.2.1 differs from library version 4.2.2.
// GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
// options passed: -mlittle-endian -mabi=lp64 -O0 -std=c11 -fasynchronous-unwind-tables
	.text
	.align	2
	.global	critter_compute_analysis
	.type	critter_compute_analysis, %function
critter_compute_analysis:
.LFB0:
	.cfi_startproc
	sub	sp, sp, #80	//,,
	.cfi_def_cfa_offset 80
	str	x0, [sp, 24]	// summary, summary
	str	d0, [sp, 16]	// prediction_horizon_s, prediction_horizon_s
	str	x1, [sp, 8]	// result, result
// Development/CritterProduct/Pilot/Computation/critter_computation.c:15:     if (summary == NULL || result == NULL || summary->sample_count == 0U || !isfinite(prediction_horizon_s))
	ldr	x0, [sp, 24]	// tmp140, summary
	cmp	x0, 0	// tmp140,
	beq	.L2		//,
// Development/CritterProduct/Pilot/Computation/critter_computation.c:15:     if (summary == NULL || result == NULL || summary->sample_count == 0U || !isfinite(prediction_horizon_s))
	ldr	x0, [sp, 8]	// tmp141, result
	cmp	x0, 0	// tmp141,
	beq	.L2		//,
// Development/CritterProduct/Pilot/Computation/critter_computation.c:15:     if (summary == NULL || result == NULL || summary->sample_count == 0U || !isfinite(prediction_horizon_s))
	ldr	x0, [sp, 24]	// tmp142, summary
	ldr	x0, [x0]	// _1, summary_42(D)->sample_count
// Development/CritterProduct/Pilot/Computation/critter_computation.c:15:     if (summary == NULL || result == NULL || summary->sample_count == 0U || !isfinite(prediction_horizon_s))
	cmp	x0, 0	// _1,
	beq	.L2		//,
// Development/CritterProduct/Pilot/Computation/critter_computation.c:15:     if (summary == NULL || result == NULL || summary->sample_count == 0U || !isfinite(prediction_horizon_s))
	ldr	d31, [sp, 16]	// tmp143, prediction_horizon_s
	fabs	d31, d31	// _2, tmp143
// Development/CritterProduct/Pilot/Computation/critter_computation.c:15:     if (summary == NULL || result == NULL || summary->sample_count == 0U || !isfinite(prediction_horizon_s))
	mov	x0, 9218868437227405311	// tmp233,
	fmov	d30, x0	// tmp144, tmp233
	fcmp	d31, d30	// _2, tmp144
	bhi	.L2		//,
	b	.L31		//
.L2:
// Development/CritterProduct/Pilot/Computation/critter_computation.c:16:         return -1;
	mov	w0, -1	// _36,
	b	.L5		//
.L31:
// Development/CritterProduct/Pilot/Computation/critter_computation.c:18:     result->analysis_timestamp_s = summary->last_timestamp_s;
	ldr	x0, [sp, 24]	// tmp145, summary
	ldr	d31, [x0, 104]	// _3, summary_42(D)->last_timestamp_s
// Development/CritterProduct/Pilot/Computation/critter_computation.c:18:     result->analysis_timestamp_s = summary->last_timestamp_s;
	ldr	x0, [sp, 8]	// tmp146, result
	str	d31, [x0, 40]	// _3, result_43(D)->analysis_timestamp_s
// Development/CritterProduct/Pilot/Computation/critter_computation.c:19:     result->current_temperature_c = summary->latest_temperature_c;
	ldr	x0, [sp, 24]	// tmp147, summary
	ldr	d31, [x0, 128]	// _4, summary_42(D)->latest_temperature_c
// Development/CritterProduct/Pilot/Computation/critter_computation.c:19:     result->current_temperature_c = summary->latest_temperature_c;
	ldr	x0, [sp, 8]	// tmp148, result
	str	d31, [x0]	// _4, result_43(D)->current_temperature_c
// Development/CritterProduct/Pilot/Computation/critter_computation.c:20:     result->source = summary->source;
	ldr	x0, [sp, 24]	// tmp149, summary
	ldr	w1, [x0, 120]	// _5, summary_42(D)->source
// Development/CritterProduct/Pilot/Computation/critter_computation.c:20:     result->source = summary->source;
	ldr	x0, [sp, 8]	// tmp150, result
	str	w1, [x0, 88]	// _5, result_43(D)->source
// Development/CritterProduct/Pilot/Computation/critter_computation.c:21:     result->prediction_horizon_s = prediction_horizon_s;
	ldr	x0, [sp, 8]	// tmp151, result
	ldr	d31, [sp, 16]	// tmp152, prediction_horizon_s
	str	d31, [x0, 32]	// tmp152, result_43(D)->prediction_horizon_s
// Development/CritterProduct/Pilot/Computation/critter_computation.c:23:     delta_t = summary->last_timestamp_s - summary->first_timestamp_s;
	ldr	x0, [sp, 24]	// tmp153, summary
	ldr	d30, [x0, 104]	// _6, summary_42(D)->last_timestamp_s
// Development/CritterProduct/Pilot/Computation/critter_computation.c:23:     delta_t = summary->last_timestamp_s - summary->first_timestamp_s;
	ldr	x0, [sp, 24]	// tmp154, summary
	ldr	d31, [x0, 96]	// _7, summary_42(D)->first_timestamp_s
// Development/CritterProduct/Pilot/Computation/critter_computation.c:23:     delta_t = summary->last_timestamp_s - summary->first_timestamp_s;
	fsub	d31, d30, d31	// delta_t_50, _6, _7
	str	d31, [sp, 72]	// delta_t_50, delta_t
// Development/CritterProduct/Pilot/Computation/critter_computation.c:24:     if (delta_t <= 0.0)
	ldr	d31, [sp, 72]	// tmp156, delta_t
	fcmpe	d31, #0.0	// tmp156
	bls	.L24		//,
	b	.L6		//
.L24:
// Development/CritterProduct/Pilot/Computation/critter_computation.c:25:         delta_t = 1.0;
	fmov	d31, 1.0e+0	// tmp157,
	str	d31, [sp, 72]	// tmp157, delta_t
.L6:
// Development/CritterProduct/Pilot/Computation/critter_computation.c:27:     slope = (summary->latest_temperature_c - summary->mean_temperature_c) / delta_t;
	ldr	x0, [sp, 24]	// tmp158, summary
	ldr	d30, [x0, 128]	// _8, summary_42(D)->latest_temperature_c
// Development/CritterProduct/Pilot/Computation/critter_computation.c:27:     slope = (summary->latest_temperature_c - summary->mean_temperature_c) / delta_t;
	ldr	x0, [sp, 24]	// tmp159, summary
	ldr	d31, [x0, 72]	// _9, summary_42(D)->mean_temperature_c
// Development/CritterProduct/Pilot/Computation/critter_computation.c:27:     slope = (summary->latest_temperature_c - summary->mean_temperature_c) / delta_t;
	fsub	d30, d30, d31	// _10, _8, _9
// Development/CritterProduct/Pilot/Computation/critter_computation.c:27:     slope = (summary->latest_temperature_c - summary->mean_temperature_c) / delta_t;
	ldr	d31, [sp, 72]	// tmp161, delta_t
	fdiv	d31, d30, d31	// slope_52, _10, tmp161
	str	d31, [sp, 64]	// slope_52, slope
// Development/CritterProduct/Pilot/Computation/critter_computation.c:28:     intercept = summary->latest_temperature_c - slope * summary->last_timestamp_s;
	ldr	x0, [sp, 24]	// tmp162, summary
	ldr	d30, [x0, 128]	// _11, summary_42(D)->latest_temperature_c
// Development/CritterProduct/Pilot/Computation/critter_computation.c:28:     intercept = summary->latest_temperature_c - slope * summary->last_timestamp_s;
	ldr	x0, [sp, 24]	// tmp163, summary
	ldr	d29, [x0, 104]	// _12, summary_42(D)->last_timestamp_s
// Development/CritterProduct/Pilot/Computation/critter_computation.c:28:     intercept = summary->latest_temperature_c - slope * summary->last_timestamp_s;
	ldr	d31, [sp, 64]	// tmp164, slope
	fmul	d31, d29, d31	// _13, _12, tmp164
// Development/CritterProduct/Pilot/Computation/critter_computation.c:28:     intercept = summary->latest_temperature_c - slope * summary->last_timestamp_s;
	fsub	d31, d30, d31	// intercept_53, _11, _13
	str	d31, [sp, 56]	// intercept_53, intercept
// Development/CritterProduct/Pilot/Computation/critter_computation.c:29:     recent_delta_c = summary->latest_temperature_c - summary->min_temperature_c;
	ldr	x0, [sp, 24]	// tmp166, summary
	ldr	d30, [x0, 128]	// _14, summary_42(D)->latest_temperature_c
// Development/CritterProduct/Pilot/Computation/critter_computation.c:29:     recent_delta_c = summary->latest_temperature_c - summary->min_temperature_c;
	ldr	x0, [sp, 24]	// tmp167, summary
	ldr	d31, [x0, 56]	// _15, summary_42(D)->min_temperature_c
// Development/CritterProduct/Pilot/Computation/critter_computation.c:29:     recent_delta_c = summary->latest_temperature_c - summary->min_temperature_c;
	fsub	d31, d30, d31	// recent_delta_c_54, _14, _15
	str	d31, [sp, 48]	// recent_delta_c_54, recent_delta_c
// Development/CritterProduct/Pilot/Computation/critter_computation.c:30:     variance = summary->stddev_temperature_c * summary->stddev_temperature_c;
	ldr	x0, [sp, 24]	// tmp169, summary
	ldr	d30, [x0, 88]	// _16, summary_42(D)->stddev_temperature_c
// Development/CritterProduct/Pilot/Computation/critter_computation.c:30:     variance = summary->stddev_temperature_c * summary->stddev_temperature_c;
	ldr	x0, [sp, 24]	// tmp170, summary
	ldr	d31, [x0, 88]	// _17, summary_42(D)->stddev_temperature_c
// Development/CritterProduct/Pilot/Computation/critter_computation.c:30:     variance = summary->stddev_temperature_c * summary->stddev_temperature_c;
	fmul	d31, d30, d31	// variance_55, _16, _17
	str	d31, [sp, 40]	// variance_55, variance
// Development/CritterProduct/Pilot/Computation/critter_computation.c:32:     result->trend_c_per_s = slope;
	ldr	x0, [sp, 8]	// tmp172, result
	ldr	d31, [sp, 64]	// tmp173, slope
	str	d31, [x0, 8]	// tmp173, result_43(D)->trend_c_per_s
// Development/CritterProduct/Pilot/Computation/critter_computation.c:33:     result->rate_of_change_c_per_s = slope;
	ldr	x0, [sp, 8]	// tmp174, result
	ldr	d31, [sp, 64]	// tmp175, slope
	str	d31, [x0, 16]	// tmp175, result_43(D)->rate_of_change_c_per_s
// Development/CritterProduct/Pilot/Computation/critter_computation.c:34:     result->slope_c_per_s = slope;
	ldr	x0, [sp, 8]	// tmp176, result
	ldr	d31, [sp, 64]	// tmp177, slope
	str	d31, [x0, 48]	// tmp177, result_43(D)->slope_c_per_s
// Development/CritterProduct/Pilot/Computation/critter_computation.c:35:     result->intercept_c = intercept;
	ldr	x0, [sp, 8]	// tmp178, result
	ldr	d31, [sp, 56]	// tmp179, intercept
	str	d31, [x0, 56]	// tmp179, result_43(D)->intercept_c
// Development/CritterProduct/Pilot/Computation/critter_computation.c:36:     result->variance_c = variance;
	ldr	x0, [sp, 8]	// tmp180, result
	ldr	d31, [sp, 40]	// tmp181, variance
	str	d31, [x0, 64]	// tmp181, result_43(D)->variance_c
// Development/CritterProduct/Pilot/Computation/critter_computation.c:37:     result->recent_delta_c = recent_delta_c;
	ldr	x0, [sp, 8]	// tmp182, result
	ldr	d31, [sp, 48]	// tmp183, recent_delta_c
	str	d31, [x0, 72]	// tmp183, result_43(D)->recent_delta_c
// Development/CritterProduct/Pilot/Computation/critter_computation.c:38:     result->predicted_temperature_c = summary->latest_temperature_c + slope * prediction_horizon_s;
	ldr	x0, [sp, 24]	// tmp184, summary
	ldr	d30, [x0, 128]	// _18, summary_42(D)->latest_temperature_c
// Development/CritterProduct/Pilot/Computation/critter_computation.c:38:     result->predicted_temperature_c = summary->latest_temperature_c + slope * prediction_horizon_s;
	ldr	d29, [sp, 64]	// tmp185, slope
	ldr	d31, [sp, 16]	// tmp186, prediction_horizon_s
	fmul	d31, d29, d31	// _19, tmp185, tmp186
// Development/CritterProduct/Pilot/Computation/critter_computation.c:38:     result->predicted_temperature_c = summary->latest_temperature_c + slope * prediction_horizon_s;
	fadd	d31, d30, d31	// _20, _18, _19
// Development/CritterProduct/Pilot/Computation/critter_computation.c:38:     result->predicted_temperature_c = summary->latest_temperature_c + slope * prediction_horizon_s;
	ldr	x0, [sp, 8]	// tmp187, result
	str	d31, [x0, 24]	// _20, result_43(D)->predicted_temperature_c
// Development/CritterProduct/Pilot/Computation/critter_computation.c:39:     result->stable = fabs(slope) < 0.05 && summary->stddev_temperature_c < 0.5;
	ldr	d31, [sp, 64]	// tmp188, slope
	fabs	d31, d31	// _21, tmp188
// Development/CritterProduct/Pilot/Computation/critter_computation.c:39:     result->stable = fabs(slope) < 0.05 && summary->stddev_temperature_c < 0.5;
	adrp	x0, .LC0	// tmp235,
	ldr	d30, [x0, #:lo12:.LC0]	// tmp189,
	fcmpe	d31, d30	// _21, tmp189
	bmi	.L25		//,
	b	.L8		//
.L25:
// Development/CritterProduct/Pilot/Computation/critter_computation.c:39:     result->stable = fabs(slope) < 0.05 && summary->stddev_temperature_c < 0.5;
	ldr	x0, [sp, 24]	// tmp190, summary
	ldr	d30, [x0, 88]	// _22, summary_42(D)->stddev_temperature_c
// Development/CritterProduct/Pilot/Computation/critter_computation.c:39:     result->stable = fabs(slope) < 0.05 && summary->stddev_temperature_c < 0.5;
	fmov	d31, 5.0e-1	// tmp191,
	fcmpe	d30, d31	// _22, tmp191
	bmi	.L26		//,
	b	.L8		//
.L26:
// Development/CritterProduct/Pilot/Computation/critter_computation.c:39:     result->stable = fabs(slope) < 0.05 && summary->stddev_temperature_c < 0.5;
	mov	w0, 1	// iftmp.0_37,
// Development/CritterProduct/Pilot/Computation/critter_computation.c:39:     result->stable = fabs(slope) < 0.05 && summary->stddev_temperature_c < 0.5;
	b	.L11		//
.L8:
// Development/CritterProduct/Pilot/Computation/critter_computation.c:39:     result->stable = fabs(slope) < 0.05 && summary->stddev_temperature_c < 0.5;
	mov	w0, 0	// iftmp.0_37,
.L11:
// Development/CritterProduct/Pilot/Computation/critter_computation.c:39:     result->stable = fabs(slope) < 0.05 && summary->stddev_temperature_c < 0.5;
	and	w0, w0, 1	// tmp193, tmp192,
	and	w1, w0, 255	// _23, tmp193
// Development/CritterProduct/Pilot/Computation/critter_computation.c:39:     result->stable = fabs(slope) < 0.05 && summary->stddev_temperature_c < 0.5;
	ldr	x0, [sp, 8]	// tmp194, result
	strb	w1, [x0, 80]	// tmp195, result_43(D)->stable
// Development/CritterProduct/Pilot/Computation/critter_computation.c:40:     result->rising = slope > 0.02;
	ldr	d31, [sp, 64]	// tmp197, slope
	adrp	x0, .LC1	// tmp236,
	ldr	d30, [x0, #:lo12:.LC1]	// tmp198,
	fcmpe	d31, d30	// tmp197, tmp198
	cset	w0, gt	// tmp199,
	and	w1, w0, 255	// _24, _24
// Development/CritterProduct/Pilot/Computation/critter_computation.c:40:     result->rising = slope > 0.02;
	ldr	x0, [sp, 8]	// tmp200, result
	strb	w1, [x0, 81]	// tmp201, result_43(D)->rising
// Development/CritterProduct/Pilot/Computation/critter_computation.c:41:     result->falling = slope < -0.02;
	ldr	d31, [sp, 64]	// tmp203, slope
	adrp	x0, .LC2	// tmp237,
	ldr	d30, [x0, #:lo12:.LC2]	// tmp204,
	fcmpe	d31, d30	// tmp203, tmp204
	cset	w0, mi	// tmp205,
	and	w1, w0, 255	// _25, _25
// Development/CritterProduct/Pilot/Computation/critter_computation.c:41:     result->falling = slope < -0.02;
	ldr	x0, [sp, 8]	// tmp206, result
	strb	w1, [x0, 82]	// tmp207, result_43(D)->falling
// Development/CritterProduct/Pilot/Computation/critter_computation.c:42:     result->likely_hvac_active = fabs(slope) > 0.05 || summary->stddev_temperature_c > 0.5;
	ldr	d31, [sp, 64]	// tmp208, slope
	fabs	d31, d31	// _26, tmp208
// Development/CritterProduct/Pilot/Computation/critter_computation.c:42:     result->likely_hvac_active = fabs(slope) > 0.05 || summary->stddev_temperature_c > 0.5;
	adrp	x0, .LC0	// tmp238,
	ldr	d30, [x0, #:lo12:.LC0]	// tmp209,
	fcmpe	d31, d30	// _26, tmp209
	bgt	.L12		//,
// Development/CritterProduct/Pilot/Computation/critter_computation.c:42:     result->likely_hvac_active = fabs(slope) > 0.05 || summary->stddev_temperature_c > 0.5;
	ldr	x0, [sp, 24]	// tmp210, summary
	ldr	d30, [x0, 88]	// _27, summary_42(D)->stddev_temperature_c
// Development/CritterProduct/Pilot/Computation/critter_computation.c:42:     result->likely_hvac_active = fabs(slope) > 0.05 || summary->stddev_temperature_c > 0.5;
	fmov	d31, 5.0e-1	// tmp211,
	fcmpe	d30, d31	// _27, tmp211
	bgt	.L12		//,
	b	.L32		//
.L12:
// Development/CritterProduct/Pilot/Computation/critter_computation.c:42:     result->likely_hvac_active = fabs(slope) > 0.05 || summary->stddev_temperature_c > 0.5;
	mov	w0, 1	// iftmp.1_38,
// Development/CritterProduct/Pilot/Computation/critter_computation.c:42:     result->likely_hvac_active = fabs(slope) > 0.05 || summary->stddev_temperature_c > 0.5;
	b	.L15		//
.L32:
// Development/CritterProduct/Pilot/Computation/critter_computation.c:42:     result->likely_hvac_active = fabs(slope) > 0.05 || summary->stddev_temperature_c > 0.5;
	mov	w0, 0	// iftmp.1_38,
.L15:
// Development/CritterProduct/Pilot/Computation/critter_computation.c:42:     result->likely_hvac_active = fabs(slope) > 0.05 || summary->stddev_temperature_c > 0.5;
	and	w0, w0, 1	// tmp213, tmp212,
	and	w1, w0, 255	// _28, tmp213
// Development/CritterProduct/Pilot/Computation/critter_computation.c:42:     result->likely_hvac_active = fabs(slope) > 0.05 || summary->stddev_temperature_c > 0.5;
	ldr	x0, [sp, 8]	// tmp214, result
	strb	w1, [x0, 83]	// tmp215, result_43(D)->likely_hvac_active
// Development/CritterProduct/Pilot/Computation/critter_computation.c:43:     result->likely_heating = slope > 0.03 && summary->latest_temperature_c > summary->mean_temperature_c;
	ldr	d31, [sp, 64]	// tmp216, slope
	adrp	x0, .LC3	// tmp239,
	ldr	d30, [x0, #:lo12:.LC3]	// tmp217,
	fcmpe	d31, d30	// tmp216, tmp217
	bgt	.L27		//,
	b	.L16		//
.L27:
// Development/CritterProduct/Pilot/Computation/critter_computation.c:43:     result->likely_heating = slope > 0.03 && summary->latest_temperature_c > summary->mean_temperature_c;
	ldr	x0, [sp, 24]	// tmp218, summary
	ldr	d30, [x0, 128]	// _29, summary_42(D)->latest_temperature_c
// Development/CritterProduct/Pilot/Computation/critter_computation.c:43:     result->likely_heating = slope > 0.03 && summary->latest_temperature_c > summary->mean_temperature_c;
	ldr	x0, [sp, 24]	// tmp219, summary
	ldr	d31, [x0, 72]	// _30, summary_42(D)->mean_temperature_c
// Development/CritterProduct/Pilot/Computation/critter_computation.c:43:     result->likely_heating = slope > 0.03 && summary->latest_temperature_c > summary->mean_temperature_c;
	fcmpe	d30, d31	// _29, _30
	bgt	.L28		//,
	b	.L16		//
.L28:
// Development/CritterProduct/Pilot/Computation/critter_computation.c:43:     result->likely_heating = slope > 0.03 && summary->latest_temperature_c > summary->mean_temperature_c;
	mov	w0, 1	// iftmp.2_39,
// Development/CritterProduct/Pilot/Computation/critter_computation.c:43:     result->likely_heating = slope > 0.03 && summary->latest_temperature_c > summary->mean_temperature_c;
	b	.L19		//
.L16:
// Development/CritterProduct/Pilot/Computation/critter_computation.c:43:     result->likely_heating = slope > 0.03 && summary->latest_temperature_c > summary->mean_temperature_c;
	mov	w0, 0	// iftmp.2_39,
.L19:
// Development/CritterProduct/Pilot/Computation/critter_computation.c:43:     result->likely_heating = slope > 0.03 && summary->latest_temperature_c > summary->mean_temperature_c;
	and	w0, w0, 1	// tmp221, tmp220,
	and	w1, w0, 255	// _31, tmp221
// Development/CritterProduct/Pilot/Computation/critter_computation.c:43:     result->likely_heating = slope > 0.03 && summary->latest_temperature_c > summary->mean_temperature_c;
	ldr	x0, [sp, 8]	// tmp222, result
	strb	w1, [x0, 85]	// tmp223, result_43(D)->likely_heating
// Development/CritterProduct/Pilot/Computation/critter_computation.c:44:     result->likely_cooling = slope < -0.03 && summary->latest_temperature_c < summary->mean_temperature_c;
	ldr	d31, [sp, 64]	// tmp224, slope
	adrp	x0, .LC4	// tmp240,
	ldr	d30, [x0, #:lo12:.LC4]	// tmp225,
	fcmpe	d31, d30	// tmp224, tmp225
	bmi	.L29		//,
	b	.L20		//
.L29:
// Development/CritterProduct/Pilot/Computation/critter_computation.c:44:     result->likely_cooling = slope < -0.03 && summary->latest_temperature_c < summary->mean_temperature_c;
	ldr	x0, [sp, 24]	// tmp226, summary
	ldr	d30, [x0, 128]	// _32, summary_42(D)->latest_temperature_c
// Development/CritterProduct/Pilot/Computation/critter_computation.c:44:     result->likely_cooling = slope < -0.03 && summary->latest_temperature_c < summary->mean_temperature_c;
	ldr	x0, [sp, 24]	// tmp227, summary
	ldr	d31, [x0, 72]	// _33, summary_42(D)->mean_temperature_c
// Development/CritterProduct/Pilot/Computation/critter_computation.c:44:     result->likely_cooling = slope < -0.03 && summary->latest_temperature_c < summary->mean_temperature_c;
	fcmpe	d30, d31	// _32, _33
	bmi	.L30		//,
	b	.L20		//
.L30:
// Development/CritterProduct/Pilot/Computation/critter_computation.c:44:     result->likely_cooling = slope < -0.03 && summary->latest_temperature_c < summary->mean_temperature_c;
	mov	w0, 1	// iftmp.3_40,
// Development/CritterProduct/Pilot/Computation/critter_computation.c:44:     result->likely_cooling = slope < -0.03 && summary->latest_temperature_c < summary->mean_temperature_c;
	b	.L23		//
.L20:
// Development/CritterProduct/Pilot/Computation/critter_computation.c:44:     result->likely_cooling = slope < -0.03 && summary->latest_temperature_c < summary->mean_temperature_c;
	mov	w0, 0	// iftmp.3_40,
.L23:
// Development/CritterProduct/Pilot/Computation/critter_computation.c:44:     result->likely_cooling = slope < -0.03 && summary->latest_temperature_c < summary->mean_temperature_c;
	and	w0, w0, 1	// tmp229, tmp228,
	and	w1, w0, 255	// _34, tmp229
// Development/CritterProduct/Pilot/Computation/critter_computation.c:44:     result->likely_cooling = slope < -0.03 && summary->latest_temperature_c < summary->mean_temperature_c;
	ldr	x0, [sp, 8]	// tmp230, result
	strb	w1, [x0, 84]	// tmp231, result_43(D)->likely_cooling
// Development/CritterProduct/Pilot/Computation/critter_computation.c:46:     return 0;
	mov	w0, 0	// _36,
.L5:
// Development/CritterProduct/Pilot/Computation/critter_computation.c:47: }
	add	sp, sp, 80	//,,
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE0:
	.size	critter_compute_analysis, .-critter_compute_analysis
	.section	.rodata
	.align	3
.LC0:
	.word	-1717986918
	.word	1068079513
	.align	3
.LC1:
	.word	1202590843
	.word	1066695393
	.align	3
.LC2:
	.word	1202590843
	.word	-1080788255
	.align	3
.LC3:
	.word	-343597384
	.word	1067366481
	.align	3
.LC4:
	.word	-343597384
	.word	-1080117167
	.ident	"GCC: (Debian 14.2.0-19) 14.2.0"
	.section	.note.GNU-stack,"",@progbits
