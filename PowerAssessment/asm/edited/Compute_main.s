	.arch armv8-a
	.file	"Compute_main.c"
// GNU C11 (Debian 14.2.0-19) version 14.2.0 (aarch64-linux-gnu)
//	compiled by GNU C version 14.2.0, GMP version 6.3.0, MPFR version 4.2.1, MPC version 1.3.1, isl version isl-0.27-GMP

// warning: MPFR header version 4.2.1 differs from library version 4.2.2.
// GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
// options passed: -mlittle-endian -mabi=lp64 -O0 -std=c11 -fasynchronous-unwind-tables
	.text
	.section	.rodata
	.align	3
	.type	compute_input, %object
	.size	compute_input, 136
compute_input:
// sample_count:
	.xword	100
// valid_sample_count:
	.xword	100
// outlier_count:
	.xword	6
// sample_count_by_source:
	.xword	0
	.xword	0
	.xword	100
	.xword	0
// min_temperature_c:
	.word	1202590843
	.word	1077443297
// max_temperature_c:
	.word	-1374389535
	.word	1077477703
// mean_temperature_c:
	.word	-1504956541
	.word	1077460490
// median_temperature_c:
	.word	2061584302
	.word	1077460500
// stddev_temperature_c:
	.word	339326386
	.word	1069721430
// first_timestamp_s:
	.word	1282618163
	.word	1104762108
// last_timestamp_s:
	.word	1324561203
	.word	1104762108
// retained_ratio:
	.word	1431655765
	.word	1069897045
// source:
	.word	2
// latest_temperature_c:
	.zero	4
	.word	-1546188227
	.word	1077476720
	.align	3
.LC0:
	.string	"failed to read start time\n"
	.align	3
.LC1:
	.string	"failed to compute analysis\n"
	.align	3
.LC2:
	.string	"failed to read end time\n"
	.align	3
.LC3:
	.string	"true"
	.align	3
.LC4:
	.string	"false"
	.align	3
.LC5:
	.string	"analysis: current=%.2f predicted=%.6f trend=%.6f rate=%.6f hvac=%s heating=%s cooling=%s stable=%s\n"
	.align	3
.LC6:
	.string	"one prediction: %.0f ns (limited by clock resolution/overhead; not energy)\n"
	.text
	.align	2
	.global	main
	.type	main, %function
main:
.LFB0:
	.cfi_startproc
	stp	x29, x30, [sp, -160]!	//,,,
	.cfi_def_cfa_offset 160
	.cfi_offset 29, -160
	.cfi_offset 30, -152
	mov	x29, sp	//,
// PowerAssessment/comp/Compute_main.c:12:     const double prediction_horizon_s = 30.0;
	fmov	d31, 3.0e+1	// tmp130,
	str	d31, [sp, 152]	// tmp130, prediction_horizon_s
// PowerAssessment/comp/Compute_main.c:16:     if (clock_gettime(CLOCK_MONOTONIC, &start_ts) != 0)
	add	x0, sp, 40	// tmp131,,
	mov	x1, x0	//, tmp131
	mov	w0, 1	//,
	bl	clock_gettime		//
// PowerAssessment/comp/Compute_main.c:16:     if (clock_gettime(CLOCK_MONOTONIC, &start_ts) != 0)
	cmp	w0, 0	// _1,
	beq	.L2		//,
// PowerAssessment/comp/Compute_main.c:18:         fprintf(stderr, "failed to read start time\n");
	adrp	x0, :got:stderr;ldr	x0, [x0, :got_lo12:stderr]	// tmp132,
	ldr	x0, [x0]	// stderr.0_2, stderr
	mov	x3, x0	//, stderr.0_2
	mov	x2, 26	//,
	mov	x1, 1	//,
	adrp	x0, .LC0	// tmp133,
	add	x0, x0, :lo12:.LC0	//, tmp133,
	bl	fwrite		//
// PowerAssessment/comp/Compute_main.c:19:         return 1;
	mov	w0, 1	// _25,
	b	.L14		//
