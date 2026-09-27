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
	.cfi_startproc
// Same exchange-sort order; keep pointers and values in registers.
	cbz	x1, .Lopt_median_empty
	add	x4, x0, x1, lsl #3
	mov	x2, x0
.Lopt_median_outer:
	ldr	d0, [x2]
	add	x3, x2, #8
	cmp	x3, x4
	b.hs	.Lopt_median_next
.Lopt_median_inner:
	ldr	d1, [x3]
	fcmpe	d1, d0
	b.pl	.Lopt_median_keep
	str	d0, [x3]
	fmov	d0, d1
	str	d0, [x2]
.Lopt_median_keep:
	add	x3, x3, #8
	cmp	x3, x4
	b.lo	.Lopt_median_inner
.Lopt_median_next:
	add	x2, x2, #8
	cmp	x2, x4
	b.lo	.Lopt_median_outer
	lsr	x2, x1, #1
	add	x2, x0, x2, lsl #3
	ldr	d0, [x2]
	tbnz	x1, #0, .Lopt_median_done
	ldr	d1, [x2, #-8]
	fadd	d0, d1, d0
	fmov	d1, #0.5
	fmul	d0, d0, d1        // Exact power-of-two scaling replaces / 2.
.Lopt_median_done:
	ret
.Lopt_median_empty:
	fmov	d0, xzr
	ret
	.cfi_endproc
	.size	critter_median, .-critter_median
	.align	2
	.type	critter_stddev, %function
critter_stddev:
	.cfi_startproc
// Keep the original scalar accumulation order and sqrt library semantics.
	cbz	x1, .Lopt_stddev_empty
	fmov	d1, d0
	fmov	d0, xzr
	mov	x2, x1
.Lopt_stddev_loop:
	ldr	d2, [x0], #8
	fsub	d2, d2, d1
	fmul	d2, d2, d2
	fadd	d0, d0, d2
	subs	x2, x2, #1
	b.ne	.Lopt_stddev_loop
	ucvtf	d1, x1
	fdiv	d0, d0, d1
	b	sqrt                 // Tail call: no stack frame is needed.
.Lopt_stddev_empty:
	fmov	d0, xzr
	ret
	.cfi_endproc
	.size	critter_stddev, .-critter_stddev
	.align	2
	.type	critter_add_in_ring, %function
critter_add_in_ring:
	.cfi_startproc
cbz	x0, .Lopt_ring_error
	cbz	x1, .Lopt_ring_error
	ldp	x2, x3, [x0]       // buffer, capacity
	ldp	x4, x5, [x0, 16]   // head, count
	add	x6, x4, x4, lsl #2
	add	x6, x2, x6, lsl #3 // 40-byte sample
	ldp	q0, q1, [x1]
	ldr	x7, [x1, 32]
	stp	q0, q1, [x6]
	str	x7, [x6, 32]
// Valid initialized ring: head < capacity and count <= capacity.
	add	x4, x4, #1
	cmp	x4, x3
	csel	x4, xzr, x4, eq
	cmp	x5, x3
	cinc	x5, x5, lo
	stp	x4, x5, [x0, 16]
	mov	w0, #0
	ret
.Lopt_ring_error:
	mov	w0, #-1
	ret
	.cfi_endproc
	.size	critter_add_in_ring, .-critter_add_in_ring
	.align	2
	.type	critter_detect_outlier, %function
critter_detect_outlier:
	.cfi_startproc
stp	x29, x30, [sp, #-64]!
	.cfi_def_cfa_offset 64
	.cfi_offset 29, -64
	.cfi_offset 30, -56
	mov	x29, sp
	stp	x19, x20, [sp, 16]
	.cfi_offset 19, -48
	.cfi_offset 20, -40
	stp	x21, x22, [sp, 32]
	.cfi_offset 21, -32
	.cfi_offset 22, -24
	str	d8, [sp, 48]
	.cfi_offset 72, -16
	cbz	x0, .Lopt_outlier_none
	cbz	x1, .Lopt_outlier_none
	mov	x19, x0
	mov	x20, x1
	ldr	x21, [x19, 24]
	cmp	x21, #3
	b.lo	.Lopt_outlier_none
	lsl	x0, x21, #3
	bl	malloc
	cbz	x0, .Lopt_outlier_none
	mov	x22, x0
// Compute the oldest index once, then increment and wrap without division.
	ldp	x9, x10, [x19]     // buffer, capacity
	ldr	x11, [x19, 16]
	subs	x11, x11, x21
	add	x12, x11, x10
	csel	x11, x12, x11, lo
	mov	x13, x22
	mov	x14, x21
.Lopt_outlier_copy:
	add	x12, x11, x11, lsl #2
	add	x12, x9, x12, lsl #3
	ldr	d0, [x12, 8]
	str	d0, [x13], #8
	add	x11, x11, #1
	cmp	x11, x10
	csel	x11, xzr, x11, eq
	subs	x14, x14, #1
	b.ne	.Lopt_outlier_copy
	mov	x0, x22
	mov	x1, x21
	bl	critter_median
	fmov	d8, d0           // Preserve the median across the second call.
// Independent deviations: two doubles per NEON iteration, scalar odd tail.
	dup	v1.2d, v0.d[0]
	mov	x9, x22
	lsr	x10, x21, #1
	cbz	x10, .Lopt_deviation_tail
.Lopt_deviation_pair:
	ldr	q0, [x9]
	fsub	v0.2d, v0.2d, v1.2d
	fabs	v0.2d, v0.2d
	str	q0, [x9], #16
	subs	x10, x10, #1
	b.ne	.Lopt_deviation_pair
.Lopt_deviation_tail:
	tbz	x21, #0, .Lopt_deviation_done
	ldr	d0, [x9]
	fsub	d0, d0, d8
	fabs	d0, d0
	str	d0, [x9]
.Lopt_deviation_done:
	mov	x0, x22
	mov	x1, x21
	bl	critter_median
	fmov	d1, #3.0
	fmul	d0, d0, d1
	fmov	d1, #0.5
	fadd	d0, d0, d1
	ldr	d1, [x20, 8]
	fsub	d1, d1, d8
	fabs	d1, d1
	fcmpe	d0, d1
	cset	w19, mi
	mov	x0, x22
	bl	free
	mov	w0, w19
	b	.Lopt_outlier_return
.Lopt_outlier_none:
	mov	w0, #0
.Lopt_outlier_return:
	ldr	d8, [sp, 48]
	.cfi_restore 72
	ldp	x21, x22, [sp, 32]
	.cfi_restore 21
	.cfi_restore 22
	ldp	x19, x20, [sp, 16]
	.cfi_restore 19
	.cfi_restore 20
	ldp	x29, x30, [sp], #64
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
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
	.cfi_startproc
stp	x29, x30, [sp, #-80]!
	.cfi_def_cfa_offset 80
	.cfi_offset 29, -80
	.cfi_offset 30, -72
	mov	x29, sp
	stp	x19, x20, [sp, 16]
	.cfi_offset 19, -64
	.cfi_offset 20, -56
	stp	x21, x22, [sp, 32]
	.cfi_offset 21, -48
	.cfi_offset 22, -40
	stp	d8, d9, [sp, 48]
	.cfi_offset 72, -32
	.cfi_offset 73, -24
	str	d10, [sp, 64]
	.cfi_offset 74, -16
	cbz	x0, .Lopt_summary_error
	cbz	x1, .Lopt_summary_error
	mov	x19, x0
	mov	x20, x1
	ldr	x21, [x19, 24]
	cbz	x21, .Lopt_summary_error
	mov	x0, x20
	mov	w1, #0
	mov	x2, #136
	bl	memset
	lsl	x0, x21, #3
	bl	malloc
	cbz	x0, .Lopt_summary_error
	mov	x22, x0
	ldp	x9, x10, [x19]    // buffer, capacity
	ldr	x11, [x19, 16]    // head
	subs	x11, x11, x21
	add	x12, x11, x10
	csel	x11, x12, x11, lo
	add	x12, x11, x11, lsl #2
	add	x12, x9, x12, lsl #3
	ldp	d0, d9, [x12]     // first timestamp and initial minimum
	str	d0, [x20, 96]
	fmov	d10, d9
	fmov	d8, xzr           // running sum, original accumulation order
// Resolve the latest sample once for both timestamp and temperature.
	ldr	x12, [x19, 16]
	subs	x12, x12, #1
	sub	x13, x10, #1
	csel	x12, x13, x12, lo
	add	x12, x12, x12, lsl #2
	add	x12, x9, x12, lsl #3
	ldp	d0, d1, [x12]
	str	d0, [x20, 104]
	str	d1, [x20, 128]
	stp	x21, x21, [x20]
	ldr	x12, [x19, 56]
	str	x12, [x20, 16]
	mov	x13, x22
	mov	x17, x21
	mov	w16, #0            // Preserve the existing source-state transitions.
.Lopt_summary_loop:
	add	x12, x11, x11, lsl #2
	add	x12, x9, x12, lsl #3
	ldr	d0, [x12, 8]
	str	d0, [x13], #8
	fadd	d8, d8, d0
	fcmpe	d0, d9
	fcsel	d9, d0, d9, mi
	fcmpe	d10, d0
	fcsel	d10, d0, d10, mi
	ldr	w14, [x12, 32]
	sub	w15, w14, #1
	cmp	w15, #2
	b.hi	.Lopt_summary_source
	add	x12, x20, #24
	ldr	x15, [x12, x14, lsl #3]
	add	x15, x15, #1
	str	x15, [x12, x14, lsl #3]
.Lopt_summary_source:
	cmp	w16, w14
	csel	w15, w16, wzr, eq
	cmp	w16, #0
	csel	w16, w14, w15, eq
	add	x11, x11, #1
	cmp	x11, x10
	csel	x11, xzr, x11, eq
	subs	x17, x17, #1
	b.ne	.Lopt_summary_loop
	str	w16, [x20, 120]
	ucvtf	d0, x21
	fdiv	d8, d8, d0
	stp	d9, d10, [x20, 56]
	str	d8, [x20, 72]
	mov	x0, x22
	mov	x1, x21
	bl	critter_median
	str	d0, [x20, 80]
	mov	x0, x22
	mov	x1, x21
	fmov	d0, d8
	bl	critter_stddev
	str	d0, [x20, 88]
	ucvtf	d0, x21
	ldr	x9, [x19, 32]
	ucvtf	d1, x9
	fdiv	d0, d0, d1
	str	d0, [x20, 112]
	mov	x0, x22
	bl	free
	mov	w0, #0
	b	.Lopt_summary_return
.Lopt_summary_error:
	mov	w0, #-1
.Lopt_summary_return:
	ldr	d10, [sp, 64]
	.cfi_restore 74
	ldp	d8, d9, [sp, 48]
	.cfi_restore 72
	.cfi_restore 73
	ldp	x21, x22, [sp, 32]
	.cfi_restore 21
	.cfi_restore 22
	ldp	x19, x20, [sp, 16]
	.cfi_restore 19
	.cfi_restore 20
	ldp	x29, x30, [sp], #80
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
	.size	critter_memory_build_summary, .-critter_memory_build_summary
	.ident	"GCC: (Debian 14.2.0-19) 14.2.0"
	.section	.note.GNU-stack,"",@progbits
