	.arch armv8-a
	.file	"critter_memory.c"
// GNU C11 (Debian 14.2.0-19) version 14.2.0 (aarch64-linux-gnu)
//	compiled by GNU C version 14.2.0, GMP version 6.3.0, MPFR version 4.2.1, MPC version 1.3.1, isl version isl-0.27-GMP

// warning: MPFR header version 4.2.1 differs from library version 4.2.2.
// GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
// options passed: -mlittle-endian -mabi=lp64 -O0 -std=c11 -fasynchronous-unwind-tables
	.text
	.align	2
	.type	critter_is_valid_sample, %function
critter_is_valid_sample:
.LFB0:
	.cfi_startproc
	sub	sp, sp, #16	//,,
	.cfi_def_cfa_offset 16
	str	x0, [sp, 8]	// sample, sample
// Development/CritterProduct/Pilot/Memory/critter_memory.c:9:     if (sample == NULL)
	ldr	x0, [sp, 8]	// tmp118, sample
	cmp	x0, 0	// tmp118,
	bne	.L2		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:10:         return 0;
	mov	w0, 0	// _17,
	b	.L3		//
.L2:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:12:     if (!isfinite(sample->timestamp_s) || sample->timestamp_s <= 0.0)
	ldr	x0, [sp, 8]	// tmp119, sample
	ldr	d31, [x0]	// _1, sample_18(D)->timestamp_s
	fabs	d31, d31	// _2, _1
// Development/CritterProduct/Pilot/Memory/critter_memory.c:12:     if (!isfinite(sample->timestamp_s) || sample->timestamp_s <= 0.0)
	mov	x0, 9218868437227405311	// tmp143,
	fmov	d30, x0	// tmp120, tmp143
	fcmp	d31, d30	// _2, tmp120
	bhi	.L4		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:12:     if (!isfinite(sample->timestamp_s) || sample->timestamp_s <= 0.0)
	ldr	x0, [sp, 8]	// tmp121, sample
	ldr	d31, [x0]	// _3, sample_18(D)->timestamp_s
// Development/CritterProduct/Pilot/Memory/critter_memory.c:12:     if (!isfinite(sample->timestamp_s) || sample->timestamp_s <= 0.0)
	fcmpe	d31, #0.0	// _3
	bls	.L4		//,
	b	.L18		//
.L4:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:13:         return 0;
	mov	w0, 0	// _17,
	b	.L3		//
.L18:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:15:     if (!isfinite(sample->temperature_c))
	ldr	x0, [sp, 8]	// tmp122, sample
	ldr	d31, [x0, 8]	// _4, sample_18(D)->temperature_c
	fabs	d31, d31	// _5, _4
// Development/CritterProduct/Pilot/Memory/critter_memory.c:15:     if (!isfinite(sample->temperature_c))
	mov	x0, 9218868437227405311	// tmp142,
	fmov	d30, x0	// tmp123, tmp142
	fcmp	d31, d30	// _5, tmp123
	bhi	.L17		//,
	b	.L19		//
.L17:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:16:         return 0;
	mov	w0, 0	// _17,
	b	.L3		//
.L19:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:18:     if (sample->source < TEMPERATURE_SOURCE_SENSE_HAT || sample->source > TEMPERATURE_SOURCE_CPU)
	ldr	x0, [sp, 8]	// tmp124, sample
	ldr	w0, [x0, 32]	// _6, sample_18(D)->source
// Development/CritterProduct/Pilot/Memory/critter_memory.c:18:     if (sample->source < TEMPERATURE_SOURCE_SENSE_HAT || sample->source > TEMPERATURE_SOURCE_CPU)
	cmp	w0, 0	// _6,
	beq	.L9		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:18:     if (sample->source < TEMPERATURE_SOURCE_SENSE_HAT || sample->source > TEMPERATURE_SOURCE_CPU)
	ldr	x0, [sp, 8]	// tmp125, sample
	ldr	w0, [x0, 32]	// _7, sample_18(D)->source
// Development/CritterProduct/Pilot/Memory/critter_memory.c:18:     if (sample->source < TEMPERATURE_SOURCE_SENSE_HAT || sample->source > TEMPERATURE_SOURCE_CPU)
	cmp	w0, 3	// _7,
	bls	.L10		//,
.L9:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:19:         return 0;
	mov	w0, 0	// _17,
	b	.L3		//
.L10:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:21:     if (sample->has_humidity && (!isfinite(sample->humidity_percent) || sample->humidity_percent < 0.0 || sample->humidity_percent > 100.0))
	ldr	x0, [sp, 8]	// tmp126, sample
	ldrb	w0, [x0, 36]	// _8, sample_18(D)->has_humidity
// Development/CritterProduct/Pilot/Memory/critter_memory.c:21:     if (sample->has_humidity && (!isfinite(sample->humidity_percent) || sample->humidity_percent < 0.0 || sample->humidity_percent > 100.0))
	and	w0, w0, 1	// tmp127, _8,
	cmp	w0, 0	// tmp127,
	beq	.L11		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:21:     if (sample->has_humidity && (!isfinite(sample->humidity_percent) || sample->humidity_percent < 0.0 || sample->humidity_percent > 100.0))
	ldr	x0, [sp, 8]	// tmp128, sample
	ldr	d31, [x0, 16]	// _9, sample_18(D)->humidity_percent
	fabs	d31, d31	// _10, _9
// Development/CritterProduct/Pilot/Memory/critter_memory.c:21:     if (sample->has_humidity && (!isfinite(sample->humidity_percent) || sample->humidity_percent < 0.0 || sample->humidity_percent > 100.0))
	mov	x0, 9218868437227405311	// tmp141,
	fmov	d30, x0	// tmp129, tmp141
	fcmp	d31, d30	// _10, tmp129
	bhi	.L12		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:21:     if (sample->has_humidity && (!isfinite(sample->humidity_percent) || sample->humidity_percent < 0.0 || sample->humidity_percent > 100.0))
	ldr	x0, [sp, 8]	// tmp130, sample
	ldr	d31, [x0, 16]	// _11, sample_18(D)->humidity_percent
// Development/CritterProduct/Pilot/Memory/critter_memory.c:21:     if (sample->has_humidity && (!isfinite(sample->humidity_percent) || sample->humidity_percent < 0.0 || sample->humidity_percent > 100.0))
	fcmpe	d31, #0.0	// _11
	bmi	.L12		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:21:     if (sample->has_humidity && (!isfinite(sample->humidity_percent) || sample->humidity_percent < 0.0 || sample->humidity_percent > 100.0))
	ldr	x0, [sp, 8]	// tmp131, sample
	ldr	d31, [x0, 16]	// _12, sample_18(D)->humidity_percent
// Development/CritterProduct/Pilot/Memory/critter_memory.c:21:     if (sample->has_humidity && (!isfinite(sample->humidity_percent) || sample->humidity_percent < 0.0 || sample->humidity_percent > 100.0))
	mov	x0, 4636737291354636288	// tmp140,
	fmov	d30, x0	// tmp132, tmp140
	fcmpe	d31, d30	// _12, tmp132
	bgt	.L12		//,
	b	.L11		//
.L12:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:22:         return 0;
	mov	w0, 0	// _17,
	b	.L3		//
.L11:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:24:     if (sample->has_pressure && (!isfinite(sample->pressure_hpa) || sample->pressure_hpa <= 0.0))
	ldr	x0, [sp, 8]	// tmp133, sample
	ldrb	w0, [x0, 37]	// _13, sample_18(D)->has_pressure
// Development/CritterProduct/Pilot/Memory/critter_memory.c:24:     if (sample->has_pressure && (!isfinite(sample->pressure_hpa) || sample->pressure_hpa <= 0.0))
	and	w0, w0, 1	// tmp134, _13,
	cmp	w0, 0	// tmp134,
	beq	.L14		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:24:     if (sample->has_pressure && (!isfinite(sample->pressure_hpa) || sample->pressure_hpa <= 0.0))
	ldr	x0, [sp, 8]	// tmp135, sample
	ldr	d31, [x0, 24]	// _14, sample_18(D)->pressure_hpa
	fabs	d31, d31	// _15, _14
// Development/CritterProduct/Pilot/Memory/critter_memory.c:24:     if (sample->has_pressure && (!isfinite(sample->pressure_hpa) || sample->pressure_hpa <= 0.0))
	mov	x0, 9218868437227405311	// tmp139,
	fmov	d30, x0	// tmp136, tmp139
	fcmp	d31, d30	// _15, tmp136
	bhi	.L15		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:24:     if (sample->has_pressure && (!isfinite(sample->pressure_hpa) || sample->pressure_hpa <= 0.0))
	ldr	x0, [sp, 8]	// tmp137, sample
	ldr	d31, [x0, 24]	// _16, sample_18(D)->pressure_hpa
// Development/CritterProduct/Pilot/Memory/critter_memory.c:24:     if (sample->has_pressure && (!isfinite(sample->pressure_hpa) || sample->pressure_hpa <= 0.0))
	fcmpe	d31, #0.0	// _16
	bls	.L15		//,
	b	.L14		//
.L15:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:25:         return 0;
	mov	w0, 0	// _17,
	b	.L3		//
.L14:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:27:     return 1;
	mov	w0, 1	// _17,
.L3:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:28: }
	add	sp, sp, 16	//,,
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE0:
	.size	critter_is_valid_sample, .-critter_is_valid_sample
	.align	2
	.type	critter_median, %function
critter_median:
.LFB1:
	.cfi_startproc
	sub	sp, sp, #48	//,,
	.cfi_def_cfa_offset 48
	str	x0, [sp, 8]	// values, values
	str	x1, [sp]	// count, count
// Development/CritterProduct/Pilot/Memory/critter_memory.c:36:     if (count == 0)
	ldr	x0, [sp]	// tmp131, count
	cmp	x0, 0	// tmp131,
	bne	.L21		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:37:         return 0.0;
	movi	d31, #0	// _32
	b	.L22		//
.L21:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:39:     for (i = 0; i < count; ++i)
	str	xzr, [sp, 40]	//, i
// Development/CritterProduct/Pilot/Memory/critter_memory.c:39:     for (i = 0; i < count; ++i)
	b	.L23		//
.L28:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:41:         for (j = i + 1; j < count; ++j)
	ldr	x0, [sp, 40]	// tmp133, i
	add	x0, x0, 1	// j_43, tmp133,
	str	x0, [sp, 32]	// j_43, j
// Development/CritterProduct/Pilot/Memory/critter_memory.c:41:         for (j = i + 1; j < count; ++j)
	b	.L24		//
.L27:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:43:             if (values[j] < values[i])
	ldr	x0, [sp, 32]	// tmp134, j
	lsl	x0, x0, 3	// _1, tmp134,
	ldr	x1, [sp, 8]	// tmp135, values
	add	x0, x1, x0	// _2, tmp135, _1
	ldr	d30, [x0]	// _3, *_2
