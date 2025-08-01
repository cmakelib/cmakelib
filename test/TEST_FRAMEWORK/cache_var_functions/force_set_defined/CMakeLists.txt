## Test CACHE_VAR_FORCE_SET on defined variable

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(TEST_CACHE_VAR_FORCE_SET_DEFINED)
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

MACRO(TEST_GLOBAL_PROPERTY_DEFINED property_name)
	GET_PROPERTY(is_defined GLOBAL PROPERTY ${property_name} SET)
	IF(NOT is_defined)
		MESSAGE(FATAL_ERROR "Global property ${property_name} is not defined")
	ENDIF()
ENDMACRO()

MACRO(TEST_GLOBAL_PROPERTY_EQUALS_LITERAL property_name expected_value)
	GET_PROPERTY(actual_value GLOBAL PROPERTY ${property_name})
	IF(NOT "${actual_value}" STREQUAL "${expected_value}")
		MESSAGE(FATAL_ERROR "Global property ${property_name} should be '${expected_value}' but is '${actual_value}'")
	ENDIF()
ENDMACRO()

MACRO(TEST_GLOBAL_PROPERTY_EQUALS_BOOLEAN property_name expected_boolean)
	GET_PROPERTY(actual_value GLOBAL PROPERTY ${property_name})
	IF("${expected_boolean}" STREQUAL "TRUE" OR "${expected_boolean}" STREQUAL "ON" OR "${expected_boolean}" STREQUAL "1")
		IF(NOT actual_value)
			MESSAGE(FATAL_ERROR "Global property ${property_name} should be TRUE but is '${actual_value}'")
		ENDIF()
	ELSE()
		IF(actual_value)
			MESSAGE(FATAL_ERROR "Global property ${property_name} should be FALSE but is '${actual_value}'")
		ENDIF()
	ENDIF()
ENDMACRO()

SET(test_var_name "TEST_DEFINED_VAR")

SET(${test_var_name} "original_value" CACHE STRING "Test variable" FORCE)
TEST_CACHE_VAR_DEFINED(${test_var_name})
TEST_CACHE_VAR_EQUALS_LITERAL(${test_var_name} "original_value")

CACHE_VAR_FORCE_SET(${test_var_name} "new_value")

TEST_CACHE_VAR_DEFINED(${test_var_name})
TEST_CACHE_VAR_EQUALS_LITERAL(${test_var_name} "new_value")
TEST_GLOBAL_PROPERTY_DEFINED("CACHE_VAR_WAS_DEFINED_${test_var_name}")
TEST_GLOBAL_PROPERTY_EQUALS_BOOLEAN("CACHE_VAR_WAS_DEFINED_${test_var_name}" TRUE)
TEST_GLOBAL_PROPERTY_DEFINED("CACHE_VAR_ORIGINAL_${test_var_name}")
TEST_GLOBAL_PROPERTY_EQUALS_LITERAL("CACHE_VAR_ORIGINAL_${test_var_name}" "original_value")
