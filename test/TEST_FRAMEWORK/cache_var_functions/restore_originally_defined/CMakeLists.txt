## Test CACHE_VAR_RESTORE when originally_defined=TRUE

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(TEST_CACHE_VAR_RESTORE_ORIGINALLY_DEFINED)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../")
FIND_PACKAGE(CMLIB REQUIRED)
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../cache_var.cmake")

MACRO(TEST_CACHE_VAR_DEFINED var_name)
	GET_PROPERTY(is_defined CACHE ${var_name} PROPERTY VALUE SET)
	IF(NOT is_defined)
		MESSAGE(FATAL_ERROR "Cache variable ${var_name} is not defined")
	ENDIF()
ENDMACRO()

MACRO(TEST_CACHE_VAR_EQUALS_LITERAL var_name expected_value)
	GET_PROPERTY(actual_value CACHE ${var_name} PROPERTY VALUE)
	IF(NOT "${actual_value}" STREQUAL "${expected_value}")
		MESSAGE(FATAL_ERROR "Cache variable ${var_name} should be '${expected_value}' but is '${actual_value}'")
	ENDIF()
ENDMACRO()

MACRO(TEST_GLOBAL_PROPERTY_NOT_DEFINED property_name)
	GET_PROPERTY(is_defined GLOBAL PROPERTY ${property_name} SET)
	IF(is_defined)
		MESSAGE(FATAL_ERROR "Global property ${property_name} is defined")
	ENDIF()
ENDMACRO()

SET(test_var_name "TEST_RESTORE_ORIGINALLY_DEFINED_VAR")

# Manually set up the global properties as if CACHE_VAR_FORCE_SET was called on a defined variable
SET_PROPERTY(GLOBAL PROPERTY "CACHE_VAR_WAS_DEFINED_${test_var_name}" TRUE)
SET_PROPERTY(GLOBAL PROPERTY "CACHE_VAR_ORIGINAL_${test_var_name}" "original_value")

CACHE_VAR_RESTORE(${test_var_name})

TEST_CACHE_VAR_DEFINED(${test_var_name})
TEST_CACHE_VAR_EQUALS_LITERAL(${test_var_name} "original_value")
TEST_GLOBAL_PROPERTY_NOT_DEFINED("CACHE_VAR_WAS_DEFINED_${test_var_name}")
TEST_GLOBAL_PROPERTY_NOT_DEFINED("CACHE_VAR_ORIGINAL_${test_var_name}")