// Development/CritterProduct/Pilot/Memory/critter_memory.c:43:             if (values[j] < values[i])
	ldr	x0, [sp, 40]	// tmp136, i
	lsl	x0, x0, 3	// _4, tmp136,
	ldr	x1, [sp, 8]	// tmp137, values
	add	x0, x1, x0	// _5, tmp137, _4
	ldr	d31, [x0]	// _6, *_5
// Development/CritterProduct/Pilot/Memory/critter_memory.c:43:             if (values[j] < values[i])
	fcmpe	d30, d31	// _3, _6
	bmi	.L30		//,
	b	.L25		//
.L30:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:45:                 temp = values[i];
	ldr	x0, [sp, 40]	// tmp138, i
	lsl	x0, x0, 3	// _7, tmp138,
	ldr	x1, [sp, 8]	// tmp139, values
	add	x0, x1, x0	// _8, tmp139, _7
// Development/CritterProduct/Pilot/Memory/critter_memory.c:45:                 temp = values[i];
	ldr	d31, [x0]	// tmp140, *_8
	str	d31, [sp, 24]	// tmp140, temp
// Development/CritterProduct/Pilot/Memory/critter_memory.c:46:                 values[i] = values[j];
	ldr	x0, [sp, 32]	// tmp141, j
	lsl	x0, x0, 3	// _9, tmp141,
	ldr	x1, [sp, 8]	// tmp142, values
	add	x1, x1, x0	// _10, tmp142, _9
// Development/CritterProduct/Pilot/Memory/critter_memory.c:46:                 values[i] = values[j];
	ldr	x0, [sp, 40]	// tmp143, i
	lsl	x0, x0, 3	// _11, tmp143,
	ldr	x2, [sp, 8]	// tmp144, values
	add	x0, x2, x0	// _12, tmp144, _11
// Development/CritterProduct/Pilot/Memory/critter_memory.c:46:                 values[i] = values[j];
	ldr	d31, [x1]	// _13, *_10
// Development/CritterProduct/Pilot/Memory/critter_memory.c:46:                 values[i] = values[j];
	str	d31, [x0]	// _13, *_12
// Development/CritterProduct/Pilot/Memory/critter_memory.c:47:                 values[j] = temp;
	ldr	x0, [sp, 32]	// tmp145, j
	lsl	x0, x0, 3	// _14, tmp145,
	ldr	x1, [sp, 8]	// tmp146, values
	add	x0, x1, x0	// _15, tmp146, _14
// Development/CritterProduct/Pilot/Memory/critter_memory.c:47:                 values[j] = temp;
	ldr	d31, [sp, 24]	// tmp147, temp
	str	d31, [x0]	// tmp147, *_15
.L25:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:41:         for (j = i + 1; j < count; ++j)
	ldr	x0, [sp, 32]	// tmp149, j
	add	x0, x0, 1	// j_48, tmp149,
	str	x0, [sp, 32]	// j_48, j
.L24:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:41:         for (j = i + 1; j < count; ++j)
	ldr	x1, [sp, 32]	// tmp150, j
	ldr	x0, [sp]	// tmp151, count
	cmp	x1, x0	// tmp150, tmp151
	bcc	.L27		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:39:     for (i = 0; i < count; ++i)
	ldr	x0, [sp, 40]	// tmp153, i
	add	x0, x0, 1	// i_44, tmp153,
	str	x0, [sp, 40]	// i_44, i
.L23:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:39:     for (i = 0; i < count; ++i)
	ldr	x1, [sp, 40]	// tmp154, i
	ldr	x0, [sp]	// tmp155, count
	cmp	x1, x0	// tmp154, tmp155
	bcc	.L28		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:52:     if (count % 2 == 0)
	ldr	x0, [sp]	// tmp156, count
	and	x0, x0, 1	// _16, tmp156,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:52:     if (count % 2 == 0)
	cmp	x0, 0	// _16,
	bne	.L29		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:53:         return (values[count / 2 - 1] + values[count / 2]) / 2.0;
	ldr	x0, [sp]	// tmp157, count
	lsr	x0, x0, 1	// _17, tmp157,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:53:         return (values[count / 2 - 1] + values[count / 2]) / 2.0;
	lsl	x0, x0, 3	// _18, _17,
	sub	x0, x0, #8	// _19, _18,
	ldr	x1, [sp, 8]	// tmp158, values
	add	x0, x1, x0	// _20, tmp158, _19
	ldr	d30, [x0]	// _21, *_20
// Development/CritterProduct/Pilot/Memory/critter_memory.c:53:         return (values[count / 2 - 1] + values[count / 2]) / 2.0;
	ldr	x0, [sp]	// tmp159, count
	lsr	x0, x0, 1	// _22, tmp159,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:53:         return (values[count / 2 - 1] + values[count / 2]) / 2.0;
	lsl	x0, x0, 3	// _23, _22,
	ldr	x1, [sp, 8]	// tmp160, values
	add	x0, x1, x0	// _24, tmp160, _23
	ldr	d31, [x0]	// _25, *_24
// Development/CritterProduct/Pilot/Memory/critter_memory.c:53:         return (values[count / 2 - 1] + values[count / 2]) / 2.0;
	fadd	d30, d30, d31	// _26, _21, _25
// Development/CritterProduct/Pilot/Memory/critter_memory.c:53:         return (values[count / 2 - 1] + values[count / 2]) / 2.0;
	fmov	d31, 2.0e+0	// tmp161,
	fdiv	d31, d30, d31	// _32, _26, tmp161
	b	.L22		//
.L29:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:55:     return values[count / 2];
	ldr	x0, [sp]	// tmp162, count
	lsr	x0, x0, 1	// _27, tmp162,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:55:     return values[count / 2];
	lsl	x0, x0, 3	// _28, _27,
	ldr	x1, [sp, 8]	// tmp163, values
	add	x0, x1, x0	// _29, tmp163, _28
	ldr	d31, [x0]	// _32, *_29
.L22:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:56: }
	fmov	d0, d31	//, <retval>
	add	sp, sp, 48	//,,
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE1:
	.size	critter_median, .-critter_median
	.align	2
	.type	critter_stddev, %function
critter_stddev:
.LFB2:
	.cfi_startproc
	stp	x29, x30, [sp, -80]!	//,,,
	.cfi_def_cfa_offset 80
	.cfi_offset 29, -80
	.cfi_offset 30, -72
	mov	x29, sp	//,
	str	x0, [sp, 40]	// values, values
	str	x1, [sp, 32]	// count, count
	str	d0, [sp, 24]	// mean, mean
// Development/CritterProduct/Pilot/Memory/critter_memory.c:60:     double variance = 0.0;
	str	xzr, [sp, 72]	//, variance
// Development/CritterProduct/Pilot/Memory/critter_memory.c:63:     if (count == 0)
	ldr	x0, [sp, 32]	// tmp107, count
	cmp	x0, 0	// tmp107,
	bne	.L32		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:64:         return 0.0;
	movi	d31, #0	// _8
	b	.L33		//
.L32:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:66:     for (i = 0; i < count; ++i)
	str	xzr, [sp, 64]	//, i
// Development/CritterProduct/Pilot/Memory/critter_memory.c:66:     for (i = 0; i < count; ++i)
	b	.L34		//
.L35:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:68:         double diff = values[i] - mean;
	ldr	x0, [sp, 64]	// tmp108, i
	lsl	x0, x0, 3	// _1, tmp108,
	ldr	x1, [sp, 40]	// tmp109, values
	add	x0, x1, x0	// _2, tmp109, _1
	ldr	d30, [x0]	// _3, *_2
// Development/CritterProduct/Pilot/Memory/critter_memory.c:68:         double diff = values[i] - mean;
	ldr	d31, [sp, 24]	// tmp111, mean
	fsub	d31, d30, d31	// diff_19, _3, tmp111
	str	d31, [sp, 56]	// diff_19, diff
// Development/CritterProduct/Pilot/Memory/critter_memory.c:69:         variance += diff * diff;
	ldr	d31, [sp, 56]	// tmp112, diff
	fmul	d31, d31, d31	// _4, tmp112, tmp112
// Development/CritterProduct/Pilot/Memory/critter_memory.c:69:         variance += diff * diff;
	ldr	d30, [sp, 72]	// tmp114, variance
	fadd	d31, d30, d31	// variance_20, tmp114, _4
	str	d31, [sp, 72]	// variance_20, variance
// Development/CritterProduct/Pilot/Memory/critter_memory.c:66:     for (i = 0; i < count; ++i)
	ldr	x0, [sp, 64]	// tmp116, i
	add	x0, x0, 1	// i_21, tmp116,
	str	x0, [sp, 64]	// i_21, i
.L34:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:66:     for (i = 0; i < count; ++i)
	ldr	x1, [sp, 64]	// tmp117, i
	ldr	x0, [sp, 32]	// tmp118, count
	cmp	x1, x0	// tmp117, tmp118
	bcc	.L35		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:72:     variance /= (double)count;
	ldr	d31, [sp, 32]	// tmp119, count
	ucvtf	d31, d31	// _5, tmp119
// Development/CritterProduct/Pilot/Memory/critter_memory.c:72:     variance /= (double)count;
	ldr	d30, [sp, 72]	// tmp121, variance
	fdiv	d31, d30, d31	// variance_13, tmp121, _5
	str	d31, [sp, 72]	// variance_13, variance
// Development/CritterProduct/Pilot/Memory/critter_memory.c:73:     return sqrt(variance);
	ldr	d0, [sp, 72]	//, variance
	bl	sqrt		//
	fmov	d31, d0	// _8,
.L33:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:74: }
	fmov	d0, d31	//, <retval>
	ldp	x29, x30, [sp], 80	//,,,
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE2:
	.size	critter_stddev, .-critter_stddev
	.align	2
	.type	critter_add_in_ring, %function
critter_add_in_ring:
.LFB3:
	.cfi_startproc
	sub	sp, sp, #32	//,,
	.cfi_def_cfa_offset 32
	str	x0, [sp, 8]	// memory, memory
	str	x1, [sp]	// sample, sample
// Development/CritterProduct/Pilot/Memory/critter_memory.c:80:     if (memory == NULL || sample == NULL)
	ldr	x0, [sp, 8]	// tmp113, memory
	cmp	x0, 0	// tmp113,
	beq	.L37		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:80:     if (memory == NULL || sample == NULL)
	ldr	x0, [sp]	// tmp114, sample
	cmp	x0, 0	// tmp114,
	bne	.L38		//,
.L37:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:81:         return -1;
	mov	w0, -1	// _12,
	b	.L39		//