.L2:
// PowerAssessment/comp/Compute_main.c:22:     if (critter_compute_analysis(&compute_input, prediction_horizon_s, &analysis) != 0)
	add	x0, sp, 56	// tmp134,,
	mov	x1, x0	//, tmp134
	ldr	d0, [sp, 152]	//, prediction_horizon_s
	adrp	x0, compute_input	// tmp135,
	add	x0, x0, :lo12:compute_input	//, tmp135,
	bl	critter_compute_analysis		//
// PowerAssessment/comp/Compute_main.c:22:     if (critter_compute_analysis(&compute_input, prediction_horizon_s, &analysis) != 0)
	cmp	w0, 0	// _3,
	beq	.L4		//,
// PowerAssessment/comp/Compute_main.c:24:         fprintf(stderr, "failed to compute analysis\n");
	adrp	x0, :got:stderr;ldr	x0, [x0, :got_lo12:stderr]	// tmp136,
	ldr	x0, [x0]	// stderr.1_4, stderr
	mov	x3, x0	//, stderr.1_4
	mov	x2, 27	//,
	mov	x1, 1	//,
	adrp	x0, .LC1	// tmp137,
	add	x0, x0, :lo12:.LC1	//, tmp137,
	bl	fwrite		//
// PowerAssessment/comp/Compute_main.c:25:         return 1;
	mov	w0, 1	// _25,
	b	.L14		//
.L4:
// PowerAssessment/comp/Compute_main.c:27:     if (clock_gettime(CLOCK_MONOTONIC, &end_ts) != 0)
	add	x0, sp, 24	// tmp138,,
	mov	x1, x0	//, tmp138
	mov	w0, 1	//,
	bl	clock_gettime		//
// PowerAssessment/comp/Compute_main.c:27:     if (clock_gettime(CLOCK_MONOTONIC, &end_ts) != 0)
	cmp	w0, 0	// _5,
	beq	.L5		//,
// PowerAssessment/comp/Compute_main.c:29:         fprintf(stderr, "failed to read end time\n");
	adrp	x0, :got:stderr;ldr	x0, [x0, :got_lo12:stderr]	// tmp139,
	ldr	x0, [x0]	// stderr.2_6, stderr
	mov	x3, x0	//, stderr.2_6
	mov	x2, 24	//,
	mov	x1, 1	//,
	adrp	x0, .LC2	// tmp140,
	add	x0, x0, :lo12:.LC2	//, tmp140,
	bl	fwrite		//
// PowerAssessment/comp/Compute_main.c:30:         return 1;
	mov	w0, 1	// _25,
	b	.L14		//
.L5:
// PowerAssessment/comp/Compute_main.c:33:     printf("analysis: current=%.2f predicted=%.6f trend=%.6f rate=%.6f hvac=%s heating=%s cooling=%s stable=%s\n",
	ldr	d31, [sp, 56]	// _7, analysis.current_temperature_c
	ldr	d30, [sp, 80]	// _8, analysis.predicted_temperature_c
	ldr	d29, [sp, 64]	// _9, analysis.trend_c_per_s
	ldr	d28, [sp, 72]	// _10, analysis.rate_of_change_c_per_s
// PowerAssessment/comp/Compute_main.c:36:            analysis.likely_hvac_active ? "true" : "false",
	ldrb	w0, [sp, 139]	// _11, analysis.likely_hvac_active
// PowerAssessment/comp/Compute_main.c:33:     printf("analysis: current=%.2f predicted=%.6f trend=%.6f rate=%.6f hvac=%s heating=%s cooling=%s stable=%s\n",
	and	w0, w0, 1	// tmp141, _11,
	cmp	w0, 0	// tmp141,
	beq	.L6		//,
// PowerAssessment/comp/Compute_main.c:33:     printf("analysis: current=%.2f predicted=%.6f trend=%.6f rate=%.6f hvac=%s heating=%s cooling=%s stable=%s\n",
	adrp	x0, .LC3	// tmp142,
	add	x0, x0, :lo12:.LC3	// iftmp.3_26, tmp142,
	b	.L7		//
