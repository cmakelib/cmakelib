## Caller script for Fatal Error Test Case 2
#
# This script calls TEST_RUN_AND_CHECK_OUTPUT expecting a fatal error,
# but the project succeeds without any fatal error, so it should fail.
#

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../../")
FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../TEST.cmake")

TEST_RUN_AND_CHECK_OUTPUT("should_fail_missing"
	FATAL_ERROR_MESSAGE "Test fatal error message")