.L38:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:83:     index = memory->head;
	ldr	x0, [sp, 8]	// tmp115, memory
	ldr	x0, [x0, 16]	// tmp116, memory_15(D)->head
	str	x0, [sp, 24]	// tmp116, index
// Development/CritterProduct/Pilot/Memory/critter_memory.c:84:     memory->buffer[index] = *sample;
	ldr	x0, [sp, 8]	// tmp117, memory
	ldr	x2, [x0]	// _1, memory_15(D)->buffer
// Development/CritterProduct/Pilot/Memory/critter_memory.c:84:     memory->buffer[index] = *sample;
	ldr	x1, [sp, 24]	// tmp118, index
	mov	x0, x1	// _2, tmp118
	lsl	x0, x0, 2	// _2, _2,
	add	x0, x0, x1	// _2, _2, tmp118
	lsl	x0, x0, 3	// tmp120, _2,
	add	x0, x2, x0	// _3, _1, _2
// Development/CritterProduct/Pilot/Memory/critter_memory.c:84:     memory->buffer[index] = *sample;
	ldr	x1, [sp]	// tmp121, sample
	ldr	q30, [x1]	// tmp124, *sample_16(D)
	ldr	q31, [x1, 16]	// tmp125, *sample_16(D)
	ldr	x1, [x1, 32]	// tmp126, *sample_16(D)
	str	q30, [x0]	// tmp124, *_3
	str	q31, [x0, 16]	// tmp125, *_3
	str	x1, [x0, 32]	// tmp126, *_3
// Development/CritterProduct/Pilot/Memory/critter_memory.c:85:     memory->head = (memory->head + 1U) % memory->capacity;
	ldr	x0, [sp, 8]	// tmp127, memory
	ldr	x0, [x0, 16]	// _4, memory_15(D)->head
// Development/CritterProduct/Pilot/Memory/critter_memory.c:85:     memory->head = (memory->head + 1U) % memory->capacity;
	add	x0, x0, 1	// _5, _4,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:85:     memory->head = (memory->head + 1U) % memory->capacity;
	ldr	x1, [sp, 8]	// tmp128, memory
	ldr	x1, [x1, 8]	// _6, memory_15(D)->capacity
// Development/CritterProduct/Pilot/Memory/critter_memory.c:85:     memory->head = (memory->head + 1U) % memory->capacity;
	udiv	x2, x0, x1	// tmp131, _5, _6
	mul	x1, x2, x1	// tmp132, tmp131, _6
	sub	x1, x0, x1	// _7, _5, tmp132
// Development/CritterProduct/Pilot/Memory/critter_memory.c:85:     memory->head = (memory->head + 1U) % memory->capacity;
	ldr	x0, [sp, 8]	// tmp133, memory
	str	x1, [x0, 16]	// _7, memory_15(D)->head
// Development/CritterProduct/Pilot/Memory/critter_memory.c:87:     if (memory->count < memory->capacity)
	ldr	x0, [sp, 8]	// tmp134, memory
	ldr	x1, [x0, 24]	// _8, memory_15(D)->count
// Development/CritterProduct/Pilot/Memory/critter_memory.c:87:     if (memory->count < memory->capacity)
	ldr	x0, [sp, 8]	// tmp135, memory
	ldr	x0, [x0, 8]	// _9, memory_15(D)->capacity
// Development/CritterProduct/Pilot/Memory/critter_memory.c:87:     if (memory->count < memory->capacity)
	cmp	x1, x0	// _8, _9
	bcs	.L40		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:89:         memory->count += 1U;
	ldr	x0, [sp, 8]	// tmp136, memory
	ldr	x0, [x0, 24]	// _10, memory_15(D)->count
// Development/CritterProduct/Pilot/Memory/critter_memory.c:89:         memory->count += 1U;
	add	x1, x0, 1	// _11, _10,
	ldr	x0, [sp, 8]	// tmp137, memory
	str	x1, [x0, 24]	// _11, memory_15(D)->count
.L40:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:92:     return 0;
	mov	w0, 0	// _12,
.L39:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:93: }
	add	sp, sp, 32	//,,
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE3:
	.size	critter_add_in_ring, .-critter_add_in_ring
	.align	2
	.type	critter_detect_outlier, %function
critter_detect_outlier:
.LFB4:
	.cfi_startproc
	stp	x29, x30, [sp, -96]!	//,,,
	.cfi_def_cfa_offset 96
	.cfi_offset 29, -96
	.cfi_offset 30, -88
	mov	x29, sp	//,
	str	x0, [sp, 24]	// memory, memory
	str	x1, [sp, 16]	// sample, sample
// Development/CritterProduct/Pilot/Memory/critter_memory.c:105:     if (memory == NULL || sample == NULL)
	ldr	x0, [sp, 24]	// tmp126, memory
	cmp	x0, 0	// tmp126,
	beq	.L42		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:105:     if (memory == NULL || sample == NULL)
	ldr	x0, [sp, 16]	// tmp127, sample
	cmp	x0, 0	// tmp127,
	bne	.L43		//,
.L42:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:106:         return 0;
	mov	w0, 0	// _27,
	b	.L44		//
.L43:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:108:     valid_count = memory->count;
	ldr	x0, [sp, 24]	// tmp128, memory
	ldr	x0, [x0, 24]	// tmp129, memory_31(D)->count
	str	x0, [sp, 80]	// tmp129, valid_count
// Development/CritterProduct/Pilot/Memory/critter_memory.c:109:     if (valid_count < 3U)
	ldr	x0, [sp, 80]	// tmp130, valid_count
	cmp	x0, 2	// tmp130,
	bhi	.L45		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:110:         return 0;
	mov	w0, 0	// _27,
	b	.L44		//
.L45:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:112:     window_size = valid_count;
	ldr	x0, [sp, 80]	// tmp131, valid_count
	str	x0, [sp, 72]	// tmp131, window_size
// Development/CritterProduct/Pilot/Memory/critter_memory.c:113:     temperatures = (double *)malloc(sizeof(double) * window_size);
	ldr	x0, [sp, 72]	// tmp132, window_size
	lsl	x0, x0, 3	// _1, tmp132,
	bl	malloc		//
	str	x0, [sp, 64]	// tmp133, temperatures
// Development/CritterProduct/Pilot/Memory/critter_memory.c:114:     if (temperatures == NULL)
	ldr	x0, [sp, 64]	// tmp134, temperatures
	cmp	x0, 0	// tmp134,
	bne	.L46		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:115:         return 0;
	mov	w0, 0	// _27,
	b	.L44		//
.L46:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:117:     for (i = 0; i < window_size; ++i)
	str	xzr, [sp, 88]	//, i
// Development/CritterProduct/Pilot/Memory/critter_memory.c:117:     for (i = 0; i < window_size; ++i)
	b	.L47		//
.L48:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:119:         size_t idx = (memory->head + memory->capacity - window_size + i) % memory->capacity;
	ldr	x0, [sp, 24]	// tmp135, memory
	ldr	x1, [x0, 16]	// _2, memory_31(D)->head
// Development/CritterProduct/Pilot/Memory/critter_memory.c:119:         size_t idx = (memory->head + memory->capacity - window_size + i) % memory->capacity;
	ldr	x0, [sp, 24]	// tmp136, memory
	ldr	x0, [x0, 8]	// _3, memory_31(D)->capacity
// Development/CritterProduct/Pilot/Memory/critter_memory.c:119:         size_t idx = (memory->head + memory->capacity - window_size + i) % memory->capacity;
	add	x1, x1, x0	// _4, _2, _3
// Development/CritterProduct/Pilot/Memory/critter_memory.c:119:         size_t idx = (memory->head + memory->capacity - window_size + i) % memory->capacity;
	ldr	x0, [sp, 72]	// tmp137, window_size
	sub	x1, x1, x0	// _5, _4, tmp137
// Development/CritterProduct/Pilot/Memory/critter_memory.c:119:         size_t idx = (memory->head + memory->capacity - window_size + i) % memory->capacity;
	ldr	x0, [sp, 88]	// tmp138, i
	add	x0, x1, x0	// _6, _5, tmp138
// Development/CritterProduct/Pilot/Memory/critter_memory.c:119:         size_t idx = (memory->head + memory->capacity - window_size + i) % memory->capacity;
	ldr	x1, [sp, 24]	// tmp139, memory
	ldr	x1, [x1, 8]	// _7, memory_31(D)->capacity
// Development/CritterProduct/Pilot/Memory/critter_memory.c:119:         size_t idx = (memory->head + memory->capacity - window_size + i) % memory->capacity;
	udiv	x2, x0, x1	// tmp142, _6, _7
	mul	x1, x2, x1	// tmp143, tmp142, _7
	sub	x0, x0, x1	// idx_51, _6, tmp143
	str	x0, [sp, 32]	// idx_51, idx
// Development/CritterProduct/Pilot/Memory/critter_memory.c:120:         temperatures[i] = memory->buffer[idx].temperature_c;
	ldr	x0, [sp, 24]	// tmp145, memory
	ldr	x2, [x0]	// _8, memory_31(D)->buffer
// Development/CritterProduct/Pilot/Memory/critter_memory.c:120:         temperatures[i] = memory->buffer[idx].temperature_c;
	ldr	x1, [sp, 32]	// tmp146, idx
	mov	x0, x1	// _9, tmp146
	lsl	x0, x0, 2	// _9, _9,
	add	x0, x0, x1	// _9, _9, tmp146
	lsl	x0, x0, 3	// tmp148, _9,
	add	x1, x2, x0	// _10, _8, _9
// Development/CritterProduct/Pilot/Memory/critter_memory.c:120:         temperatures[i] = memory->buffer[idx].temperature_c;
	ldr	x0, [sp, 88]	// tmp149, i
	lsl	x0, x0, 3	// _11, tmp149,
	ldr	x2, [sp, 64]	// tmp150, temperatures
	add	x0, x2, x0	// _12, tmp150, _11
// Development/CritterProduct/Pilot/Memory/critter_memory.c:120:         temperatures[i] = memory->buffer[idx].temperature_c;
	ldr	d31, [x1, 8]	// _13, _10->temperature_c
// Development/CritterProduct/Pilot/Memory/critter_memory.c:120:         temperatures[i] = memory->buffer[idx].temperature_c;
	str	d31, [x0]	// _13, *_12
// Development/CritterProduct/Pilot/Memory/critter_memory.c:117:     for (i = 0; i < window_size; ++i)
	ldr	x0, [sp, 88]	// tmp152, i
	add	x0, x0, 1	// i_53, tmp152,
	str	x0, [sp, 88]	// i_53, i
