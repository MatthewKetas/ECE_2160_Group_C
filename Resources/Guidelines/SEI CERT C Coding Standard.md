# SEI CERT C Coding Standard

## Scope

This reference summarizes **Sections 2 through 15** of the **SEI CERT C Coding Standard, 2016 Edition**. These sections contain 99 rules for developing safe, reliable, and secure C programs.

The rules target defects involving undefined behavior, invalid data, resource misuse, concurrency, and insecure interfaces. Conformance requires addressing every applicable rule; automated analysis should be supplemented by compiler diagnostics, testing, and manual review.

---

## 2. Preprocessor (PRE)

### PRE30-C: Do Not Create a Universal Character Name Through Concatenation

Do not use token concatenation (`##`) to construct a universal character name such as `\u0401`. The C standard defines this behavior as undefined.

### PRE31-C: Avoid Side Effects in Arguments to Unsafe Macros

Do not pass assignments, increments, volatile accesses, I/O operations, or side-effecting function calls to a macro that may evaluate an argument more than once or not at all. Prefer inline functions, and keep assertions free of side effects.

### PRE32-C: Do Not Use Preprocessor Directives in Invocations of Function-Like Macros

Place conditional-compilation directives outside function-like macro invocations and calls that might be implemented as macros. Directives inside a macro argument list produce undefined behavior.

---

## 3. Declarations and Initialization (DCL)

### DCL30-C: Declare Objects with Appropriate Storage Durations

Ensure that every pointer refers to a live object. Never return, retain, or publish the address of an automatic object after its scope ends.

### DCL31-C: Declare Identifiers Before Using Them

Give every object and function an explicit declaration and type before use. Include the proper standard header instead of relying on implicit function declarations or implicit `int`.

### DCL36-C: Do Not Declare an Identifier with Conflicting Linkage Classifications

Do not give the same identifier both internal and external linkage in one translation unit. Keep all declarations consistent with the identifier's intended linkage.

### DCL37-C: Do Not Declare or Define a Reserved Identifier

Avoid identifiers reserved to the implementation, including names beginning with an underscore at file scope, names beginning with two underscores or underscore-uppercase, and reserved standard-library names and patterns.

### DCL38-C: Use the Correct Syntax When Declaring a Flexible Array Member

Declare a flexible array as the final member of a structure using an incomplete array type such as `data[]`. Do not emulate it with a zero-length or one-element array.

### DCL39-C: Avoid Information Leakage When Passing a Structure Across a Trust Boundary

Do not copy raw structures across trust boundaries when padding bytes or padding bits may contain sensitive data. Serialize members individually or use a validated representation with explicit padding.

### DCL40-C: Do Not Create Incompatible Declarations of the Same Function or Object

Use compatible types for every declaration and definition of an object or function across all translation units. Put shared declarations in headers to prevent signature drift.

### DCL41-C: Do Not Declare Variables Inside a `switch` Statement Before the First `case` Label

Move declarations and executable statements that must run before dispatch outside the `switch`. Control jumps directly to a label and can bypass initialization inside the switch body.

---

## 4. Expressions (EXP)

### EXP30-C: Do Not Depend on the Order of Evaluation for Side Effects

Do not modify an object more than once, or modify and independently read it, in unsequenced subexpressions. Evaluate side-effecting operations in separate statements and explicitly order function calls that share state.

### EXP32-C: Do Not Access a Volatile Object Through a Nonvolatile Reference

Preserve `volatile` qualification through every pointer and lvalue used to access a volatile object. Access through a nonvolatile lvalue is undefined behavior.

### EXP33-C: Do Not Read Uninitialized Memory

Initialize automatic objects and newly allocated storage before reading them. Remember that `malloc()` and newly added `realloc()` bytes are uninitialized, whereas `calloc()` zero-initializes its allocation.

### EXP34-C: Do Not Dereference Null Pointers

Validate pointers before dereferencing them or using them in pointer arithmetic. Check allocation and library-call results before any access.

### EXP35-C: Do Not Modify Objects with Temporary Lifetime

Store a returned structure or union in a named object before modifying an array member within it. Do not retain access to temporary objects after their full expression ends.

### EXP36-C: Do Not Cast Pointers into More Strictly Aligned Pointer Types

Do not convert a pointer to a type with stricter alignment unless the address is known to satisfy that alignment. Use `memcpy()` to move potentially unaligned data into an aligned object.

### EXP37-C: Call Functions with the Correct Number and Type of Arguments

Keep a compatible prototype in scope and supply exactly the expected argument count and types. This is especially important for function pointers and variadic functions.

