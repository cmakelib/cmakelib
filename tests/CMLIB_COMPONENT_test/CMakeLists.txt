# CMakeLists.txt for CMLIB_COMPONENT tests
# Following the project's existing test structure
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.10)
PROJECT(CMLIB_COMPONENT_Tests)

# Enable testing
ENABLE_TESTING()

# Add unit tests
ADD_TEST(
    NAME CMLIB_COMPONENT_Unit_Tests
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_SOURCE_DIR}/test_CMLIB_COMPONENT.cmake
)

# Add integration tests
ADD_TEST(
    NAME CMLIB_COMPONENT_Integration_Tests
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_SOURCE_DIR}/test_CMLIB_COMPONENT_integration.cmake
)

# Add combined test run
ADD_TEST(
    NAME CMLIB_COMPONENT_All_Tests
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_SOURCE_DIR}/run_tests.cmake
)

# Set test properties
SET_TESTS_PROPERTIES(
    CMLIB_COMPONENT_Unit_Tests
    CMLIB_COMPONENT_Integration_Tests
    CMLIB_COMPONENT_All_Tests
    PROPERTIES
    TIMEOUT 300
    FAIL_REGULAR_EXPRESSION "ASSERTION FAILED"
)

# Create a custom target to run all tests
ADD_CUSTOM_TARGET(
    run_all_tests
    COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_SOURCE_DIR}/run_tests.cmake
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Running all CMLIB_COMPONENT tests"
)