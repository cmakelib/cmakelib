
MACRO(TEST_VAR_DEFINED var)
	IF(NOT DEFINED ${var})
		MESSAGE(FATAL_ERROR "Variable ${var} is not defined")
	ENDIF()
ENDMACRO()



MACRO(TEST_VAR_NOT_DEFINED var)
	IF(DEFINED ${var})
		MESSAGE(FATAL_ERROR "Variable ${var} is defined")
	ENDIF()
ENDMACRO()



MACRO(TEST_VAR_TRUE var)
	IF(NOT ${var})
		MESSAGE(FATAL_ERROR "var '${var}' is not true")
	ENDIF()
ENDMACRO()



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



MACRO(TEST_VAR_EQUAL var_a var_b)
	IF(NOT ("${${var_a}}" STREQUAL "${${var_b}}"))
		MESSAGE(FATAL_ERROR "Variable ${var_a}(${${var_a}}) is not equal to ${var_b}(${${var_b}})")
	ENDIF()
ENDMACRO()



##
#
# Run cmake in given directory and expetcts cmake error
# <function>(
#		<working_directory>
#		<expected_error_string_regex>
# )
#
FUNCTION(TEST_INVALID_CMAKE_RUN working_directory)
	MESSAGE(STATUS "INVALID_RUN: ${working_directory}")
	SET(expected_error_string "${ARGV1}")
	SET(arg)
	IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
		SET(arg .)
	ELSE()
		SET(arg -P "./CMakeLists.txt")
	ENDIF()
	EXECUTE_PROCESS(
		COMMAND "cmake" -DCMLIB_DEBUG=${CMLIB_DEBUG} ${arg}
		WORKING_DIRECTORY "${working_directory}"
		RESULT_VARIABLE result_var
		ERROR_VARIABLE errout
		OUTPUT_VARIABLE stdout
	)
	_CMLIB_LIBRARY_DEBUG_MESSAGE("Invalid type result: ${result_var}")
	TEST_VAR_TRUE(result_var)

	IF(NOT expected_error_string)
		RETURN()
	ENDIF()
	_CMLIB_LIBRARY_DEBUG_MESSAGE("Expected error string '${expected_error_string}'")
	STRING(REGEX MATCH "${expected_error_string}" match_found "${errout}")
	IF(NOT match_found)
		MESSAGE(FATAL_ERROR "Unexpected err message '${errout}'-'${stdout}'-${result_var}")
	ENDIF()
ENDFUNCTION()



##
#
# <function> (
#		<working_directory>
# )
#
FUNCTION(RUN_TEST test)
	MESSAGE(STATUS "TEST ${test}")
	IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
		EXECUTE_PROCESS(
			COMMAND "${CMAKE_COMMAND}" -DCMLIB_DEBUG=${CMLIB_DEBUG} .
			WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/${test}"
		)
	ELSE()
		EXECUTE_PROCESS(
			COMMAND "${CMAKE_COMMAND}" -P CMakeLists.txt
			WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/${test}"
		)
	ENDIF()
ENDFUNCTION()

