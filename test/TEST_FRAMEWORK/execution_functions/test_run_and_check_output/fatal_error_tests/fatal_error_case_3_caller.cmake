## Caller script for Fatal Error Test Case 3
#
# This script calls TEST_RUN_AND_CHECK_OUTPUT expecting a specific fatal error,
# but the project produces a different fatal error, so it should fail.
#

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../../")
FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../TEST.cmake")

TEST_RUN_AND_CHECK_OUTPUT("test_output_fatal_should_fail_no_match"
	FATAL_ERROR_MESSAGE "Test fatal error message")
