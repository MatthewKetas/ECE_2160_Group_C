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
	.cfi_startproc
// Leaf function: caller-saved registers hold pointers and intermediate values.
	cbz	x0, .Lopt_compute_error
	cbz	x1, .Lopt_compute_error
	ldr	x9, [x0]
	cbz	x9, .Lopt_compute_error
	fabs	d1, d0
	mov	x9, #9218868437227405311
	fmov	d2, x9
	fcmp	d1, d2
	b.hi	.Lopt_compute_error
	ldr	d1, [x0, 128]     // latest temperature
	ldr	d2, [x0, 72]      // mean
	ldr	d3, [x0, 88]      // standard deviation
	ldp	d5, d4, [x0, 96]  // first and last timestamp
	ldr	w9, [x0, 120]
	str	d4, [x1, 40]
	str	d1, [x1]
	str	w9, [x1, 88]
	str	d0, [x1, 32]
	fsub	d5, d4, d5
	fmov	d7, #1.0
	fcmpe	d5, #0.0
	fcsel	d5, d7, d5, ls  // Ordered <= 0 only; NaN keeps the original delta.
	fsub	d6, d1, d2
	fdiv	d6, d6, d5
	stp	d6, d6, [x1, 8]
	str	d6, [x1, 48]
// Keep separate multiply/add operations to preserve baseline rounding.
	fmul	d7, d4, d6
	fsub	d7, d1, d7
	str	d7, [x1, 56]
	ldr	d7, [x0, 56]
	fsub	d7, d1, d7
	str	d7, [x1, 72]
	fmul	d7, d3, d3
	str	d7, [x1, 64]
	fmul	d7, d6, d0
	fadd	d7, d1, d7
	str	d7, [x1, 24]
	fabs	d16, d6
	adrp	x9, .LC0
	ldr	d17, [x9, #:lo12:.LC0]
	fmov	d18, #0.5
// Conditional comparisons retain short-circuit FP exception behavior.
	fcmpe	d16, d17
	fccmpe	d3, d18, #0, mi
	cset	w9, mi
	strb	w9, [x1, 80]     // stable
	adrp	x9, .LC1
	ldr	d19, [x9, #:lo12:.LC1]
	fcmpe	d6, d19
	cset	w9, gt
	strb	w9, [x1, 81]     // rising
	adrp	x9, .LC2
	ldr	d19, [x9, #:lo12:.LC2]
	fcmpe	d6, d19
	cset	w9, mi
	strb	w9, [x1, 82]     // falling
	fcmpe	d16, d17
	fccmpe	d3, d18, #0, le
	cset	w9, gt
	strb	w9, [x1, 83]     // likely_hvac_active (not !stable)
	adrp	x9, .LC3
	ldr	d19, [x9, #:lo12:.LC3]
	fcmpe	d6, d19
	fccmpe	d1, d2, #4, gt
	cset	w9, gt
	strb	w9, [x1, 85]     // likely_heating
	adrp	x9, .LC4
	ldr	d19, [x9, #:lo12:.LC4]
	fcmpe	d6, d19
	fccmpe	d1, d2, #0, mi
	cset	w9, mi
	strb	w9, [x1, 84]     // likely_cooling
	mov	w0, #0
	ret
.Lopt_compute_error:
	mov	w0, #-1
	ret
	.cfi_endproc
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
