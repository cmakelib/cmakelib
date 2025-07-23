## Test Cache Variable Functions
#
# Tests all cache_var.cmake functions: CACHE_VAR_FORCE_SET, CACHE_VAR_FORCE_UNSET, CACHE_VAR_RESTORE
# Each test runs in its own isolated CMake context to prevent state contamination.
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(TEST_CACHE_VAR_FUNCTIONS)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../")
FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../TEST.cmake")

TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/force_set_undefined")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/force_set_defined")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/force_unset_defined")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/force_unset_undefined")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/restore_originally_defined")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/restore_originally_undefined")

TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/fail_restore_never_stored")