.L47:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:117:     for (i = 0; i < window_size; ++i)
	ldr	x1, [sp, 88]	// tmp153, i
	ldr	x0, [sp, 72]	// tmp154, window_size
	cmp	x1, x0	// tmp153, tmp154
	bcc	.L48		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:123:     median = critter_median(temperatures, window_size);
	ldr	x1, [sp, 72]	//, window_size
	ldr	x0, [sp, 64]	//, temperatures
	bl	critter_median		//
	str	d0, [sp, 56]	//, median
// Development/CritterProduct/Pilot/Memory/critter_memory.c:124:     for (i = 0; i < window_size; ++i)
	str	xzr, [sp, 88]	//, i
// Development/CritterProduct/Pilot/Memory/critter_memory.c:124:     for (i = 0; i < window_size; ++i)
	b	.L49		//
.L50:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:126:         temperatures[i] = fabs(temperatures[i] - median);
	ldr	x0, [sp, 88]	// tmp155, i
	lsl	x0, x0, 3	// _14, tmp155,
	ldr	x1, [sp, 64]	// tmp156, temperatures
	add	x0, x1, x0	// _15, tmp156, _14
	ldr	d30, [x0]	// _16, *_15
// Development/CritterProduct/Pilot/Memory/critter_memory.c:126:         temperatures[i] = fabs(temperatures[i] - median);
	ldr	d31, [sp, 56]	// tmp157, median
	fsub	d31, d30, d31	// _17, _16, tmp157
// Development/CritterProduct/Pilot/Memory/critter_memory.c:126:         temperatures[i] = fabs(temperatures[i] - median);
	ldr	x0, [sp, 88]	// tmp158, i
	lsl	x0, x0, 3	// _18, tmp158,
	ldr	x1, [sp, 64]	// tmp159, temperatures
	add	x0, x1, x0	// _19, tmp159, _18
// Development/CritterProduct/Pilot/Memory/critter_memory.c:126:         temperatures[i] = fabs(temperatures[i] - median);
	fabs	d31, d31	// _20, _17
// Development/CritterProduct/Pilot/Memory/critter_memory.c:126:         temperatures[i] = fabs(temperatures[i] - median);
	str	d31, [x0]	// _20, *_19
// Development/CritterProduct/Pilot/Memory/critter_memory.c:124:     for (i = 0; i < window_size; ++i)
	ldr	x0, [sp, 88]	// tmp161, i
	add	x0, x0, 1	// i_50, tmp161,
	str	x0, [sp, 88]	// i_50, i
.L49:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:124:     for (i = 0; i < window_size; ++i)
	ldr	x1, [sp, 88]	// tmp162, i
	ldr	x0, [sp, 72]	// tmp163, window_size
	cmp	x1, x0	// tmp162, tmp163
	bcc	.L50		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:128:     mad = critter_median(temperatures, window_size);
	ldr	x1, [sp, 72]	//, window_size
	ldr	x0, [sp, 64]	//, temperatures
	bl	critter_median		//
	str	d0, [sp, 48]	//, mad
// Development/CritterProduct/Pilot/Memory/critter_memory.c:129:     threshold = 3.0 * mad + 0.5;
	ldr	d30, [sp, 48]	// tmp164, mad
	fmov	d31, 3.0e+0	// tmp165,
	fmul	d30, d30, d31	// _21, tmp164, tmp165
// Development/CritterProduct/Pilot/Memory/critter_memory.c:129:     threshold = 3.0 * mad + 0.5;
	fmov	d31, 5.0e-1	// tmp167,
	fadd	d31, d30, d31	// threshold_44, _21, tmp167
	str	d31, [sp, 40]	// threshold_44, threshold
// Development/CritterProduct/Pilot/Memory/critter_memory.c:131:     if (fabs(sample->temperature_c - median) > threshold)
	ldr	x0, [sp, 16]	// tmp168, sample
	ldr	d30, [x0, 8]	// _22, sample_32(D)->temperature_c
// Development/CritterProduct/Pilot/Memory/critter_memory.c:131:     if (fabs(sample->temperature_c - median) > threshold)
	ldr	d31, [sp, 56]	// tmp169, median
	fsub	d31, d30, d31	// _23, _22, tmp169
// Development/CritterProduct/Pilot/Memory/critter_memory.c:131:     if (fabs(sample->temperature_c - median) > threshold)
	fabs	d31, d31	// _24, _23
// Development/CritterProduct/Pilot/Memory/critter_memory.c:131:     if (fabs(sample->temperature_c - median) > threshold)
	ldr	d30, [sp, 40]	// tmp170, threshold
	fcmpe	d30, d31	// tmp170, _24
	bmi	.L53		//,
	b	.L54		//
.L53:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:133:         free(temperatures);
	ldr	x0, [sp, 64]	//, temperatures
	bl	free		//
// Development/CritterProduct/Pilot/Memory/critter_memory.c:134:         return 1;
	mov	w0, 1	// _27,
	b	.L44		//
.L54:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:137:     free(temperatures);
	ldr	x0, [sp, 64]	//, temperatures
	bl	free		//
// Development/CritterProduct/Pilot/Memory/critter_memory.c:138:     return 0;
	mov	w0, 0	// _27,
.L44:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:139: }
	ldp	x29, x30, [sp], 96	//,,,
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE4:
	.size	critter_detect_outlier, .-critter_detect_outlier
	.align	2
	.global	critter_memory_init
	.type	critter_memory_init, %function
critter_memory_init:
.LFB5:
	.cfi_startproc
	stp	x29, x30, [sp, -32]!	//,,,
	.cfi_def_cfa_offset 32
	.cfi_offset 29, -32
	.cfi_offset 30, -24
	mov	x29, sp	//,
	str	x0, [sp, 24]	// memory, memory
	str	x1, [sp, 16]	// capacity, capacity
// Development/CritterProduct/Pilot/Memory/critter_memory.c:143:     if (memory == NULL || capacity == 0U)
	ldr	x0, [sp, 24]	// tmp104, memory
	cmp	x0, 0	// tmp104,
	beq	.L56		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:143:     if (memory == NULL || capacity == 0U)
	ldr	x0, [sp, 16]	// tmp105, capacity
	cmp	x0, 0	// tmp105,
	bne	.L57		//,
.L56:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:144:         return -1;
	mov	w0, -1	// _3,
	b	.L58		//
.L57:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:146:     memset(memory, 0, sizeof(*memory));
	mov	x2, 72	//,
	mov	w1, 0	//,
	ldr	x0, [sp, 24]	//, memory
	bl	memset		//
// Development/CritterProduct/Pilot/Memory/critter_memory.c:147:     memory->capacity = capacity;
	ldr	x0, [sp, 24]	// tmp106, memory
	ldr	x1, [sp, 16]	// tmp107, capacity
	str	x1, [x0, 8]	// tmp107, memory_5(D)->capacity
// Development/CritterProduct/Pilot/Memory/critter_memory.c:148:     memory->buffer = (critter_sample_t *)calloc(capacity, sizeof(critter_sample_t));
	mov	x1, 40	//,
	ldr	x0, [sp, 16]	//, capacity
	bl	calloc		//
	mov	x1, x0	// _1, tmp108
// Development/CritterProduct/Pilot/Memory/critter_memory.c:148:     memory->buffer = (critter_sample_t *)calloc(capacity, sizeof(critter_sample_t));
	ldr	x0, [sp, 24]	// tmp109, memory
	str	x1, [x0]	// _1, memory_5(D)->buffer
// Development/CritterProduct/Pilot/Memory/critter_memory.c:149:     if (memory->buffer == NULL)
	ldr	x0, [sp, 24]	// tmp110, memory
	ldr	x0, [x0]	// _2, memory_5(D)->buffer
// Development/CritterProduct/Pilot/Memory/critter_memory.c:149:     if (memory->buffer == NULL)
	cmp	x0, 0	// _2,
	bne	.L59		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:150:         return -1;
	mov	w0, -1	// _3,
	b	.L58		//
.L59:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:152:     return 0;
	mov	w0, 0	// _3,
.L58:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:153: }
	ldp	x29, x30, [sp], 32	//,,,
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE5:
	.size	critter_memory_init, .-critter_memory_init
	.align	2
	.global	critter_memory_free
	.type	critter_memory_free, %function
critter_memory_free:
.LFB6:
	.cfi_startproc
	stp	x29, x30, [sp, -32]!	//,,,
	.cfi_def_cfa_offset 32
	.cfi_offset 29, -32
	.cfi_offset 30, -24
	mov	x29, sp	//,
	str	x0, [sp, 24]	// memory, memory
// Development/CritterProduct/Pilot/Memory/critter_memory.c:157:     if (memory == NULL)
	ldr	x0, [sp, 24]	// tmp101, memory
	cmp	x0, 0	// tmp101,
	beq	.L63		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:160:     free(memory->buffer);
	ldr	x0, [sp, 24]	// tmp102, memory
	ldr	x0, [x0]	// _1, memory_3(D)->buffer
// Development/CritterProduct/Pilot/Memory/critter_memory.c:160:     free(memory->buffer);
	bl	free		//
// Development/CritterProduct/Pilot/Memory/critter_memory.c:161:     memory->buffer = NULL;
	ldr	x0, [sp, 24]	// tmp103, memory
	str	xzr, [x0]	//, memory_3(D)->buffer
// Development/CritterProduct/Pilot/Memory/critter_memory.c:162:     memory->capacity = 0U;
	ldr	x0, [sp, 24]	// tmp104, memory
	str	xzr, [x0, 8]	//, memory_3(D)->capacity
// Development/CritterProduct/Pilot/Memory/critter_memory.c:163:     memory->head = 0U;
	ldr	x0, [sp, 24]	// tmp105, memory
	str	xzr, [x0, 16]	//, memory_3(D)->head
// Development/CritterProduct/Pilot/Memory/critter_memory.c:164:     memory->count = 0U;
	ldr	x0, [sp, 24]	// tmp106, memory
	str	xzr, [x0, 24]	//, memory_3(D)->count
	b	.L60		//
.L63:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:158:         return;
	nop	
.L60:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:165: }
	ldp	x29, x30, [sp], 32	//,,,
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE6:
	.size	critter_memory_free, .-critter_memory_free
	.align	2
	.global	critter_memory_add_sample
	.type	critter_memory_add_sample, %function
critter_memory_add_sample:
.LFB7:
	.cfi_startproc
	stp	x29, x30, [sp, -48]!	//,,,
	.cfi_def_cfa_offset 48
	.cfi_offset 29, -48
	.cfi_offset 30, -40
	mov	x29, sp	//,
	str	x0, [sp, 24]	// memory, memory
	str	x1, [sp, 16]	// sample, sample
// Development/CritterProduct/Pilot/Memory/critter_memory.c:171:     if (memory == NULL || sample == NULL)
	ldr	x0, [sp, 24]	// tmp113, memory
	cmp	x0, 0	// tmp113,
	beq	.L65		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:171:     if (memory == NULL || sample == NULL)
	ldr	x0, [sp, 16]	// tmp114, sample
	cmp	x0, 0	// tmp114,
	bne	.L66		//,
