## HTTP URI Download Test
#
# Verify DEPENDENCY can download files using HTTP URIs
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
    PROJECT(CMLIB_DEPENDENCY_HTTP_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../")
FIND_PACKAGE(CMLIB)
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../transform_git_uri.cmake")

TRANSFORM_GIT_URI_TO_HTTPS(
    URI "${CMLIB_REQUIRED_ENV_REMOTE_URL}/cmakelib-test/archive/v1.0.0.zip"
    OUTPUT_VAR HTTP_URI
)

CMLIB_DEPENDENCY(
    TYPE FILE
    URI "${HTTP_URI}"
    OUTPUT_PATH_VAR output_path
)

IF(NOT EXISTS "${output_path}")
    MESSAGE(FATAL_ERROR "HTTP URI download failed - output file does not exist: ${output_path}")
ENDIF()
