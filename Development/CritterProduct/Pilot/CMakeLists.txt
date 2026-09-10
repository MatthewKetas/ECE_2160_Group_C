cmake_minimum_required(VERSION 3.16)

project(Pilot LANGUAGES C)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

add_library(Pilot_core STATIC
    "Computation/critter_computation.c"
    "IO/critter_io.c"
    "Memory/critter_memory.c"
    "../../../Utils/SenseHat/sense_hat_environment.c"
)

target_include_directories(Pilot_core PUBLIC
    "${CMAKE_CURRENT_SOURCE_DIR}"
    "${CMAKE_CURRENT_SOURCE_DIR}/Computation"
    "${CMAKE_CURRENT_SOURCE_DIR}/IO"
    "${CMAKE_CURRENT_SOURCE_DIR}/Memory"
    "${CMAKE_CURRENT_SOURCE_DIR}/."
    "${CMAKE_CURRENT_SOURCE_DIR}/../../../Utils/SenseHat"
)

target_link_libraries(Pilot_core PUBLIC m)

add_executable(Pilot
    "main.c"
)

target_link_libraries(Pilot PRIVATE Pilot_core)

add_executable(test_memory_computation
    "tests/test_memory_computation.c"
)

add_executable(test_data_fallback
    "tests/test_data_fallback.c"
)

add_executable(test_internal_temperature
    "tests/test_internal_temperature.c"
)

add_executable(test_io_get_temperature_fallback
    "tests/test_io_get_temperature_fallback.c"
)

add_executable(test_io_get_temperature_sources
    "tests/test_io_get_temperature_sources.c"
)

target_link_libraries(test_memory_computation PRIVATE Pilot_core)
target_link_libraries(test_data_fallback PRIVATE Pilot_core)
target_link_libraries(test_internal_temperature PRIVATE Pilot_core)
target_link_libraries(test_io_get_temperature_fallback PRIVATE Pilot_core)
target_link_libraries(test_io_get_temperature_sources PRIVATE Pilot_core)
target_compile_definitions(test_data_fallback PRIVATE
    DATA_FILE_PATH="${CMAKE_CURRENT_SOURCE_DIR}/Data/temperature_samples.csv"
)

enable_testing()

add_test(NAME test_memory_computation COMMAND test_memory_computation)
add_test(NAME test_data_fallback COMMAND test_data_fallback)
add_test(NAME test_internal_temperature COMMAND test_internal_temperature)
add_test(NAME test_io_get_temperature_fallback COMMAND test_io_get_temperature_fallback)
add_test(NAME test_io_get_temperature_sources COMMAND test_io_get_temperature_sources)