.L65:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:172:         return -1;
	mov	w0, -1	// _12,
	b	.L67		//
.L66:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:174:     memory->total_received_samples += 1U;
	ldr	x0, [sp, 24]	// tmp115, memory
	ldr	x0, [x0, 32]	// _1, memory_14(D)->total_received_samples
// Development/CritterProduct/Pilot/Memory/critter_memory.c:174:     memory->total_received_samples += 1U;
	add	x1, x0, 1	// _2, _1,
	ldr	x0, [sp, 24]	// tmp116, memory
	str	x1, [x0, 32]	// _2, memory_14(D)->total_received_samples
// Development/CritterProduct/Pilot/Memory/critter_memory.c:176:     if (!critter_is_valid_sample(sample))
	ldr	x0, [sp, 16]	//, sample
	bl	critter_is_valid_sample		//
// Development/CritterProduct/Pilot/Memory/critter_memory.c:176:     if (!critter_is_valid_sample(sample))
	cmp	w0, 0	// _3,
	bne	.L68		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:178:         memory->total_rejected_samples += 1U;
	ldr	x0, [sp, 24]	// tmp117, memory
	ldr	x0, [x0, 48]	// _4, memory_14(D)->total_rejected_samples
// Development/CritterProduct/Pilot/Memory/critter_memory.c:178:         memory->total_rejected_samples += 1U;
	add	x1, x0, 1	// _5, _4,
	ldr	x0, [sp, 24]	// tmp118, memory
	str	x1, [x0, 48]	// _5, memory_14(D)->total_rejected_samples
// Development/CritterProduct/Pilot/Memory/critter_memory.c:179:         return -1;
	mov	w0, -1	// _12,
	b	.L67		//
.L68:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:182:     memory->total_valid_samples += 1U;
	ldr	x0, [sp, 24]	// tmp119, memory
	ldr	x0, [x0, 40]	// _6, memory_14(D)->total_valid_samples
// Development/CritterProduct/Pilot/Memory/critter_memory.c:182:     memory->total_valid_samples += 1U;
	add	x1, x0, 1	// _7, _6,
	ldr	x0, [sp, 24]	// tmp120, memory
	str	x1, [x0, 40]	// _7, memory_14(D)->total_valid_samples
// Development/CritterProduct/Pilot/Memory/critter_memory.c:183:     is_outlier = critter_detect_outlier(memory, sample);
	ldr	x1, [sp, 16]	//, sample
	ldr	x0, [sp, 24]	//, memory
	bl	critter_detect_outlier		//
	str	w0, [sp, 44]	//, is_outlier
// Development/CritterProduct/Pilot/Memory/critter_memory.c:184:     if (is_outlier)
	ldr	w0, [sp, 44]	// tmp121, is_outlier
	cmp	w0, 0	// tmp121,
	beq	.L69		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:186:         memory->total_outliers += 1U;
	ldr	x0, [sp, 24]	// tmp122, memory
	ldr	x0, [x0, 56]	// _8, memory_14(D)->total_outliers
// Development/CritterProduct/Pilot/Memory/critter_memory.c:186:         memory->total_outliers += 1U;
	add	x1, x0, 1	// _9, _8,
	ldr	x0, [sp, 24]	// tmp123, memory
	str	x1, [x0, 56]	// _9, memory_14(D)->total_outliers
// Development/CritterProduct/Pilot/Memory/critter_memory.c:187:         return 0;
	mov	w0, 0	// _12,
	b	.L67		//
.L69:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:190:     if (critter_add_in_ring(memory, sample) != 0)
	ldr	x1, [sp, 16]	//, sample
	ldr	x0, [sp, 24]	//, memory
	bl	critter_add_in_ring		//
// Development/CritterProduct/Pilot/Memory/critter_memory.c:190:     if (critter_add_in_ring(memory, sample) != 0)
	cmp	w0, 0	// _10,
	beq	.L70		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:191:         return -1;
	mov	w0, -1	// _12,
	b	.L67		//
.L70:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:193:     memory->last_timestamp_s = sample->timestamp_s;
	ldr	x0, [sp, 16]	// tmp124, sample
	ldr	d31, [x0]	// _11, sample_15(D)->timestamp_s
// Development/CritterProduct/Pilot/Memory/critter_memory.c:193:     memory->last_timestamp_s = sample->timestamp_s;
	ldr	x0, [sp, 24]	// tmp125, memory
	str	d31, [x0, 64]	// _11, memory_14(D)->last_timestamp_s
// Development/CritterProduct/Pilot/Memory/critter_memory.c:194:     return 0;
	mov	w0, 0	// _12,
.L67:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:195: }
	ldp	x29, x30, [sp], 48	//,,,
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE7:
	.size	critter_memory_add_sample, .-critter_memory_add_sample
	.align	2
	.global	critter_memory_build_summary
	.type	critter_memory_build_summary, %function
critter_memory_build_summary:
.LFB8:
	.cfi_startproc
	stp	x29, x30, [sp, -96]!	//,,,
	.cfi_def_cfa_offset 96
	.cfi_offset 29, -96
	.cfi_offset 30, -88
	mov	x29, sp	//,
	str	x0, [sp, 24]	// memory, memory
	str	x1, [sp, 16]	// summary, summary
// Development/CritterProduct/Pilot/Memory/critter_memory.c:207:     if (memory == NULL || summary == NULL || memory->count == 0U)
	ldr	x0, [sp, 24]	// tmp204, memory
	cmp	x0, 0	// tmp204,
	beq	.L72		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:207:     if (memory == NULL || summary == NULL || memory->count == 0U)
	ldr	x0, [sp, 16]	// tmp205, summary
	cmp	x0, 0	// tmp205,
	beq	.L72		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:207:     if (memory == NULL || summary == NULL || memory->count == 0U)
	ldr	x0, [sp, 24]	// tmp206, memory
	ldr	x0, [x0, 24]	// _1, memory_114(D)->count
// Development/CritterProduct/Pilot/Memory/critter_memory.c:207:     if (memory == NULL || summary == NULL || memory->count == 0U)
	cmp	x0, 0	// _1,
	bne	.L73		//,
.L72:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:208:         return -1;
	mov	w0, -1	// _108,
	b	.L74		//
.L73:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:210:     memset(summary, 0, sizeof(*summary));
	mov	x2, 136	//,
	mov	w1, 0	//,
	ldr	x0, [sp, 16]	//, summary
	bl	memset		//
// Development/CritterProduct/Pilot/Memory/critter_memory.c:211:     count = memory->count;
	ldr	x0, [sp, 24]	// tmp207, memory
	ldr	x0, [x0, 24]	// tmp208, memory_114(D)->count
	str	x0, [sp, 56]	// tmp208, count
// Development/CritterProduct/Pilot/Memory/critter_memory.c:212:     temperatures = (double *)malloc(sizeof(double) * count);
	ldr	x0, [sp, 56]	// tmp209, count
	lsl	x0, x0, 3	// _2, tmp209,
	bl	malloc		//
	str	x0, [sp, 48]	// tmp210, temperatures
// Development/CritterProduct/Pilot/Memory/critter_memory.c:213:     if (temperatures == NULL)
	ldr	x0, [sp, 48]	// tmp211, temperatures
	cmp	x0, 0	// tmp211,
	bne	.L75		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:214:         return -1;
	mov	w0, -1	// _108,
	b	.L74		//
.L75:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:216:     min_temp = memory->buffer[(memory->head + memory->capacity - count) % memory->capacity].temperature_c;
	ldr	x0, [sp, 24]	// tmp212, memory
	ldr	x2, [x0]	// _3, memory_114(D)->buffer
// Development/CritterProduct/Pilot/Memory/critter_memory.c:216:     min_temp = memory->buffer[(memory->head + memory->capacity - count) % memory->capacity].temperature_c;
	ldr	x0, [sp, 24]	// tmp213, memory
	ldr	x1, [x0, 16]	// _4, memory_114(D)->head
// Development/CritterProduct/Pilot/Memory/critter_memory.c:216:     min_temp = memory->buffer[(memory->head + memory->capacity - count) % memory->capacity].temperature_c;
	ldr	x0, [sp, 24]	// tmp214, memory
	ldr	x0, [x0, 8]	// _5, memory_114(D)->capacity
// Development/CritterProduct/Pilot/Memory/critter_memory.c:216:     min_temp = memory->buffer[(memory->head + memory->capacity - count) % memory->capacity].temperature_c;
	add	x1, x1, x0	// _6, _4, _5
// Development/CritterProduct/Pilot/Memory/critter_memory.c:216:     min_temp = memory->buffer[(memory->head + memory->capacity - count) % memory->capacity].temperature_c;
	ldr	x0, [sp, 56]	// tmp215, count
	sub	x0, x1, x0	// _7, _6, tmp215
// Development/CritterProduct/Pilot/Memory/critter_memory.c:216:     min_temp = memory->buffer[(memory->head + memory->capacity - count) % memory->capacity].temperature_c;
	ldr	x1, [sp, 24]	// tmp216, memory
	ldr	x1, [x1, 8]	// _8, memory_114(D)->capacity
// Development/CritterProduct/Pilot/Memory/critter_memory.c:216:     min_temp = memory->buffer[(memory->head + memory->capacity - count) % memory->capacity].temperature_c;
	udiv	x3, x0, x1	// tmp219, _7, _8
	mul	x1, x3, x1	// tmp220, tmp219, _8
	sub	x1, x0, x1	// _9, _7, tmp220
// Development/CritterProduct/Pilot/Memory/critter_memory.c:216:     min_temp = memory->buffer[(memory->head + memory->capacity - count) % memory->capacity].temperature_c;
	mov	x0, x1	// _10, _9
	lsl	x0, x0, 2	// _10, _10,
	add	x0, x0, x1	// _10, _10, _9
	lsl	x0, x0, 3	// tmp222, _10,
	add	x0, x2, x0	// _11, _3, _10
// Development/CritterProduct/Pilot/Memory/critter_memory.c:216:     min_temp = memory->buffer[(memory->head + memory->capacity - count) % memory->capacity].temperature_c;
	ldr	d31, [x0, 8]	// tmp223, _11->temperature_c
	str	d31, [sp, 72]	// tmp223, min_temp
// Development/CritterProduct/Pilot/Memory/critter_memory.c:217:     max_temp = min_temp;
	ldr	d31, [sp, 72]	// tmp224, min_temp
	str	d31, [sp, 64]	// tmp224, max_temp
// Development/CritterProduct/Pilot/Memory/critter_memory.c:218:     mean = 0.0;
	str	xzr, [sp, 80]	//, mean