### EXP39-C: Do Not Access a Variable Through a Pointer of an Incompatible Type

Respect effective-type and strict-aliasing rules. Access an object only through a compatible type, a permitted signed or unsigned counterpart, an appropriate aggregate, or a character type.

### EXP40-C: Do Not Modify Constant Objects

Do not cast away `const` and write through the resulting lvalue. If an object must change, define it as modifiable from the outset.

### EXP42-C: Do Not Compare Padding Data

Compare structure members individually rather than comparing an entire structure with `memcmp()`. Padding bytes can have unspecified values even when all named members are equal.

### EXP43-C: Avoid Undefined Behavior When Using `restrict`-Qualified Pointers

Honor the non-aliasing contract of `restrict`. Do not access a modified object through competing unrelated pointers, and use `memmove()` rather than `memcpy()` for overlapping regions.

### EXP44-C: Do Not Rely on Side Effects in Operands to `sizeof`, `_Alignof`, or `_Generic`

Keep side effects outside unevaluated operands. Whether a variable-length-array size expression is evaluated by `sizeof` can also be unspecified in some cases.

### EXP45-C: Do Not Perform Assignments in Selection Statements

Avoid assignments in controlling expressions where `==` may have been intended. When assignment is intentional, make it explicit and compare its result in a clearly parenthesized expression.

### EXP46-C: Do Not Use a Bitwise Operator with a Boolean-Like Operand

Use logical operators (`&&`, `||`) for Boolean conditions. Do not mix `&`, `|`, or `^` with `_Bool`, relational results, or equality results unless the bitwise operation is deliberate and clearly parenthesized.

---

## 5. Integers (INT)

### INT30-C: Ensure That Unsigned Integer Operations Do Not Wrap

Check addition, subtraction, multiplication, increment, decrement, and left shifts before using their results in sizes, indexes, pointer arithmetic, or security decisions. Permit modulo arithmetic only when it is intentional and documented.

### INT31-C: Ensure That Integer Conversions Do Not Result in Lost or Misinterpreted Data

Validate source values against the destination range before narrowing or changing signedness. A cast suppresses diagnostics but does not make an out-of-range conversion safe.

### INT32-C: Ensure That Operations on Signed Integers Do Not Result in Overflow

Guard signed addition, subtraction, multiplication, division, remainder, shifts, and negation before evaluating them. Signed overflow is undefined behavior.

### INT33-C: Ensure That Division and Remainder Operations Do Not Result in Divide-by-Zero Errors

Verify that the divisor is nonzero before `/` or `%`. For signed values, also reject division or remainder of the minimum value by `-1` when that operation overflows.

### INT34-C: Do Not Shift by a Negative Amount or by an Amount Greater Than or Equal to the Operand Precision

Validate shift counts before shifting and prefer unsigned operands. For signed left shifts, also ensure the left operand is nonnegative and the result remains representable.

### INT35-C: Use Correct Integer Precisions

Do not infer an integer type's precision solely from `sizeof(type) * CHAR_BIT`, because a representation may contain padding bits. Use documented implementation limits or a validated precision calculation.

### INT36-C: Converting a Pointer to Integer or Integer to Pointer

Avoid pointer-integer conversions unless required by the platform. When supported, use `intptr_t` or `uintptr_t` for round trips, and do not encode unrelated flags into pointer bits.

---

## 6. Floating Point (FLP)

### FLP30-C: Do Not Use Floating-Point Variables as Loop Counters

Use an integer induction variable and derive floating-point values from it. Rounding can cause a floating-point loop to execute the wrong number of times or never terminate.

### FLP32-C: Prevent or Detect Domain and Range Errors in Math Functions

Validate function domains before calls such as `sqrt()`, `log()`, and `pow()`. Detect range, pole, overflow, and underflow errors using the implementation's `math_errhandling`, floating-point exceptions, and `errno` behavior.

### FLP34-C: Ensure That Floating-Point Conversions Are Within Range of the New Type

Before converting floating-point values to integers or narrower floating types, verify that the value is finite and representable in the destination range. Also validate integer-to-floating conversions when the floating type may not represent the range.

### FLP36-C: Preserve Precision When Converting Integral Values to Floating-Point Type

Use a floating type with enough significand precision when an exact integer value must be preserved. Confirm the required precision with implementation limits or static assertions.

### FLP37-C: Do Not Use Object Representations to Compare Floating-Point Values

Do not compare floating-point storage with `memcmp()`. Compare values and surrounding structure members individually because equal values can have different representations and NaNs have special equality behavior.

---

## 7. Arrays (ARR)

### ARR30-C: Do Not Form or Use Out-of-Bounds Pointers or Array Subscripts

