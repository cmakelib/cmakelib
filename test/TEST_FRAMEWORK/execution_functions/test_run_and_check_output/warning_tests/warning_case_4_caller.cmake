## Caller script for Warning Test Case 4
#
# This script calls TEST_RUN_AND_CHECK_OUTPUT expecting a warning,
# but the project fails after producing the warning, so it should fail
# because warnings require the project to succeed.
#

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../../")
FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../TEST.cmake")

TEST_RUN_AND_CHECK_OUTPUT("test_output_warning_should_fail_project_fails"
	WARNING_MESSAGE "Test warning message")
