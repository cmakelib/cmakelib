#!/usr/bin/env cmake -P
#
# Test runner for CMLIB_COMPONENT tests
# Following the pattern from existing test infrastructure
#
# Usage: cmake -P run_tests.cmake
#

MESSAGE(STATUS "========================================")
MESSAGE(STATUS "CMLIB_COMPONENT Test Suite")
MESSAGE(STATUS "Testing Framework: Custom CMake testing macros")
MESSAGE(STATUS "========================================")

# Set up test environment
SET(CMAKE_CURRENT_SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}")
SET(CMAKE_CURRENT_BINARY_DIR "${CMAKE_CURRENT_LIST_DIR}/build")

# Create build directory
FILE(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")

# Include the actual component being tested
INCLUDE(${CMAKE_CURRENT_SOURCE_DIR}/../../src/CMLIB_COMPONENT.cmake)

# Include and run unit tests
MESSAGE(STATUS "")
MESSAGE(STATUS "Running unit tests...")
MESSAGE(STATUS "")
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/test_CMLIB_COMPONENT.cmake)

# Include and run integration tests
MESSAGE(STATUS "")
MESSAGE(STATUS "Running integration tests...")
MESSAGE(STATUS "")
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/test_CMLIB_COMPONENT_integration.cmake)

MESSAGE(STATUS "")
MESSAGE(STATUS "========================================")
MESSAGE(STATUS "All tests completed successfully!")
MESSAGE(STATUS "========================================")