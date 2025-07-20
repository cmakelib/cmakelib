## Caller script for Warning Test Case 2
#
# This script calls TEST_RUN_AND_CHECK_OUTPUT expecting a warning,
# but the project produces no warning, so it should fail.
#

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../../")
FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../TEST.cmake")

TEST_RUN_AND_CHECK_OUTPUT("test_output_warning_should_fail_missing"
	WARNING_MESSAGE "Test warning message")
