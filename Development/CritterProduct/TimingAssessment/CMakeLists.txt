cmake_minimum_required(VERSION 3.16)
project(CritterTimingAssessment LANGUAGES C)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)
set(PILOT "${CMAKE_CURRENT_SOURCE_DIR}/../Pilot")
set(UTILS "${CMAKE_CURRENT_SOURCE_DIR}/../../../Utils/SenseHat")
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    set(SENSOR_SOURCE "${UTILS}/sense_hat_environment.c")
else()
    set(SENSOR_SOURCE tests/sensor_unavailable.c)
    message(STATUS "Non-Linux build: hardware sensor unavailable; use --source data")
endif()
add_executable(CritterTiming main.c
    "${PILOT}/IO/critter_io.c"
    "${PILOT}/Memory/critter_memory.c"
    "${PILOT}/Computation/critter_computation.c"
    "${SENSOR_SOURCE}")
target_include_directories(CritterTiming PRIVATE "${PILOT}" "${UTILS}")
target_compile_options(CritterTiming PRIVATE -Wall -Wextra -Wpedantic)
target_link_libraries(CritterTiming PRIVATE m)

enable_testing()
add_executable(test_timing_io tests/test_io_paths.c "${PILOT}/IO/critter_io.c" "${SENSOR_SOURCE}")
target_include_directories(test_timing_io PRIVATE "${PILOT}" "${UTILS}")
add_test(NAME timing_io_paths COMMAND test_timing_io)
add_executable(test_timing_memory "${PILOT}/tests/test_memory_computation.c"
    "${PILOT}/Memory/critter_memory.c" "${PILOT}/Computation/critter_computation.c")
target_include_directories(test_timing_memory PRIVATE "${PILOT}")
target_link_libraries(test_timing_memory PRIVATE m)
add_test(NAME pilot_memory_computation COMMAND test_timing_memory)

# Keep the instructor's source unchanged; record its hash and compile with -O0.
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/workload/matrixmult.c")
    add_executable(matrixmult workload/matrixmult.c)
    target_compile_options(matrixmult PRIVATE -O0)
    target_link_libraries(matrixmult PRIVATE m)
endif()
