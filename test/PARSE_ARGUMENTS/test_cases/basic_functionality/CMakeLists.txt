##
#
# Test CMLIB_PARSE_ARGUMENTS basic functionality including PREFIX parameter behavior,
# default prefix handling, and fundamental argument parsing scenarios with single
# and multiple argument types.
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(CMLIB_PARSE_ARGUMENTS_BASIC_FUNCTIONALITY_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../")
FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")

FUNCTION(TEST_PREFIX_FUNCTIONALITY)
	CMLIB_PARSE_ARGUMENTS(
		PREFIX CUSTOM_
		ONE_VALUE TEST_VALUE
		REQUIRED TEST_VALUE
		P_ARGN
			TEST_VALUE "custom_test"
	)

	TEST_VAR_DEFINED(CUSTOM__TEST_VALUE)
	TEST_VAR_EQUALS_LITERAL(CUSTOM__TEST_VALUE "custom_test")

	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE TEST_VALUE2
		REQUIRED TEST_VALUE2
		P_ARGN
			TEST_VALUE2 "default_test"
	)

	TEST_VAR_DEFINED(__TEST_VALUE2)
	TEST_VAR_EQUALS_LITERAL(__TEST_VALUE2 "default_test")

	CMLIB_PARSE_ARGUMENTS(
		PREFIX ""
		ONE_VALUE TEST_VALUE3
		REQUIRED TEST_VALUE3
		P_ARGN
			TEST_VALUE3 "empty_prefix_test"
	)

	TEST_VAR_DEFINED(__TEST_VALUE3)
	TEST_VAR_EQUALS_LITERAL(__TEST_VALUE3 "empty_prefix_test")
ENDFUNCTION()

FUNCTION(TEST_PREFIX_EDGE_CASES)
	CMLIB_PARSE_ARGUMENTS(
		PREFIX PREFIX_123_
		ONE_VALUE TEST_VALUE
		REQUIRED TEST_VALUE
		P_ARGN
			TEST_VALUE "special_test"
	)

	TEST_VAR_DEFINED(PREFIX_123__TEST_VALUE)
	TEST_VAR_EQUALS_LITERAL(PREFIX_123__TEST_VALUE "special_test")

	SET(LONG_PREFIX "VERY_LONG_PREFIX_STRING_THAT_EXCEEDS_FIFTY_CHARACTERS_")
	CMLIB_PARSE_ARGUMENTS(
		PREFIX ${LONG_PREFIX}
		ONE_VALUE TEST_VALUE
		REQUIRED TEST_VALUE
		P_ARGN
			TEST_VALUE "long_prefix_test"
	)

	TEST_VAR_DEFINED(${LONG_PREFIX}_TEST_VALUE)
	TEST_VAR_EQUALS_LITERAL(${LONG_PREFIX}_TEST_VALUE "long_prefix_test")
ENDFUNCTION()

FUNCTION(TEST_BASIC_ARGUMENT_PARSING)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE SIMPLE_ARG
		REQUIRED SIMPLE_ARG
		P_ARGN
			SIMPLE_ARG "simple_value"
	)

	TEST_VAR_DEFINED(__SIMPLE_ARG)
	TEST_VAR_EQUALS_LITERAL(__SIMPLE_ARG "simple_value")

	CMLIB_PARSE_ARGUMENTS(
		OPTIONS ENABLE_FEATURE
		ONE_VALUE CONFIG_FILE
		MULTI_VALUE SOURCE_FILES
		REQUIRED CONFIG_FILE SOURCE_FILES
		P_ARGN
			ENABLE_FEATURE ON
			CONFIG_FILE "config.txt"
			SOURCE_FILES "file1.cpp" "file2.cpp"
	)

	TEST_VAR_TRUE(__ENABLE_FEATURE)
	TEST_VAR_EQUALS_LITERAL(__CONFIG_FILE "config.txt")
	TEST_VAR_DEFINED(__SOURCE_FILES)

	LIST(LENGTH __SOURCE_FILES source_count)
	SET(expected_count 2)
	TEST_VAR_EQUAL(source_count expected_count)

	LIST(GET __SOURCE_FILES 0 first_file)
	TEST_VAR_EQUALS_LITERAL(first_file "file1.cpp")
ENDFUNCTION()



TEST_PREFIX_FUNCTIONALITY()
TEST_PREFIX_EDGE_CASES()
TEST_BASIC_ARGUMENT_PARSING()