// Development/CritterProduct/Pilot/Memory/critter_memory.c:219:     summary->first_timestamp_s = memory->buffer[(memory->head + memory->capacity - count) % memory->capacity].timestamp_s;
	ldr	x0, [sp, 24]	// tmp225, memory
	ldr	x2, [x0]	// _12, memory_114(D)->buffer
// Development/CritterProduct/Pilot/Memory/critter_memory.c:219:     summary->first_timestamp_s = memory->buffer[(memory->head + memory->capacity - count) % memory->capacity].timestamp_s;
	ldr	x0, [sp, 24]	// tmp226, memory
	ldr	x1, [x0, 16]	// _13, memory_114(D)->head
// Development/CritterProduct/Pilot/Memory/critter_memory.c:219:     summary->first_timestamp_s = memory->buffer[(memory->head + memory->capacity - count) % memory->capacity].timestamp_s;
	ldr	x0, [sp, 24]	// tmp227, memory
	ldr	x0, [x0, 8]	// _14, memory_114(D)->capacity
// Development/CritterProduct/Pilot/Memory/critter_memory.c:219:     summary->first_timestamp_s = memory->buffer[(memory->head + memory->capacity - count) % memory->capacity].timestamp_s;
	add	x1, x1, x0	// _15, _13, _14
// Development/CritterProduct/Pilot/Memory/critter_memory.c:219:     summary->first_timestamp_s = memory->buffer[(memory->head + memory->capacity - count) % memory->capacity].timestamp_s;
	ldr	x0, [sp, 56]	// tmp228, count
	sub	x0, x1, x0	// _16, _15, tmp228
// Development/CritterProduct/Pilot/Memory/critter_memory.c:219:     summary->first_timestamp_s = memory->buffer[(memory->head + memory->capacity - count) % memory->capacity].timestamp_s;
	ldr	x1, [sp, 24]	// tmp229, memory
	ldr	x1, [x1, 8]	// _17, memory_114(D)->capacity
// Development/CritterProduct/Pilot/Memory/critter_memory.c:219:     summary->first_timestamp_s = memory->buffer[(memory->head + memory->capacity - count) % memory->capacity].timestamp_s;
	udiv	x3, x0, x1	// tmp232, _16, _17
	mul	x1, x3, x1	// tmp233, tmp232, _17
	sub	x1, x0, x1	// _18, _16, tmp233
// Development/CritterProduct/Pilot/Memory/critter_memory.c:219:     summary->first_timestamp_s = memory->buffer[(memory->head + memory->capacity - count) % memory->capacity].timestamp_s;
	mov	x0, x1	// _19, _18
	lsl	x0, x0, 2	// _19, _19,
	add	x0, x0, x1	// _19, _19, _18
	lsl	x0, x0, 3	// tmp235, _19,
	add	x0, x2, x0	// _20, _12, _19
// Development/CritterProduct/Pilot/Memory/critter_memory.c:219:     summary->first_timestamp_s = memory->buffer[(memory->head + memory->capacity - count) % memory->capacity].timestamp_s;
	ldr	d31, [x0]	// _21, _20->timestamp_s
// Development/CritterProduct/Pilot/Memory/critter_memory.c:219:     summary->first_timestamp_s = memory->buffer[(memory->head + memory->capacity - count) % memory->capacity].timestamp_s;
	ldr	x0, [sp, 16]	// tmp236, summary
	str	d31, [x0, 96]	// _21, summary_115(D)->first_timestamp_s
// Development/CritterProduct/Pilot/Memory/critter_memory.c:220:     summary->last_timestamp_s = memory->buffer[(memory->head + memory->capacity - 1U) % memory->capacity].timestamp_s;
	ldr	x0, [sp, 24]	// tmp237, memory
	ldr	x2, [x0]	// _22, memory_114(D)->buffer
// Development/CritterProduct/Pilot/Memory/critter_memory.c:220:     summary->last_timestamp_s = memory->buffer[(memory->head + memory->capacity - 1U) % memory->capacity].timestamp_s;
	ldr	x0, [sp, 24]	// tmp238, memory
	ldr	x1, [x0, 16]	// _23, memory_114(D)->head
// Development/CritterProduct/Pilot/Memory/critter_memory.c:220:     summary->last_timestamp_s = memory->buffer[(memory->head + memory->capacity - 1U) % memory->capacity].timestamp_s;
	ldr	x0, [sp, 24]	// tmp239, memory
	ldr	x0, [x0, 8]	// _24, memory_114(D)->capacity
// Development/CritterProduct/Pilot/Memory/critter_memory.c:220:     summary->last_timestamp_s = memory->buffer[(memory->head + memory->capacity - 1U) % memory->capacity].timestamp_s;
	add	x0, x1, x0	// _25, _23, _24
// Development/CritterProduct/Pilot/Memory/critter_memory.c:220:     summary->last_timestamp_s = memory->buffer[(memory->head + memory->capacity - 1U) % memory->capacity].timestamp_s;
	sub	x0, x0, #1	// _26, _25,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:220:     summary->last_timestamp_s = memory->buffer[(memory->head + memory->capacity - 1U) % memory->capacity].timestamp_s;
	ldr	x1, [sp, 24]	// tmp240, memory
	ldr	x1, [x1, 8]	// _27, memory_114(D)->capacity
// Development/CritterProduct/Pilot/Memory/critter_memory.c:220:     summary->last_timestamp_s = memory->buffer[(memory->head + memory->capacity - 1U) % memory->capacity].timestamp_s;
	udiv	x3, x0, x1	// tmp243, _26, _27
	mul	x1, x3, x1	// tmp244, tmp243, _27
	sub	x1, x0, x1	// _28, _26, tmp244
// Development/CritterProduct/Pilot/Memory/critter_memory.c:220:     summary->last_timestamp_s = memory->buffer[(memory->head + memory->capacity - 1U) % memory->capacity].timestamp_s;
	mov	x0, x1	// _29, _28
	lsl	x0, x0, 2	// _29, _29,
	add	x0, x0, x1	// _29, _29, _28
	lsl	x0, x0, 3	// tmp246, _29,
	add	x0, x2, x0	// _30, _22, _29
// Development/CritterProduct/Pilot/Memory/critter_memory.c:220:     summary->last_timestamp_s = memory->buffer[(memory->head + memory->capacity - 1U) % memory->capacity].timestamp_s;
	ldr	d31, [x0]	// _31, _30->timestamp_s
// Development/CritterProduct/Pilot/Memory/critter_memory.c:220:     summary->last_timestamp_s = memory->buffer[(memory->head + memory->capacity - 1U) % memory->capacity].timestamp_s;
	ldr	x0, [sp, 16]	// tmp247, summary
	str	d31, [x0, 104]	// _31, summary_115(D)->last_timestamp_s
// Development/CritterProduct/Pilot/Memory/critter_memory.c:221:     summary->source = TEMPERATURE_SOURCE_UNKNOWN;
	ldr	x0, [sp, 16]	// tmp248, summary
	str	wzr, [x0, 120]	//, summary_115(D)->source
// Development/CritterProduct/Pilot/Memory/critter_memory.c:222:     summary->sample_count = count;
	ldr	x0, [sp, 16]	// tmp249, summary
	ldr	x1, [sp, 56]	// tmp250, count
	str	x1, [x0]	// tmp250, summary_115(D)->sample_count
// Development/CritterProduct/Pilot/Memory/critter_memory.c:223:     summary->valid_sample_count = count;
	ldr	x0, [sp, 16]	// tmp251, summary
	ldr	x1, [sp, 56]	// tmp252, count
	str	x1, [x0, 8]	// tmp252, summary_115(D)->valid_sample_count
// Development/CritterProduct/Pilot/Memory/critter_memory.c:224:     summary->outlier_count = memory->total_outliers;
	ldr	x0, [sp, 24]	// tmp253, memory
	ldr	x1, [x0, 56]	// _32, memory_114(D)->total_outliers
// Development/CritterProduct/Pilot/Memory/critter_memory.c:224:     summary->outlier_count = memory->total_outliers;
	ldr	x0, [sp, 16]	// tmp254, summary
	str	x1, [x0, 16]	// _32, summary_115(D)->outlier_count
// Development/CritterProduct/Pilot/Memory/critter_memory.c:226:     for (i = 0; i < count; ++i)
	str	xzr, [sp, 88]	//, i
// Development/CritterProduct/Pilot/Memory/critter_memory.c:226:     for (i = 0; i < count; ++i)
	b	.L76		//
.L84:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:228:         index = (memory->head + memory->capacity - count + i) % memory->capacity;
	ldr	x0, [sp, 24]	// tmp255, memory
	ldr	x1, [x0, 16]	// _33, memory_114(D)->head
// Development/CritterProduct/Pilot/Memory/critter_memory.c:228:         index = (memory->head + memory->capacity - count + i) % memory->capacity;
	ldr	x0, [sp, 24]	// tmp256, memory
	ldr	x0, [x0, 8]	// _34, memory_114(D)->capacity
// Development/CritterProduct/Pilot/Memory/critter_memory.c:228:         index = (memory->head + memory->capacity - count + i) % memory->capacity;
	add	x1, x1, x0	// _35, _33, _34
// Development/CritterProduct/Pilot/Memory/critter_memory.c:228:         index = (memory->head + memory->capacity - count + i) % memory->capacity;
	ldr	x0, [sp, 56]	// tmp257, count
	sub	x1, x1, x0	// _36, _35, tmp257
// Development/CritterProduct/Pilot/Memory/critter_memory.c:228:         index = (memory->head + memory->capacity - count + i) % memory->capacity;
	ldr	x0, [sp, 88]	// tmp258, i
	add	x0, x1, x0	// _37, _36, tmp258
// Development/CritterProduct/Pilot/Memory/critter_memory.c:228:         index = (memory->head + memory->capacity - count + i) % memory->capacity;
	ldr	x1, [sp, 24]	// tmp259, memory
	ldr	x1, [x1, 8]	// _38, memory_114(D)->capacity
// Development/CritterProduct/Pilot/Memory/critter_memory.c:228:         index = (memory->head + memory->capacity - count + i) % memory->capacity;
	udiv	x2, x0, x1	// tmp262, _37, _38
	mul	x1, x2, x1	// tmp263, tmp262, _38
	sub	x0, x0, x1	// index_145, _37, tmp263
	str	x0, [sp, 40]	// index_145, index
// Development/CritterProduct/Pilot/Memory/critter_memory.c:229:         temperatures[i] = memory->buffer[index].temperature_c;
	ldr	x0, [sp, 24]	// tmp265, memory
	ldr	x2, [x0]	// _39, memory_114(D)->buffer
