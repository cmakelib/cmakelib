##
#
# Test CMLIB_PARSE_ARGUMENTS_CLEANUP functionality including memory management,
# internal variable cleanup, reusability after cleanup, cleanup between multiple
# parsing calls, and scope handling in function vs macro contexts.
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(CMLIB_PARSE_ARGUMENTS_CLEANUP_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../")
FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/cleanup_test_macros.cmake")

FUNCTION(TEST_MEMORY_MANAGEMENT)
	CLEANUP_TEST_MACRO()
ENDFUNCTION()

FUNCTION(TEST_REUSABILITY)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE FIRST_VALUE
		REQUIRED FIRST_VALUE
		P_ARGN
			FIRST_VALUE "first_call"
	)

	TEST_VAR_EQUALS_LITERAL(__FIRST_VALUE "first_call")

	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE SECOND_VALUE
		OPTIONS SECOND_OPTION
		REQUIRED SECOND_VALUE
		P_ARGN
			SECOND_VALUE "second_call"
			SECOND_OPTION ON
	)

	TEST_VAR_EQUALS_LITERAL(__SECOND_VALUE "second_call")
	TEST_VAR_TRUE(__SECOND_OPTION)

	TEST_VAR_EQUALS_LITERAL(__FIRST_VALUE "first_call")
ENDFUNCTION()

FUNCTION(TEST_CLEANUP_BETWEEN_CALLS)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE TEST_VALUE1
		REQUIRED TEST_VALUE1
		P_ARGN
			TEST_VALUE1 "before_cleanup"
	)

	TEST_VAR_EQUALS_LITERAL(__TEST_VALUE1 "before_cleanup")

	CMLIB_PARSE_ARGUMENTS_CLEANUP()

	TEST_VAR_EQUALS_LITERAL(__TEST_VALUE1 "before_cleanup")

	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE TEST_VALUE2
		REQUIRED TEST_VALUE2
		P_ARGN
			TEST_VALUE2 "after_cleanup"
	)

	TEST_VAR_EQUALS_LITERAL(__TEST_VALUE2 "after_cleanup")
	TEST_VAR_EQUALS_LITERAL(__TEST_VALUE1 "before_cleanup")
ENDFUNCTION()

FUNCTION(TEST_SCOPE_HANDLING)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE FUNCTION_VALUE
		REQUIRED FUNCTION_VALUE
		P_ARGN
			FUNCTION_VALUE "function_context"
	)

	TEST_VAR_EQUALS_LITERAL(__FUNCTION_VALUE "function_context")

	CMLIB_PARSE_ARGUMENTS_CLEANUP()

	TEST_VAR_EQUALS_LITERAL(__FUNCTION_VALUE "function_context")
ENDFUNCTION()

TEST_MEMORY_MANAGEMENT()
TEST_REUSABILITY()
TEST_CLEANUP_BETWEEN_CALLS()
TEST_SCOPE_HANDLING()