.L6:
// PowerAssessment/comp/Compute_main.c:33:     printf("analysis: current=%.2f predicted=%.6f trend=%.6f rate=%.6f hvac=%s heating=%s cooling=%s stable=%s\n",
	adrp	x0, .LC4	// tmp143,
	add	x0, x0, :lo12:.LC4	// iftmp.3_26, tmp143,
.L7:
// PowerAssessment/comp/Compute_main.c:37:            analysis.likely_heating ? "true" : "false",
	ldrb	w1, [sp, 141]	// _12, analysis.likely_heating
// PowerAssessment/comp/Compute_main.c:33:     printf("analysis: current=%.2f predicted=%.6f trend=%.6f rate=%.6f hvac=%s heating=%s cooling=%s stable=%s\n",
	and	w1, w1, 1	// tmp144, _12,
	cmp	w1, 0	// tmp144,
	beq	.L8		//,
// PowerAssessment/comp/Compute_main.c:33:     printf("analysis: current=%.2f predicted=%.6f trend=%.6f rate=%.6f hvac=%s heating=%s cooling=%s stable=%s\n",
	adrp	x1, .LC3	// tmp145,
	add	x1, x1, :lo12:.LC3	// iftmp.4_27, tmp145,
	b	.L9		//
.L8:
// PowerAssessment/comp/Compute_main.c:33:     printf("analysis: current=%.2f predicted=%.6f trend=%.6f rate=%.6f hvac=%s heating=%s cooling=%s stable=%s\n",
	adrp	x1, .LC4	// tmp146,
	add	x1, x1, :lo12:.LC4	// iftmp.4_27, tmp146,
.L9:
// PowerAssessment/comp/Compute_main.c:38:            analysis.likely_cooling ? "true" : "false",
	ldrb	w2, [sp, 140]	// _13, analysis.likely_cooling
// PowerAssessment/comp/Compute_main.c:33:     printf("analysis: current=%.2f predicted=%.6f trend=%.6f rate=%.6f hvac=%s heating=%s cooling=%s stable=%s\n",
	and	w2, w2, 1	// tmp147, _13,
	cmp	w2, 0	// tmp147,
	beq	.L10		//,
// PowerAssessment/comp/Compute_main.c:33:     printf("analysis: current=%.2f predicted=%.6f trend=%.6f rate=%.6f hvac=%s heating=%s cooling=%s stable=%s\n",
	adrp	x2, .LC3	// tmp148,
	add	x2, x2, :lo12:.LC3	// iftmp.5_28, tmp148,
	b	.L11		//
.L10:
// PowerAssessment/comp/Compute_main.c:33:     printf("analysis: current=%.2f predicted=%.6f trend=%.6f rate=%.6f hvac=%s heating=%s cooling=%s stable=%s\n",
	adrp	x2, .LC4	// tmp149,
	add	x2, x2, :lo12:.LC4	// iftmp.5_28, tmp149,
.L11:
// PowerAssessment/comp/Compute_main.c:39:            analysis.stable ? "true" : "false");
	ldrb	w3, [sp, 136]	// _14, analysis.stable
// PowerAssessment/comp/Compute_main.c:33:     printf("analysis: current=%.2f predicted=%.6f trend=%.6f rate=%.6f hvac=%s heating=%s cooling=%s stable=%s\n",
	and	w3, w3, 1	// tmp150, _14,
	cmp	w3, 0	// tmp150,
	beq	.L12		//,
// PowerAssessment/comp/Compute_main.c:33:     printf("analysis: current=%.2f predicted=%.6f trend=%.6f rate=%.6f hvac=%s heating=%s cooling=%s stable=%s\n",
	adrp	x3, .LC3	// tmp151,
	add	x3, x3, :lo12:.LC3	// iftmp.6_29, tmp151,
	b	.L13		//