// Development/CritterProduct/Pilot/Memory/critter_memory.c:229:         temperatures[i] = memory->buffer[index].temperature_c;
	ldr	x1, [sp, 40]	// tmp266, index
	mov	x0, x1	// _40, tmp266
	lsl	x0, x0, 2	// _40, _40,
	add	x0, x0, x1	// _40, _40, tmp266
	lsl	x0, x0, 3	// tmp268, _40,
	add	x1, x2, x0	// _41, _39, _40
// Development/CritterProduct/Pilot/Memory/critter_memory.c:229:         temperatures[i] = memory->buffer[index].temperature_c;
	ldr	x0, [sp, 88]	// tmp269, i
	lsl	x0, x0, 3	// _42, tmp269,
	ldr	x2, [sp, 48]	// tmp270, temperatures
	add	x0, x2, x0	// _43, tmp270, _42
// Development/CritterProduct/Pilot/Memory/critter_memory.c:229:         temperatures[i] = memory->buffer[index].temperature_c;
	ldr	d31, [x1, 8]	// _44, _41->temperature_c
// Development/CritterProduct/Pilot/Memory/critter_memory.c:229:         temperatures[i] = memory->buffer[index].temperature_c;
	str	d31, [x0]	// _44, *_43
// Development/CritterProduct/Pilot/Memory/critter_memory.c:230:         mean += temperatures[i];
	ldr	x0, [sp, 88]	// tmp271, i
	lsl	x0, x0, 3	// _45, tmp271,
	ldr	x1, [sp, 48]	// tmp272, temperatures
	add	x0, x1, x0	// _46, tmp272, _45
	ldr	d31, [x0]	// _47, *_46
// Development/CritterProduct/Pilot/Memory/critter_memory.c:230:         mean += temperatures[i];
	ldr	d30, [sp, 80]	// tmp274, mean
	fadd	d31, d30, d31	// mean_147, tmp274, _47
	str	d31, [sp, 80]	// mean_147, mean
// Development/CritterProduct/Pilot/Memory/critter_memory.c:231:         if (temperatures[i] < min_temp)
	ldr	x0, [sp, 88]	// tmp275, i
	lsl	x0, x0, 3	// _48, tmp275,
	ldr	x1, [sp, 48]	// tmp276, temperatures
	add	x0, x1, x0	// _49, tmp276, _48
	ldr	d31, [x0]	// _50, *_49
// Development/CritterProduct/Pilot/Memory/critter_memory.c:231:         if (temperatures[i] < min_temp)
	ldr	d30, [sp, 72]	// tmp277, min_temp
	fcmpe	d30, d31	// tmp277, _50
	bgt	.L87		//,
	b	.L77		//
.L87:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:232:             min_temp = temperatures[i];
	ldr	x0, [sp, 88]	// tmp278, i
	lsl	x0, x0, 3	// _51, tmp278,
	ldr	x1, [sp, 48]	// tmp279, temperatures
	add	x0, x1, x0	// _52, tmp279, _51
// Development/CritterProduct/Pilot/Memory/critter_memory.c:232:             min_temp = temperatures[i];
	ldr	d31, [x0]	// tmp280, *_52
	str	d31, [sp, 72]	// tmp280, min_temp
.L77:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:233:         if (temperatures[i] > max_temp)
	ldr	x0, [sp, 88]	// tmp281, i
	lsl	x0, x0, 3	// _53, tmp281,
	ldr	x1, [sp, 48]	// tmp282, temperatures
	add	x0, x1, x0	// _54, tmp282, _53
	ldr	d31, [x0]	// _55, *_54
// Development/CritterProduct/Pilot/Memory/critter_memory.c:233:         if (temperatures[i] > max_temp)
	ldr	d30, [sp, 64]	// tmp283, max_temp
	fcmpe	d30, d31	// tmp283, _55
	bmi	.L88		//,
	b	.L79		//
.L88:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:234:             max_temp = temperatures[i];
	ldr	x0, [sp, 88]	// tmp284, i
	lsl	x0, x0, 3	// _56, tmp284,
	ldr	x1, [sp, 48]	// tmp285, temperatures
	add	x0, x1, x0	// _57, tmp285, _56
// Development/CritterProduct/Pilot/Memory/critter_memory.c:234:             max_temp = temperatures[i];
	ldr	d31, [x0]	// tmp286, *_57
	str	d31, [sp, 64]	// tmp286, max_temp
.L79:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:236:         if (memory->buffer[index].source >= TEMPERATURE_SOURCE_SENSE_HAT &&
	ldr	x0, [sp, 24]	// tmp287, memory
	ldr	x2, [x0]	// _58, memory_114(D)->buffer
// Development/CritterProduct/Pilot/Memory/critter_memory.c:236:         if (memory->buffer[index].source >= TEMPERATURE_SOURCE_SENSE_HAT &&
	ldr	x1, [sp, 40]	// tmp288, index
	mov	x0, x1	// _59, tmp288
	lsl	x0, x0, 2	// _59, _59,
	add	x0, x0, x1	// _59, _59, tmp288
	lsl	x0, x0, 3	// tmp290, _59,
	add	x0, x2, x0	// _60, _58, _59
// Development/CritterProduct/Pilot/Memory/critter_memory.c:236:         if (memory->buffer[index].source >= TEMPERATURE_SOURCE_SENSE_HAT &&
	ldr	w0, [x0, 32]	// _61, _60->source
// Development/CritterProduct/Pilot/Memory/critter_memory.c:236:         if (memory->buffer[index].source >= TEMPERATURE_SOURCE_SENSE_HAT &&
	cmp	w0, 0	// _61,
	beq	.L81		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:237:             memory->buffer[index].source <= TEMPERATURE_SOURCE_CPU)
	ldr	x0, [sp, 24]	// tmp291, memory
	ldr	x2, [x0]	// _62, memory_114(D)->buffer
// Development/CritterProduct/Pilot/Memory/critter_memory.c:237:             memory->buffer[index].source <= TEMPERATURE_SOURCE_CPU)
	ldr	x1, [sp, 40]	// tmp292, index
	mov	x0, x1	// _63, tmp292
	lsl	x0, x0, 2	// _63, _63,
	add	x0, x0, x1	// _63, _63, tmp292
	lsl	x0, x0, 3	// tmp294, _63,
	add	x0, x2, x0	// _64, _62, _63
// Development/CritterProduct/Pilot/Memory/critter_memory.c:237:             memory->buffer[index].source <= TEMPERATURE_SOURCE_CPU)
	ldr	w0, [x0, 32]	// _65, _64->source
// Development/CritterProduct/Pilot/Memory/critter_memory.c:236:         if (memory->buffer[index].source >= TEMPERATURE_SOURCE_SENSE_HAT &&
	cmp	w0, 3	// _65,
	bhi	.L81		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:239:             summary->sample_count_by_source[memory->buffer[index].source] += 1U;
	ldr	x0, [sp, 24]	// tmp295, memory
	ldr	x2, [x0]	// _66, memory_114(D)->buffer
// Development/CritterProduct/Pilot/Memory/critter_memory.c:239:             summary->sample_count_by_source[memory->buffer[index].source] += 1U;
	ldr	x1, [sp, 40]	// tmp296, index
	mov	x0, x1	// _67, tmp296
	lsl	x0, x0, 2	// _67, _67,
	add	x0, x0, x1	// _67, _67, tmp296
	lsl	x0, x0, 3	// tmp298, _67,
	add	x0, x2, x0	// _68, _66, _67
// Development/CritterProduct/Pilot/Memory/critter_memory.c:239:             summary->sample_count_by_source[memory->buffer[index].source] += 1U;
	ldr	w0, [x0, 32]	// _69, _68->source
// Development/CritterProduct/Pilot/Memory/critter_memory.c:239:             summary->sample_count_by_source[memory->buffer[index].source] += 1U;
	ldr	x1, [sp, 16]	// tmp299, summary
	uxtw	x0, w0	// tmp300, _69
	add	x0, x0, 2	// tmp301, tmp300,
	lsl	x0, x0, 3	// tmp302, tmp301,
	add	x0, x1, x0	// tmp303, tmp299, tmp302
	ldr	x2, [x0, 8]	// _70, summary_115(D)->sample_count_by_source[_69]
// Development/CritterProduct/Pilot/Memory/critter_memory.c:239:             summary->sample_count_by_source[memory->buffer[index].source] += 1U;
	ldr	x0, [sp, 24]	// tmp304, memory
	ldr	x3, [x0]	// _71, memory_114(D)->buffer
// Development/CritterProduct/Pilot/Memory/critter_memory.c:239:             summary->sample_count_by_source[memory->buffer[index].source] += 1U;
	ldr	x1, [sp, 40]	// tmp305, index
	mov	x0, x1	// _72, tmp305
	lsl	x0, x0, 2	// _72, _72,
	add	x0, x0, x1	// _72, _72, tmp305
	lsl	x0, x0, 3	// tmp307, _72,
	add	x0, x3, x0	// _73, _71, _72
// Development/CritterProduct/Pilot/Memory/critter_memory.c:239:             summary->sample_count_by_source[memory->buffer[index].source] += 1U;
	ldr	w0, [x0, 32]	// _74, _73->source
// Development/CritterProduct/Pilot/Memory/critter_memory.c:239:             summary->sample_count_by_source[memory->buffer[index].source] += 1U;
	add	x2, x2, 1	// _75, _70,
	ldr	x1, [sp, 16]	// tmp308, summary
	uxtw	x0, w0	// tmp309, _74
	add	x0, x0, 2	// tmp310, tmp309,
	lsl	x0, x0, 3	// tmp311, tmp310,
	add	x0, x1, x0	// tmp312, tmp308, tmp311
	str	x2, [x0, 8]	// _75, summary_115(D)->sample_count_by_source[_74]
.L81:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:242:         if (summary->source == TEMPERATURE_SOURCE_UNKNOWN)
	ldr	x0, [sp, 16]	// tmp313, summary
	ldr	w0, [x0, 120]	// _76, summary_115(D)->source
// Development/CritterProduct/Pilot/Memory/critter_memory.c:242:         if (summary->source == TEMPERATURE_SOURCE_UNKNOWN)
	cmp	w0, 0	// _76,
	bne	.L82		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:243:             summary->source = memory->buffer[index].source;
	ldr	x0, [sp, 24]	// tmp314, memory
	ldr	x2, [x0]	// _77, memory_114(D)->buffer
// Development/CritterProduct/Pilot/Memory/critter_memory.c:243:             summary->source = memory->buffer[index].source;
	ldr	x1, [sp, 40]	// tmp315, index
	mov	x0, x1	// _78, tmp315
	lsl	x0, x0, 2	// _78, _78,
	add	x0, x0, x1	// _78, _78, tmp315
	lsl	x0, x0, 3	// tmp317, _78,
	add	x0, x2, x0	// _79, _77, _78
// Development/CritterProduct/Pilot/Memory/critter_memory.c:243:             summary->source = memory->buffer[index].source;
	ldr	w1, [x0, 32]	// _80, _79->source
