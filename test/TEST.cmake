
## Main
#
# Test macros for CMLIB tests
#

# Find CMLIB package which provides CMLIB_PARSE_ARGUMENTS
LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../")
FIND_PACKAGE(CMLIB REQUIRED)

#
# var - varialbe name of value
#
MACRO(TEST_VAR_DEFINED var)
	IF(NOT DEFINED ${var})
		MESSAGE(FATAL_ERROR "Variable ${var} is not defined")
	ENDIF()
ENDMACRO()



#
# var - varialbe name of value
#
MACRO(TEST_VAR_NOT_DEFINED var)
	IF(DEFINED ${var})
		MESSAGE(FATAL_ERROR "Variable ${var} is defined")
	ENDIF()
ENDMACRO()



#
# var - varialbe name of value
#
MACRO(TEST_VAR_TRUE var)
	IF(NOT ${var})
		MESSAGE(FATAL_ERROR "var '${var}' is not true")
	ENDIF()
ENDMACRO()



#
# var - varialbe name of first value
#
MACRO(TEST_VAR_FALSE var)
	IF(${var})
		MESSAGE(FATAL_ERROR "var '${var}' is not false")
	ENDIF()
ENDMACRO()



MACRO(TEST_VAR_PATH_EXISTS var)
	IF(NOT EXISTS "${${var}}")
		MESSAGE(FATAL_ERROR "Path does not exist - ${var}:${${var}}")
	ENDIF()
ENDMACRO()



MACRO(TEST_VAR_PATH_IS_DIRECTORY var)
	IF(NOT (IS_DIRECTORY "${${var}}"))
		MESSAGE(FATAL_ERROR "Path does not exist or is not a directory - ${var}:${${var}}")
	ENDIF()
ENDMACRO()



MACRO(TEST_VAR_PATH_NOT_EXISTS var)
	IF(EXISTS "${${var}}")
		MESSAGE(FATAL_ERROR "Path does exist - ${var}:${${var}}")
	ENDIF()
ENDMACRO()



#
# var_a - varialbe name of first value
# var_b - varialbe name of second value
#
MACRO(TEST_VAR_EQUAL var_a var_b)
	IF(NOT ("${${var_a}}" STREQUAL "${${var_b}}"))
		MESSAGE(FATAL_ERROR "Variable ${var_a}(${${var_a}}) is not equal to ${var_b}(${${var_b}})")
	ENDIF()
ENDMACRO()



#
# var_a - varialbe name of first value
# var_b - varialbe name of second value
#
MACRO(TEST_VAR_NOT_EQUAL var_a var_b)
	IF(("${${var_a}}" STREQUAL "${${var_b}}"))
		MESSAGE(FATAL_ERROR "Variable ${var_a}(${${var_a}}) is not equal to ${var_b}(${${var_b}})")
	ENDIF()
ENDMACRO()



MACRO(TEST_VAR_EQUALS_LITERAL var literal_value)
	SET(expected_literal_value "${literal_value}")
	TEST_VAR_EQUAL(${var} expected_literal_value)
	UNSET(expected_literal_value)
ENDMACRO()



#
# var - variable name to check
# expected_value - expected value to compare against
#
MACRO(TEST_VAR_VALUE_EQUAL var expected_value)
	TEST_VAR_DEFINED(${var})
	IF(NOT "${${var}}" STREQUAL "${expected_value}")
		MESSAGE(FATAL_ERROR "Variable ${var} should be '${expected_value}' but is '${${var}}'")
	ENDIF()
ENDMACRO()