Validate every index and offset before pointer arithmetic or subscripting. A pointer may be formed one past an array for comparison, but it must not be dereferenced.

### ARR32-C: Ensure Size Arguments for Variable Length Arrays Are in a Valid Range

Require VLA bounds to be positive and reasonably limited, and prevent size computations from wrapping. Prefer fixed or dynamically allocated storage when the size is large or untrusted.

### ARR36-C: Do Not Subtract or Compare Two Pointers That Do Not Refer to the Same Array

Relational comparison and subtraction are valid only for pointers into the same array object, including its one-past pointer. Equality comparison remains valid for unrelated pointers.

### ARR37-C: Do Not Add or Subtract an Integer to a Pointer to a Non-Array Object

Perform pointer arithmetic only within arrays. Do not walk across structure members as though they formed an array; define an actual array when iteration is required.

### ARR38-C: Guarantee That Library Functions Do Not Form Invalid Pointers

For every library call that accepts a pointer and size, ensure the complete addressed range lies within the object. Express sizes in the element units expected by the function and prevent size products from wrapping.

### ARR39-C: Do Not Add or Subtract a Scaled Integer to a Pointer

Remember that pointer arithmetic already scales by the pointed-to type. Use element counts with typed pointers and byte counts only with character pointers.

---

## 8. Characters and Strings (STR)

### STR30-C: Do Not Attempt to Modify String Literals

Treat string literals and pointers derived from them as read-only. Use a writable array initialized from a literal when modification is required.

### STR31-C: Guarantee That Storage for Strings Has Sufficient Space for Character Data and the Null Terminator

Allocate or reserve enough space for all characters plus the terminating null character. Bound input and formatting operations, and detect truncation where it is not acceptable.

### STR32-C: Do Not Pass a Non-Null-Terminated Character Sequence to a Library Function That Expects a String

Guarantee null termination before calling string APIs. Be especially careful after `strncpy()` and after shrinking a buffer with `realloc()`.

### STR34-C: Cast Characters to `unsigned char` Before Converting to Larger Integer Sizes

Convert potentially negative `char` or `signed char` data to `unsigned char` before promotion. This prevents sign extension from producing invalid indexes or confusing byte values with `EOF`.

### STR37-C: Arguments to Character-Handling Functions Must Be Representable as `unsigned char`

Pass either `EOF` or a value converted through `unsigned char` to functions from `<ctype.h>`. Passing a negative plain `char` value is undefined behavior.

### STR38-C: Do Not Confuse Narrow and Wide Character Strings and Functions

Use narrow-string functions for `char` strings and wide-string functions for `wchar_t` strings. Compute capacities in the element units expected by each API.

---

## 9. Memory Management (MEM)

### MEM30-C: Do Not Access Freed Memory

Stop using every pointer into an allocation after `free()` or a successful moving `realloc()`. Preserve any required links or data before deallocation and prevent double frees.

### MEM31-C: Free Dynamically Allocated Memory When No Longer Needed

Pair each successful allocation with an appropriate deallocation before the last owning pointer is lost, unless the allocation intentionally persists for the program's lifetime.

### MEM33-C: Allocate and Copy Structures Containing a Flexible Array Member Dynamically

Allocate enough dynamic storage for the structure and its flexible array. Pass it by pointer and copy the complete allocated representation rather than using structure assignment or pass-by-value.

### MEM34-C: Only Free Memory Allocated Dynamically

Pass `free()` or `realloc()` only a null pointer or a pointer returned by a compatible allocation function that has not already been freed.

### MEM35-C: Allocate Sufficient Memory for an Object

Calculate allocation sizes from the pointed-to type, preferably with `sizeof(*pointer)`, and check multiplication and addition for overflow before allocating arrays or flexible structures.

### MEM36-C: Do Not Modify the Alignment of Objects by Calling `realloc()`

Do not use ordinary `realloc()` on storage requiring extended alignment. Allocate a new suitably aligned block, copy the data, and free the old block, or use a platform reallocation API that preserves alignment.

---

## 10. Input/Output (FIO)

### FIO30-C: Exclude User Input from Format Strings

Use fixed format strings and pass untrusted text as data arguments. Never allow user-controlled data to become a `printf`, `scanf`, or logging format string.

### FIO32-C: Do Not Perform Operations on Devices That Are Only Appropriate for Files

Verify that a path identifies an expected regular file before applying regular-file operations. Account for device names, special files, links, blocking behavior, and race conditions on the target platform.

### FIO34-C: Distinguish Between Characters Read from a File and `EOF` or `WEOF`