.L12:
// PowerAssessment/comp/Compute_main.c:33:     printf("analysis: current=%.2f predicted=%.6f trend=%.6f rate=%.6f hvac=%s heating=%s cooling=%s stable=%s\n",
	adrp	x3, .LC4	// tmp152,
	add	x3, x3, :lo12:.LC4	// iftmp.6_29, tmp152,
.L13:
// PowerAssessment/comp/Compute_main.c:33:     printf("analysis: current=%.2f predicted=%.6f trend=%.6f rate=%.6f hvac=%s heating=%s cooling=%s stable=%s\n",
	mov	x4, x3	//, iftmp.6_29
	mov	x3, x2	//, iftmp.5_28
	mov	x2, x1	//, iftmp.4_27
	mov	x1, x0	//, iftmp.3_26
	fmov	d3, d28	//, _10
	fmov	d2, d29	//, _9
	fmov	d1, d30	//, _8
	fmov	d0, d31	//, _7
	adrp	x0, .LC5	// tmp153,
	add	x0, x0, :lo12:.LC5	//, tmp153,
	bl	printf		//
// PowerAssessment/comp/Compute_main.c:41:            (double)(end_ts.tv_sec - start_ts.tv_sec) * 1000000000.0
	ldr	x1, [sp, 24]	// _15, end_ts.tv_sec
// PowerAssessment/comp/Compute_main.c:41:            (double)(end_ts.tv_sec - start_ts.tv_sec) * 1000000000.0
	ldr	x0, [sp, 40]	// _16, start_ts.tv_sec
// PowerAssessment/comp/Compute_main.c:41:            (double)(end_ts.tv_sec - start_ts.tv_sec) * 1000000000.0
	sub	x0, x1, x0	// _17, _15, _16
	fmov	d31, x0	// _17, _17
// PowerAssessment/comp/Compute_main.c:41:            (double)(end_ts.tv_sec - start_ts.tv_sec) * 1000000000.0
	scvtf	d31, d31	// _18, _17
// PowerAssessment/comp/Compute_main.c:41:            (double)(end_ts.tv_sec - start_ts.tv_sec) * 1000000000.0
	mov	x0, 225833675390976	// tmp157,
	movk	x0, 0x41cd, lsl 48	// tmp157,,
	fmov	d30, x0	// tmp154, tmp157
	fmul	d30, d31, d30	// _19, _18, tmp154
// PowerAssessment/comp/Compute_main.c:42:            + (double)(end_ts.tv_nsec - start_ts.tv_nsec));
	ldr	x1, [sp, 32]	// _20, end_ts.tv_nsec
// PowerAssessment/comp/Compute_main.c:42:            + (double)(end_ts.tv_nsec - start_ts.tv_nsec));
	ldr	x0, [sp, 48]	// _21, start_ts.tv_nsec
// PowerAssessment/comp/Compute_main.c:42:            + (double)(end_ts.tv_nsec - start_ts.tv_nsec));
	sub	x0, x1, x0	// _22, _20, _21
	fmov	d31, x0	// _22, _22
// PowerAssessment/comp/Compute_main.c:42:            + (double)(end_ts.tv_nsec - start_ts.tv_nsec));
	scvtf	d31, d31	// _23, _22
// PowerAssessment/comp/Compute_main.c:40:     printf("one prediction: %.0f ns (limited by clock resolution/overhead; not energy)\n",
	fadd	d31, d30, d31	// _24, _19, _23
	fmov	d0, d31	//, _24
	adrp	x0, .LC6	// tmp155,
	add	x0, x0, :lo12:.LC6	//, tmp155,
	bl	printf		//
// PowerAssessment/comp/Compute_main.c:43:     return 0;
	mov	w0, 0	// _25,
.L14:
// PowerAssessment/comp/Compute_main.c:44: }
	ldp	x29, x30, [sp], 160	//,,,
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.ident	"GCC: (Debian 14.2.0-19) 14.2.0"
	.section	.note.GNU-stack,"",@progbits