##
#
# Run cmake in given directory and expetcts cmake error
# <function>(
#		<test>
#		<expected_error_string_regex>
# )
#
FUNCTION(TEST_INVALID_CMAKE_RUN test)
	MESSAGE(STATUS "INVALID_RUN: ${test}")
	FILE(TO_CMAKE_PATH "${test}" working_dir)
	IF(NOT EXISTS "${working_dir}")
		MESSAGE(FATAL_ERROR "test does not exist: ${working_dir}")
	ENDIF()
	SET(expected_error_string "${ARGV1}")
	SET(arg)
	IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
		SET(arg .)
	ELSE()
		SET(arg -P "./CMakeLists.txt")
	ENDIF()
	EXECUTE_PROCESS(
		COMMAND "cmake" -DCMLIB_DEBUG=${CMLIB_DEBUG} ${arg}
		WORKING_DIRECTORY "${working_dir}"
		RESULT_VARIABLE result_var
		ERROR_VARIABLE errout
		OUTPUT_VARIABLE stdout
	)
	TEST_VAR_TRUE(result_var)

	IF(NOT expected_error_string)
		RETURN()
	ENDIF()
	STRING(REGEX MATCH "${expected_error_string}" match_found "${errout}")
	IF(NOT match_found)
		MESSAGE(FATAL_ERROR "Unexpected err message '${errout}'-'${stdout}'-${result_var}")
	ENDIF()
ENDFUNCTION()



#
# test - Path to the test directory containing a CMakeLists.txt file
#
# Runs a test by executing its CMakeLists.txt file. In script mode, runs the file directly.
# In normal mode, creates a build directory and configures the test there.
# Fails with a detailed error message if the test fails.
#
FUNCTION(TEST_RUN test)
	MESSAGE(STATUS "TEST ${test}")
	SET(result_variable 0)
	SET(error_variable "")
	FILE(TO_CMAKE_PATH "${test}" working_dir)
	IF(NOT IS_ABSOLUTE "${working_dir}")
		SET(working_dir "${CMAKE_CURRENT_LIST_DIR}/${working_dir}")
	ENDIF()
	IF(NOT EXISTS "${working_dir}")
		MESSAGE(FATAL_ERROR "test does not exist: ${working_dir}")
	ENDIF()

	IF(DEFINED CMAKE_SCRIPT_MODE_FILE)
		EXECUTE_PROCESS(
			COMMAND "${CMAKE_COMMAND}" -P "${working_dir}/CMakeLists.txt"
			WORKING_DIRECTORY "${working_dir}"
			RESULT_VARIABLE result_variable
			ERROR_VARIABLE error_variable
			OUTPUT_VARIABLE output_variable
		)
	ELSE()
		EXECUTE_PROCESS(
			COMMAND "${CMAKE_COMMAND}" -E make_directory "${working_dir}/build"
			RESULT_VARIABLE mkdir_result
		)
		IF(NOT mkdir_result EQUAL 0)
			MESSAGE(FATAL_ERROR "Failed to create build directory for test: ${test}")
		ENDIF()

		EXECUTE_PROCESS(
			COMMAND "${CMAKE_COMMAND}" "${working_dir}"
			WORKING_DIRECTORY "${working_dir}/build"
			RESULT_VARIABLE result_variable
			ERROR_VARIABLE error_variable
			OUTPUT_VARIABLE output_variable
		)
	ENDIF()

	IF(result_variable GREATER 0)
		MESSAGE(FATAL_ERROR "Test '${test}' failed with '${result_variable}'\nError: ${error_variable}\nOutput: ${output_variable}")
	ENDIF()
ENDFUNCTION()