Store byte-input results in `int` and wide-input results in `wint_t`. After an end indicator, use `feof()` and `ferror()` where a valid character might be indistinguishable from the sentinel.

### FIO37-C: Do Not Assume That `fgets()` or `fgetws()` Returns a Nonempty String When Successful

Input can begin with a null character. Search for a newline safely rather than indexing `strlen(buffer) - 1` without first proving the string is nonempty.

### FIO38-C: Do Not Copy a `FILE` Object

Copy and pass pointers to `FILE`, not the `FILE` object itself. A copied stream object is not required to work in place of the original.

### FIO39-C: Do Not Alternately Input and Output from a Stream Without an Intervening Flush or Positioning Call

When using an update stream, follow output with `fflush()` or a positioning call before input, and follow input with a positioning call before output unless end-of-file was reached.

### FIO40-C: Reset Strings on `fgets()` or `fgetws()` Failure

If a failed read buffer will remain in use, reset it to a known empty string before any later string operation.

### FIO41-C: Do Not Call `getc()`, `putc()`, `getwc()`, or `putwc()` with a Stream Argument That Has Side Effects

Evaluate the stream expression separately before passing it to these functions because an implementation may define them as macros that evaluate the stream argument more than once.

### FIO42-C: Close Files When They Are No Longer Needed

Match every successful open with the corresponding close and check the close result when buffered output or resource release can fail.

### FIO44-C: Only Use Values for `fsetpos()` That Are Returned from `fgetpos()`

Restore a stream position only from a successful `fgetpos()` call on a stream associated with the same file. Do not manufacture or zero-initialize an `fpos_t` value.

### FIO45-C: Avoid TOCTOU Race Conditions While Accessing Files

Avoid separate path-based check and use operations. Prefer atomic open modes such as C11 `x` or POSIX `O_CREAT | O_EXCL`, secure directories, and descriptor-based verification.

### FIO46-C: Do Not Access a Closed File

Do not use a stream pointer, descriptor, or handle after it has been closed. This includes implicit uses of closed standard streams by functions such as `printf()` or `getc()`.

### FIO47-C: Use Valid Format Strings

Match every conversion specification to the number and promoted type of its argument. Use only valid combinations of flags, widths, precisions, length modifiers, and conversion specifiers.

---

## 11. Environment (ENV)

### ENV30-C: Do Not Modify the Object Referenced by the Return Value of Certain Functions

Treat objects returned by `getenv()`, `setlocale()`, `localeconv()`, `asctime()`, and `strerror()` as read-only. Make a copy before modification.

### ENV31-C: Do Not Rely on an Environment Pointer Following an Operation That May Invalidate It

Do not continue using the nonstandard `envp` argument after modifying the environment. Use the platform's current environment interface or reacquire the needed value.

### ENV32-C: All Exit Handlers Must Return Normally

Functions registered with `atexit()` or `at_quick_exit()` must complete by returning. Do not call an exit function recursively or use `longjmp()` to escape an exit handler.

### ENV33-C: Do Not Call `system()`

Avoid command processors such as `system()`, `popen()`, and `_popen()`. Use direct library operations or process-creation APIs with explicit executable paths, arguments, and sanitized environments.

### ENV34-C: Do Not Store Pointers Returned by Certain Functions

Immediately copy data returned by functions whose internal storage may be overwritten, including `getenv()`, `localeconv()`, `setlocale()`, `strerror()`, and `asctime()`, when it must survive later calls.

---

## 12. Signals (SIG)

### SIG30-C: Call Only Asynchronous-Safe Functions Within Signal Handlers

Keep handlers minimal and call only functions documented as asynchronous-signal-safe for every target. A portable handler should generally set a `volatile sig_atomic_t` flag and return.

### SIG31-C: Do Not Access Shared Objects in Signal Handlers

Access only lock-free atomic objects or `volatile sig_atomic_t` objects shared with normal execution. Access to other static or thread-storage objects from an asynchronous handler is undefined.

### SIG34-C: Do Not Call `signal()` from Within Interruptible Signal Handlers

Do not reinstall a handler from inside itself when another occurrence could interrupt the operation. On POSIX systems, configure persistent handling and signal masks with `sigaction()`.

### SIG35-C: Do Not Return from a Computational Exception Signal Handler

Do not return from handlers for signals such as `SIGFPE`, `SIGILL`, `SIGSEGV`, or equivalent computational exceptions. Terminate safely using an allowed mechanism.

---

## 13. Error Handling (ERR)

### ERR30-C: Set `errno` to Zero Before Calling a Library Function Known to Set It, and Check It Only After Failure

