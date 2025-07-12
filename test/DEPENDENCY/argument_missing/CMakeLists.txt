## Main
#
# Check if the DEPENDENCY emits an error if
# OUTPUT_PATH_VAR is missing for TYPE=FILE.
#
# We test this only for FILE type. (it's not necessary to
# test for all types. We add these tests if needed)
#
# TEST must FAIL
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(CMLIB_DEPENDENCY_ARGUMENT_MISSING_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../")
FIND_PACKAGE(CMLIB)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../test_resources/test_resources.cmake")

# Use a unique file URI to avoid cache conflicts
TEST_RESOURCES_GET_FILE_URI("README.md" FILE_URI)

CMLIB_DEPENDENCY(
    TYPE FILE
    URI "${FILE_URI}"
    # OUTPUT_PATH_VAR is intentionally missing to trigger the error
)