// Development/CritterProduct/Pilot/Memory/critter_memory.c:243:             summary->source = memory->buffer[index].source;
	ldr	x0, [sp, 16]	// tmp318, summary
	str	w1, [x0, 120]	// _80, summary_115(D)->source
	b	.L83		//
.L82:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:244:         else if (summary->source != memory->buffer[index].source)
	ldr	x0, [sp, 16]	// tmp319, summary
	ldr	w2, [x0, 120]	// _81, summary_115(D)->source
// Development/CritterProduct/Pilot/Memory/critter_memory.c:244:         else if (summary->source != memory->buffer[index].source)
	ldr	x0, [sp, 24]	// tmp320, memory
	ldr	x3, [x0]	// _82, memory_114(D)->buffer
// Development/CritterProduct/Pilot/Memory/critter_memory.c:244:         else if (summary->source != memory->buffer[index].source)
	ldr	x1, [sp, 40]	// tmp321, index
	mov	x0, x1	// _83, tmp321
	lsl	x0, x0, 2	// _83, _83,
	add	x0, x0, x1	// _83, _83, tmp321
	lsl	x0, x0, 3	// tmp323, _83,
	add	x0, x3, x0	// _84, _82, _83
// Development/CritterProduct/Pilot/Memory/critter_memory.c:244:         else if (summary->source != memory->buffer[index].source)
	ldr	w0, [x0, 32]	// _85, _84->source
// Development/CritterProduct/Pilot/Memory/critter_memory.c:244:         else if (summary->source != memory->buffer[index].source)
	cmp	w2, w0	// _81, _85
	beq	.L83		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:245:             summary->source = TEMPERATURE_SOURCE_UNKNOWN;
	ldr	x0, [sp, 16]	// tmp324, summary
	str	wzr, [x0, 120]	//, summary_115(D)->source
.L83:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:226:     for (i = 0; i < count; ++i)
	ldr	x0, [sp, 88]	// tmp326, i
	add	x0, x0, 1	// i_153, tmp326,
	str	x0, [sp, 88]	// i_153, i
.L76:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:226:     for (i = 0; i < count; ++i)
	ldr	x1, [sp, 88]	// tmp327, i
	ldr	x0, [sp, 56]	// tmp328, count
	cmp	x1, x0	// tmp327, tmp328
	bcc	.L84		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:248:     mean /= (double)count;
	ldr	d31, [sp, 56]	// tmp329, count
	ucvtf	d31, d31	// _86, tmp329
// Development/CritterProduct/Pilot/Memory/critter_memory.c:248:     mean /= (double)count;
	ldr	d30, [sp, 80]	// tmp331, mean
	fdiv	d31, d30, d31	// mean_131, tmp331, _86
	str	d31, [sp, 80]	// mean_131, mean
// Development/CritterProduct/Pilot/Memory/critter_memory.c:249:     summary->min_temperature_c = min_temp;
	ldr	x0, [sp, 16]	// tmp332, summary
	ldr	d31, [sp, 72]	// tmp333, min_temp
	str	d31, [x0, 56]	// tmp333, summary_115(D)->min_temperature_c
// Development/CritterProduct/Pilot/Memory/critter_memory.c:250:     summary->max_temperature_c = max_temp;
	ldr	x0, [sp, 16]	// tmp334, summary
	ldr	d31, [sp, 64]	// tmp335, max_temp
	str	d31, [x0, 64]	// tmp335, summary_115(D)->max_temperature_c
// Development/CritterProduct/Pilot/Memory/critter_memory.c:251:     summary->mean_temperature_c = mean;
	ldr	x0, [sp, 16]	// tmp336, summary
	ldr	d31, [sp, 80]	// tmp337, mean
	str	d31, [x0, 72]	// tmp337, summary_115(D)->mean_temperature_c
// Development/CritterProduct/Pilot/Memory/critter_memory.c:252:     summary->median_temperature_c = critter_median(temperatures, count);
	ldr	x1, [sp, 56]	//, count
	ldr	x0, [sp, 48]	//, temperatures
	bl	critter_median		//
	fmov	d31, d0	// _87,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:252:     summary->median_temperature_c = critter_median(temperatures, count);
	ldr	x0, [sp, 16]	// tmp338, summary
	str	d31, [x0, 80]	// _87, summary_115(D)->median_temperature_c
// Development/CritterProduct/Pilot/Memory/critter_memory.c:253:     summary->stddev_temperature_c = critter_stddev(temperatures, count, mean);
	ldr	d0, [sp, 80]	//, mean
	ldr	x1, [sp, 56]	//, count
	ldr	x0, [sp, 48]	//, temperatures
	bl	critter_stddev		//
	fmov	d31, d0	// _88,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:253:     summary->stddev_temperature_c = critter_stddev(temperatures, count, mean);
	ldr	x0, [sp, 16]	// tmp339, summary
	str	d31, [x0, 88]	// _88, summary_115(D)->stddev_temperature_c
// Development/CritterProduct/Pilot/Memory/critter_memory.c:254:     summary->latest_temperature_c = memory->buffer[(memory->head + memory->capacity - 1U) % memory->capacity].temperature_c;
	ldr	x0, [sp, 24]	// tmp340, memory
	ldr	x2, [x0]	// _89, memory_114(D)->buffer
// Development/CritterProduct/Pilot/Memory/critter_memory.c:254:     summary->latest_temperature_c = memory->buffer[(memory->head + memory->capacity - 1U) % memory->capacity].temperature_c;
	ldr	x0, [sp, 24]	// tmp341, memory
	ldr	x1, [x0, 16]	// _90, memory_114(D)->head
// Development/CritterProduct/Pilot/Memory/critter_memory.c:254:     summary->latest_temperature_c = memory->buffer[(memory->head + memory->capacity - 1U) % memory->capacity].temperature_c;
	ldr	x0, [sp, 24]	// tmp342, memory
	ldr	x0, [x0, 8]	// _91, memory_114(D)->capacity
// Development/CritterProduct/Pilot/Memory/critter_memory.c:254:     summary->latest_temperature_c = memory->buffer[(memory->head + memory->capacity - 1U) % memory->capacity].temperature_c;
	add	x0, x1, x0	// _92, _90, _91
// Development/CritterProduct/Pilot/Memory/critter_memory.c:254:     summary->latest_temperature_c = memory->buffer[(memory->head + memory->capacity - 1U) % memory->capacity].temperature_c;
	sub	x0, x0, #1	// _93, _92,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:254:     summary->latest_temperature_c = memory->buffer[(memory->head + memory->capacity - 1U) % memory->capacity].temperature_c;
	ldr	x1, [sp, 24]	// tmp343, memory
	ldr	x1, [x1, 8]	// _94, memory_114(D)->capacity
// Development/CritterProduct/Pilot/Memory/critter_memory.c:254:     summary->latest_temperature_c = memory->buffer[(memory->head + memory->capacity - 1U) % memory->capacity].temperature_c;
	udiv	x3, x0, x1	// tmp346, _93, _94
	mul	x1, x3, x1	// tmp347, tmp346, _94
	sub	x1, x0, x1	// _95, _93, tmp347
// Development/CritterProduct/Pilot/Memory/critter_memory.c:254:     summary->latest_temperature_c = memory->buffer[(memory->head + memory->capacity - 1U) % memory->capacity].temperature_c;
	mov	x0, x1	// _96, _95
	lsl	x0, x0, 2	// _96, _96,
	add	x0, x0, x1	// _96, _96, _95
	lsl	x0, x0, 3	// tmp349, _96,
	add	x0, x2, x0	// _97, _89, _96
// Development/CritterProduct/Pilot/Memory/critter_memory.c:254:     summary->latest_temperature_c = memory->buffer[(memory->head + memory->capacity - 1U) % memory->capacity].temperature_c;
	ldr	d31, [x0, 8]	// _98, _97->temperature_c
// Development/CritterProduct/Pilot/Memory/critter_memory.c:254:     summary->latest_temperature_c = memory->buffer[(memory->head + memory->capacity - 1U) % memory->capacity].temperature_c;
	ldr	x0, [sp, 16]	// tmp350, summary
	str	d31, [x0, 128]	// _98, summary_115(D)->latest_temperature_c
// Development/CritterProduct/Pilot/Memory/critter_memory.c:255:     summary->retained_ratio = (count > 0U) ? (double)count / (double)memory->total_received_samples : 0.0;
	ldr	x0, [sp, 56]	// tmp351, count
	cmp	x0, 0	// tmp351,
	beq	.L85		//,
// Development/CritterProduct/Pilot/Memory/critter_memory.c:255:     summary->retained_ratio = (count > 0U) ? (double)count / (double)memory->total_received_samples : 0.0;
	ldr	d31, [sp, 56]	// tmp352, count
	ucvtf	d30, d31	// _99, tmp352
// Development/CritterProduct/Pilot/Memory/critter_memory.c:255:     summary->retained_ratio = (count > 0U) ? (double)count / (double)memory->total_received_samples : 0.0;
	ldr	x0, [sp, 24]	// tmp353, memory
	ldr	d31, [x0, 32]	// _100, memory_114(D)->total_received_samples
// Development/CritterProduct/Pilot/Memory/critter_memory.c:255:     summary->retained_ratio = (count > 0U) ? (double)count / (double)memory->total_received_samples : 0.0;
	ucvtf	d31, d31	// _101, _100
// Development/CritterProduct/Pilot/Memory/critter_memory.c:255:     summary->retained_ratio = (count > 0U) ? (double)count / (double)memory->total_received_samples : 0.0;
	fdiv	d31, d30, d31	// iftmp.0_109, _99, _101
	b	.L86		//
.L85:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:255:     summary->retained_ratio = (count > 0U) ? (double)count / (double)memory->total_received_samples : 0.0;
	movi	d31, #0	// iftmp.0_109
.L86:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:255:     summary->retained_ratio = (count > 0U) ? (double)count / (double)memory->total_received_samples : 0.0;
	ldr	x0, [sp, 16]	// tmp354, summary
	str	d31, [x0, 112]	// iftmp.0_109, summary_115(D)->retained_ratio
// Development/CritterProduct/Pilot/Memory/critter_memory.c:257:     free(temperatures);
	ldr	x0, [sp, 48]	//, temperatures
	bl	free		//
// Development/CritterProduct/Pilot/Memory/critter_memory.c:258:     return 0;
	mov	w0, 0	// _108,
.L74:
// Development/CritterProduct/Pilot/Memory/critter_memory.c:259: }
	ldp	x29, x30, [sp], 96	//,,,
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE8:
	.size	critter_memory_build_summary, .-critter_memory_build_summary
	.ident	"GCC: (Debian 14.2.0-19) 14.2.0"
	.section	.note.GNU-stack,"",@progbits
