## File URI Download Test
#
# Verify DEPENDENCY can download files using file:// URIs
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
    PROJECT(CMLIB_DEPENDENCY_FILE_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../")
FIND_PACKAGE(CMLIB)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../test_resources/test_resources.cmake")

TEST_RESOURCES_GET_FILE_URI("TEST_MODULE.cmake" FILE_URI)

CMLIB_DEPENDENCY(
    TYPE FILE
    URI "${FILE_URI}"
    OUTPUT_PATH_VAR output_path
)

IF(NOT EXISTS "${output_path}")
    MESSAGE(FATAL_ERROR "File URI download failed - output file does not exist: ${output_path}")
ENDIF()

FILE(REMOVE_RECURSE "${CMLIB_REQUIRED_ENV_TMP_PATH}")