#
# Function to run a test and check its output
# Usage:
# <function>(<test>
#     WARNING_MESSAGE <wrn_message_str>          # Check warning in stdout
#     FATAL_ERROR_MESSAGE <fatal_message_str>    # Check fatal error in stderr
# )
FUNCTION(TEST_RUN_AND_CHECK_OUTPUT test_name)
	MESSAGE(STATUS "TEST FAIL AND CHECK OUTPUT ${test_name}")
    CMLIB_PARSE_ARGUMENTS(
        PREFIX TEST_RUN
        ONE_VALUE WARNING_MESSAGE WARNING_ERROR_MESSAGE FATAL_ERROR_MESSAGE
        P_ARGN ${ARGN}
    )
	GET_FILENAME_COMPONENT(_file_name "${test_name}" NAME)
	GET_FILENAME_COMPONENT(_dir_name "${test_name}" DIRECTORY)
	IF(_dir_name STREQUAL _file_name)
		MESSAGE(FATAL_ERROR "Only name of the test could be there!")
	ENDIF()

	SET(working_dir "${CMAKE_CURRENT_LIST_DIR}")
    FILE(MAKE_DIRECTORY "${working_dir}/build")
    EXECUTE_PROCESS(
        COMMAND ${CMAKE_COMMAND} "../${test_name}"
        WORKING_DIRECTORY "${working_dir}/build"
        OUTPUT_VARIABLE output
        ERROR_VARIABLE error
        RESULT_VARIABLE result
    )
    FILE(REMOVE_RECURSE "${working_dir}/build")

    IF(DEFINED TEST_RUN_WARNING_MESSAGE)
        IF(NOT error MATCHES "${TEST_RUN_WARNING_MESSAGE}")
            MESSAGE(FATAL_ERROR "Expected WARNING message not found in output: ${TEST_RUN_WARNING_MESSAGE}")
        ENDIF()

        IF(NOT result EQUAL 0)
            MESSAGE(FATAL_ERROR "Expected process to succeed but it failed")
        ENDIF()
    ENDIF()

    IF(DEFINED TEST_RUN_FATAL_ERROR_MESSAGE)
        IF(NOT error MATCHES "${TEST_RUN_FATAL_ERROR_MESSAGE}")
            MESSAGE(FATAL_ERROR "Expected FATAL_ERROR message not found in output: ${TEST_RUN_FATAL_ERROR_MESSAGE}")
        ENDIF()

        IF(result EQUAL 0)
            MESSAGE(FATAL_ERROR "Expected process to fail but it succeeded")
        ENDIF()
    ENDIF()
ENDFUNCTION()


##
# Verify target has specific property set.
#
# Checks that a target has the specified property defined (not empty/unset).
# This is used to verify property dependencies in CMDEF_INSTALL.
#
# <macro>(
#     <target>     // Target name to check
#     <property>   // Property name that should be set
# )
#
MACRO(TEST_CHECK_TARGET_HAS_PROPERTY target property)
    GET_TARGET_PROPERTY(prop_value ${target} ${property})
    IF(NOT prop_value)
        MESSAGE(FATAL_ERROR "Target ${target} should have property ${property} set but it is not set or empty")
    ENDIF()
ENDMACRO()


##
# Verify target does NOT have specific property set.
#
# Checks that a target does not have the specified property defined or it is empty.
# This is used to verify conditional behavior in CMDEF_INSTALL.
#
# <macro>(
#     <target>     // Target name to check
#     <property>   // Property name that should NOT be set
# )
#
MACRO(TEST_CHECK_TARGET_LACKS_PROPERTY target property)
    GET_TARGET_PROPERTY(prop_value ${target} ${property})
    IF(prop_value)
        MESSAGE(FATAL_ERROR "Target ${target} should NOT have property ${property} set but it is set to: ${prop_value}")
    ENDIF()
ENDMACRO()


##
# Verify target property has exact expected value.
#
# Checks that a target's property matches the expected value exactly using string comparison.
# This is used for precise property validation in CMDEF tests.
#
# <function>(
#     <target>          // Target name to check
#     <property>        // Property name to verify
#     <expected_value>  // Exact value the property should have
# )
#
FUNCTION(TEST_CHECK_TARGET_PROPERTY target property expected_value)
    GET_PROPERTY(actual_value TARGET ${target} PROPERTY ${property})
    IF(NOT actual_value STREQUAL "${expected_value}")
        MESSAGE(FATAL_ERROR "${property} property is not set correctly for target ${target}. Expected '${expected_value}', got '${actual_value}'")
    ENDIF()
ENDFUNCTION()

##
# Verify target property contains expected pattern.
#
# Checks that a target's property contains the expected pattern using regex matching.
# This is used for flexible property validation when exact matching is not required.
#
# <function>(
#     <target>          // Target name to check
#     <property>        // Property name to verify
#     <expected_value>  // Pattern/regex that the property should contain
# )
#
FUNCTION(TEST_CHECK_TARGET_PROPERTY_CONTAINS target property expected_value)
    GET_PROPERTY(actual_value TARGET ${target} PROPERTY ${property})
    IF(NOT actual_value MATCHES "${expected_value}")
        MESSAGE(FATAL_ERROR "${property} property is not set correctly for target ${target}. Expected to contain '${expected_value}', got '${actual_value}'")
    ENDIF()
ENDFUNCTION()

