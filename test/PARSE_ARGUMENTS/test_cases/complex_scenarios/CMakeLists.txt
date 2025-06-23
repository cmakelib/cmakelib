##
#
# Test CMLIB_PARSE_ARGUMENTS complex scenarios including arguments with spaces/quotes,
# special characters handling, long argument lists, mixed argument types in complex
# combinations, and variable substitution with CMake variables and cache variables.
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(CMLIB_PARSE_ARGUMENTS_COMPLEX_SCENARIOS_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../")
FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")

FUNCTION(TEST_SPACES_AND_QUOTES)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE TEST_VALUE
		MULTI_VALUE TEST_MULTI
		REQUIRED TEST_VALUE
		P_ARGN
			TEST_VALUE "value with spaces"
			TEST_MULTI "first value" "second value with spaces" "third"
	)

	TEST_VAR_EQUALS_LITERAL(__TEST_VALUE "value with spaces")

	TEST_VAR_DEFINED(__TEST_MULTI)
	LIST(LENGTH __TEST_MULTI multi_length)
	SET(expected_multi_length 3)
	TEST_VAR_EQUAL(multi_length expected_multi_length)

	LIST(GET __TEST_MULTI 1 second_value)
	TEST_VAR_EQUALS_LITERAL(second_value "second value with spaces")
ENDFUNCTION()

FUNCTION(TEST_SPECIAL_CHARACTERS)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE TEST_VALUE
		MULTI_VALUE TEST_MULTI
		REQUIRED TEST_VALUE
		P_ARGN
			TEST_VALUE "value_with-special.chars"
			TEST_MULTI "path/to/file" "name@domain" "version-1.2.3"
	)

	TEST_VAR_EQUALS_LITERAL(__TEST_VALUE "value_with-special.chars")

	TEST_VAR_DEFINED(__TEST_MULTI)
	LIST(GET __TEST_MULTI 0 path_value)
	TEST_VAR_EQUALS_LITERAL(path_value "path/to/file")

	LIST(GET __TEST_MULTI 1 email_value)
	TEST_VAR_EQUALS_LITERAL(email_value "name@domain")
ENDFUNCTION()

FUNCTION(TEST_LONG_ARGUMENT_LISTS)
	SET(LONG_MULTI_LIST)
	FOREACH(i RANGE 1 50)
		LIST(APPEND LONG_MULTI_LIST "item_${i}")
	ENDFOREACH()

	CMLIB_PARSE_ARGUMENTS(
		MULTI_VALUE TEST_MULTI
		REQUIRED TEST_MULTI
		P_ARGN
			TEST_MULTI ${LONG_MULTI_LIST}
	)

	TEST_VAR_DEFINED(__TEST_MULTI)
	LIST(LENGTH __TEST_MULTI list_length)
	SET(expected_list_length 50)
	TEST_VAR_EQUAL(list_length expected_list_length)

	LIST(GET __TEST_MULTI 24 item_25)
	TEST_VAR_EQUALS_LITERAL(item_25 "item_25")
ENDFUNCTION()

FUNCTION(TEST_MIXED_ARGUMENT_TYPES)
	CMLIB_PARSE_ARGUMENTS(
		OPTIONS OPT1 OPT2 OPT3
		ONE_VALUE SINGLE1 SINGLE2
		MULTI_VALUE MULTI1 MULTI2
		REQUIRED SINGLE1 MULTI1
		P_ARGN
			OPT1 ON
			SINGLE1 "single_value"
			MULTI1 "multi1" "multi2" "multi3"
			OPT3 ON
			SINGLE2 "another_single"
			MULTI2 "another_multi1" "another_multi2"
	)

	TEST_VAR_TRUE(__OPT1)
	TEST_VAR_FALSE(__OPT2)
	TEST_VAR_TRUE(__OPT3)

	TEST_VAR_EQUALS_LITERAL(__SINGLE1 "single_value")
	TEST_VAR_EQUALS_LITERAL(__SINGLE2 "another_single")

	TEST_VAR_DEFINED(__MULTI1)
	LIST(LENGTH __MULTI1 multi1_length)
	SET(expected_multi1_length 3)
	TEST_VAR_EQUAL(multi1_length expected_multi1_length)

	TEST_VAR_DEFINED(__MULTI2)
	LIST(LENGTH __MULTI2 multi2_length)
	SET(expected_multi2_length 2)
	TEST_VAR_EQUAL(multi2_length expected_multi2_length)
ENDFUNCTION()

FUNCTION(TEST_VARIABLE_SUBSTITUTION)
	SET(CMAKE_VAR_VALUE "cmake_variable_value")
	SET(CMAKE_LIST_VAR "item1;item2;item3")
	SET(SOURCE_LIST "file1.cpp" "file2.cpp" "file3.cpp")
	SET(TEST_CACHE_VAR "cache_value" CACHE STRING "Test cache variable")

	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE SINGLE_VAR CACHE_VALUE
		MULTI_VALUE MULTI_VAR SOURCES
		OPTIONS ENABLE_FEATURE
		P_ARGN
			SINGLE_VAR "${CMAKE_VAR_VALUE}"
			MULTI_VAR ${CMAKE_LIST_VAR}
			SOURCES ${SOURCE_LIST}
			CACHE_VALUE "${TEST_CACHE_VAR}"
			ENABLE_FEATURE ON
	)

	TEST_VAR_EQUALS_LITERAL(__SINGLE_VAR "cmake_variable_value")

	TEST_VAR_DEFINED(__MULTI_VAR)
	LIST(LENGTH __MULTI_VAR list_length)
	SET(expected_list_length 3)
	TEST_VAR_EQUAL(list_length expected_list_length)

	LIST(GET __MULTI_VAR 1 second_item)
	TEST_VAR_EQUALS_LITERAL(second_item "item2")

	TEST_VAR_DEFINED(__SOURCES)
	LIST(LENGTH __SOURCES sources_length)
	SET(expected_sources_length 3)
	TEST_VAR_EQUAL(sources_length expected_sources_length)

	LIST(GET __SOURCES 1 second_source)
	TEST_VAR_EQUALS_LITERAL(second_source "file2.cpp")

	TEST_VAR_EQUALS_LITERAL(__CACHE_VALUE "cache_value")

	TEST_VAR_TRUE(__ENABLE_FEATURE)
ENDFUNCTION()

TEST_SPACES_AND_QUOTES()
TEST_SPECIAL_CHARACTERS()
TEST_LONG_ARGUMENT_LISTS()
TEST_MIXED_ARGUMENT_TYPES()
TEST_VARIABLE_SUBSTITUTION()