Use a function's return value as the primary error indicator. Set `errno` to zero first only for functions with ambiguous in-band error returns, then inspect it immediately when the documented return indicates possible failure.

### ERR32-C: Do Not Rely on Indeterminate Values of `errno`

Do not inspect `errno` after a signal handler leaves it indeterminate. POSIX handlers that call functions capable of changing `errno` should save and restore its prior value.

### ERR33-C: Detect and Handle Standard Library Errors

Check every fallible standard-library operation and take a defined action on failure. Do not continue with null pointers, invalid positions, partial I/O, uninitialized output, or lost `realloc()` ownership.

---

## 14. Concurrency (CON)

### CON30-C: Clean Up Thread-Specific Storage

Free thread-specific allocations before thread termination, preferably by registering a destructor when the storage key is created.

### CON31-C: Do Not Destroy a Mutex While It Is Locked

Initialize a mutex before publishing it and destroy it only after all users have completed and no thread holds or waits for it.

### CON32-C: Prevent Data Races When Accessing Bit-Fields from Multiple Threads

Adjacent bit-fields can share one memory location. Protect all accesses with the same mutex or separate concurrently modified flags into distinct non-bit-field objects.

### CON33-C: Avoid Race Conditions When Using Library Functions

Do not concurrently use library functions with shared internal state or shared return buffers. Use thread-safe variants or serialize access.

### CON34-C: Declare Objects Shared Between Threads with Appropriate Storage Durations

Ensure shared objects outlive every thread that accesses them. Prefer static or allocated storage and explicit synchronization over publishing pointers to another thread's automatic or thread-local objects.

### CON35-C: Avoid Deadlock by Locking in a Predefined Order

Establish and enforce one total ordering for acquiring multiple locks. Release locks reliably on every path.

### CON36-C: Wrap Functions That Can Spuriously Wake Up in a Loop

Call `cnd_wait()` and `cnd_timedwait()` inside a loop that rechecks the protected condition predicate after every wakeup.

### CON37-C: Do Not Call `signal()` in a Multithreaded Program

Standard C defines this combination as undefined. Use atomic communication between threads or a platform-defined signal model such as POSIX when its requirements are explicitly followed.

### CON38-C: Preserve Thread Safety and Liveness When Using Condition Variables

Test the predicate before and after waiting. Use broadcast when different waiters have different predicates, or give each waiter a condition variable that can be signaled precisely.

### CON39-C: Do Not Join or Detach a Thread That Was Previously Joined or Detached

Choose one ownership action for each thread: join it once or detach it once. Repeating or mixing these actions is undefined behavior.

### CON40-C: Do Not Refer to an Atomic Variable Twice in an Expression

Load an atomic value once into a local snapshot when one consistent value is required. Use atomic read-modify-write or compare-exchange operations for compound updates.

### CON41-C: Wrap Functions That Can Fail Spuriously in a Loop

Retry weak compare-exchange operations when failure may be spurious, or use a strong compare-exchange when a retry loop is inappropriate.

---

## 15. Miscellaneous (MSC)

### MSC30-C: Do Not Use `rand()` for Generating Pseudorandom Numbers

Use a generator whose statistical and unpredictability properties meet the application requirements. Use an operating-system or cryptographic random source for security-sensitive values.

### MSC32-C: Properly Seed Pseudorandom Number Generators

Seed deterministic generators with sufficient, nonrepeating entropy before use. Do not rely on default seeds or predictable time-only seeds for security protocols.

### MSC33-C: Do Not Pass Invalid Data to the `asctime()` Function

Avoid obsolete `asctime()` interfaces because out-of-range `struct tm` members can overflow their fixed buffer. Prefer `strftime()` or a validated bounds-checking alternative.

### MSC37-C: Ensure That Control Never Reaches the End of a Non-`void` Function

Return a valid value or transfer control on every path through a non-`void` function. The special exception is reaching the end of `main()`, which returns zero.

### MSC38-C: Do Not Treat a Predefined Identifier as an Object If It Might Only Be Implemented as a Macro

Do not suppress or take the address of standard macros such as `assert`, `errno`, `math_errhandling`, `setjmp`, or the `va_*` macros. Wrap macro behavior in a helper function when a function pointer is required.

### MSC39-C: Do Not Call `va_arg()` on a `va_list` That Has an Indeterminate Value

Use `va_copy()` when another function must traverse a variable-argument list, and pair every initialization or copy with `va_end()`. Do not reuse a list after a callee has consumed it unless the interface preserves it correctly.

### MSC40-C: Do Not Violate Constraints

Treat every compiler diagnostic for a syntax or language constraint violation as a required correction. Translation may continue after a diagnostic, but the resulting program is not valid C.