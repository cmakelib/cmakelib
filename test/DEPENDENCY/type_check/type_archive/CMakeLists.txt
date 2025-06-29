## TYPE=ARCHIVE Test
#
# Test DEPENDENCY with TYPE=ARCHIVE by creating and extracting a ZIP archive
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
    PROJECT(CMLIB_DEPENDENCY_TYPE_ARCHIVE_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../")
FIND_PACKAGE(CMLIB)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../test_resources/test_resources.cmake")

TEST_RESOURCES_GET_BASE_DIR(test_resources_base)
SET(RESOURCES_DIR "${test_resources_base}/resources")
SET(TEST_ARCHIVE "${CMAKE_CURRENT_BINARY_DIR}/test_resources.zip")

# Create ZIP archive from test resources directory
EXECUTE_PROCESS(
    COMMAND ${CMAKE_COMMAND} -E tar "cf" "${TEST_ARCHIVE}" --format=zip .
    WORKING_DIRECTORY "${RESOURCES_DIR}"
    RESULT_VARIABLE archive_result
)

IF(NOT archive_result EQUAL 0)
    MESSAGE(FATAL_ERROR "Failed to create test archive")
ENDIF()

SET(FILE_URI "file://${TEST_ARCHIVE}")

CMLIB_DEPENDENCY(
    TYPE ARCHIVE
    URI "${FILE_URI}"
    OUTPUT_PATH_VAR extracted_dir
)

# Verify extraction worked
IF(NOT EXISTS "${extracted_dir}/TEST_MODULE.cmake")
    MESSAGE(FATAL_ERROR "Archive extraction failed - TEST_MODULE.cmake not found")
ENDIF()
IF(NOT EXISTS "${extracted_dir}/README.md")
    MESSAGE(FATAL_ERROR "Archive extraction failed - README.md not found")
ENDIF()