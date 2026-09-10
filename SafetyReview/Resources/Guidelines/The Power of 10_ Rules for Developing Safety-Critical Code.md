# The Power of 10: Rules for Developing Safety-Critical Code

## Overview

The **Power of 10 Rules** were created in 2006 by [Gerard J. Holzmann](https://en.wikipedia.org/wiki/Gerard_J._Holzmann) of the NASA Jet Propulsion Laboratory (JPL) Laboratory for Reliable Software.

The rules are intended to eliminate C programming practices that make software difficult to:

- Review
- Verify
- Test
- Statically analyze
- Maintain in safety-critical systems

The Power of 10 rules complement standards such as [MISRA C](https://en.wikipedia.org/wiki/MISRA_C) and have been incorporated into broader JPL coding standards.

The objective is to constrain software design and implementation so that program behavior remains predictable, analyzable, and suitable for high-reliability and safety-critical embedded systems.

---

## Rules

### Rule 1 — Restrict Control Flow

Restrict all code to simple and predictable control-flow constructs.

Do not use:

- `goto`
- `setjmp`
- `longjmp`
- Direct recursion
- Indirect recursion

Control flow should remain straightforward enough that execution paths can be easily reviewed and analyzed.

---

### Rule 2 — Give All Loops a Fixed Upper Bound

Every loop must have a statically verifiable upper bound on the number of iterations.

A static-analysis tool should be able to determine that a loop cannot execute more than a predefined maximum number of times.

If the upper bound cannot be proven statically, the rule is considered violated.

This requirement helps prevent:

- Infinite loops
- Unbounded execution times
- Unpredictable timing behavior

---

### Rule 3 — Avoid Dynamic Memory Allocation After Initialization

Dynamic memory allocation must not be used after system initialization.

Runtime use of operations such as:

```c
malloc()
calloc()
realloc()
free()
```

should therefore be avoided.

Memory should instead be allocated statically or during a controlled initialization phase.

This reduces risks associated with:

- Memory fragmentation
- Allocation failure
- Memory leaks
- Nondeterministic allocation timing

---

### Rule 4 — Keep Functions Small

No function should be longer than what could reasonably fit on a single printed page using:

- One line per statement
- One line per declaration
- A standard source-code format

A typical guideline is approximately **60 lines of code per function**.

Functions should perform a focused task and should be decomposed when their responsibilities become too large.

---

### Rule 5 — Use Assertions Frequently

The source code should contain an average of at least **two assertions per function**.

Assertions should verify conditions that should never fail during normal execution.

Assertions must:

- Be side-effect free
- Evaluate Boolean conditions
- Detect anomalous or impossible program states
- Be associated with an explicit recovery action when appropriate

Example:

```c
assert(buffer != NULL);
assert(index < BUFFER_SIZE);
```

An assertion failure should result in a defined response, such as:

- Returning an error
- Entering a safe state
- Reporting a diagnostic condition

Assertions that a static-analysis tool can prove will always succeed or always fail do not provide useful runtime verification and violate the intent of this rule.

---

### Rule 6 — Minimize Data Scope

Declare all data objects at the smallest possible scope.

Prefer:

```c
void process(void)
{
    int sample_count = 0;
}
```

over unnecessary file-level or global variables.

Variables should only be visible to the portions of the program that require them.

This improves:

- Encapsulation
- Maintainability
- Reviewability
- Static analysis
- Protection against unintended modification

---

### Rule 7 — Check Parameters and Return Values

Each called function must validate the parameters supplied by its caller.

Each calling function must check the return value of non-`void` functions.

Example:

```c
int result = read_temperature(&temperature);

if (result != 0)
{
    return ERROR_SENSOR_READ;
}
```

Functions receiving pointers, indexes, sizes, identifiers, or other constrained values should verify that those parameters are valid before using them.

This rule prevents failures from silently propagating through the system.

---

### Rule 8 — Restrict Preprocessor Usage

Use the C preprocessor only for:

- Header-file inclusion
- Simple macro definitions

Avoid complex preprocessor behavior such as:

- Token pasting
- Variable argument macros
- Recursive macros
- Complex conditional compilation

Macros should expand into complete syntactic units.

For example:

```c
#define MAX_ROOMS 8
```

is preferable to macros that alter program structure or hide control flow.

Conditional compilation should be kept to a minimum.

---

### Rule 9 — Restrict Pointer Usage

Pointer usage should be kept as simple as possible.

No more than one level of pointer dereferencing should normally be used.

Avoid constructs such as:

```c
value = **ptr;
```

Pointer dereferencing must not be hidden inside:

- Macros
- `typedef` declarations

Function pointers are not permitted under the Power of 10 rules.

The purpose of this restriction is to make memory access explicit and easier to analyze.

---

### Rule 10 — Compile and Analyze With Zero Warnings

From the first day of development, all code must be compiled with compiler warnings enabled at the most restrictive practical level.

The project should compile with:

> **Zero compiler warnings**

The source code should also be analyzed regularly using at least one strong static-analysis tool, preferably multiple tools.

Static-analysis results should also target:

> **Zero warnings**

Compiler warnings and static-analysis findings should be treated as defects requiring investigation rather than ignored as normal build output.

---

## Summary

The Power of 10 rules emphasize:

1. Simple control flow
2. Bounded execution
3. Deterministic memory usage
4. Small functions
5. Runtime verification
6. Restricted variable scope
7. Defensive interface checking
8. Limited preprocessor usage
9. Simple pointer usage
10. Warning-free compilation and static analysis

For embedded and safety-critical systems, these restrictions improve the ability to reason about the software's behavior and make the source code easier to review, test, verify, and analyze.

---

## Reference

Gerard J. Holzmann, **"The Power of 10: Rules for Developing Safety-Critical Code,"** IEEE Computer, 2006.

Additional overview:

[The Power of 10: Rules for Developing Safety-Critical Code — Wikipedia](https://en.wikipedia.org/wiki/The_Power_of_10:_Rules_for_Developing_Safety-Critical_Code)