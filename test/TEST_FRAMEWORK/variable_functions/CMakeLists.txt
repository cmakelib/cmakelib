## Test Variable Functions
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(TEST_VARIABLE_FUNCTIONS)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../")
FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../TEST.cmake")

##
# Test TEST_VAR_DEFINED positive cases
#
FUNCTION(TEST_VAR_DEFINED_TESTS)
	SET(test_defined_var "some_value")
	TEST_VAR_DEFINED(test_defined_var)
ENDFUNCTION()

##
# Test TEST_VAR_NOT_DEFINED positive cases
#
FUNCTION(TEST_VAR_NOT_DEFINED_TESTS)
	UNSET(test_undefined_var)
	TEST_VAR_NOT_DEFINED(test_undefined_var)
ENDFUNCTION()

##
# Test TEST_VAR_TRUE positive cases
#
FUNCTION(TEST_VAR_TRUE_TESTS)
	SET(test_var_on "ON")
	TEST_VAR_TRUE(test_var_on)

	SET(test_var_1 "1")
	TEST_VAR_TRUE(test_var_1)

	SET(test_var_true "TRUE")
	TEST_VAR_TRUE(test_var_true)

	SET(test_var_yes "YES")
	TEST_VAR_TRUE(test_var_yes)
ENDFUNCTION()

##
# Test TEST_VAR_FALSE positive cases
#
FUNCTION(TEST_VAR_FALSE_TESTS)
	SET(test_var_off "OFF")
	TEST_VAR_FALSE(test_var_off)

	SET(test_var_0 "0")
	TEST_VAR_FALSE(test_var_0)

	SET(test_var_false "FALSE")
	TEST_VAR_FALSE(test_var_false)

	SET(test_var_no "NO")
	TEST_VAR_FALSE(test_var_no)

	SET(test_var_empty "")
	TEST_VAR_FALSE(test_var_empty)
ENDFUNCTION()

##
# Test TEST_VAR_EQUAL positive cases
#
FUNCTION(TEST_VAR_EQUAL_TESTS)
	SET(test_var_a "same_value")
	SET(test_var_b "same_value")
	TEST_VAR_EQUAL(test_var_a test_var_b)
ENDFUNCTION()

##
# Test TEST_VAR_NOT_EQUAL positive cases
#
FUNCTION(TEST_VAR_NOT_EQUAL_TESTS)
	SET(test_var_a "value1")
	SET(test_var_b "value2")
	TEST_VAR_NOT_EQUAL(test_var_a test_var_b)
ENDFUNCTION()

##
# Test TEST_VAR_EQUALS_LITERAL positive cases
#
FUNCTION(TEST_VAR_EQUALS_LITERAL_TESTS)
	SET(test_var "literal_value")
	TEST_VAR_EQUALS_LITERAL(test_var "literal_value")
ENDFUNCTION()

##
# Test TEST_VAR_VALUE_EQUAL positive cases
#
FUNCTION(TEST_VAR_VALUE_EQUAL_TESTS)
	SET(test_var "expected_value")
	TEST_VAR_VALUE_EQUAL(test_var "expected_value")
ENDFUNCTION()

TEST_VAR_DEFINED_TESTS()
TEST_VAR_NOT_DEFINED_TESTS()
TEST_VAR_TRUE_TESTS()
TEST_VAR_FALSE_TESTS()
TEST_VAR_EQUAL_TESTS()
TEST_VAR_NOT_EQUAL_TESTS()
TEST_VAR_EQUALS_LITERAL_TESTS()
TEST_VAR_VALUE_EQUAL_TESTS()

TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/fail_var_defined")
TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/fail_var_not_defined")
TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/fail_var_true")
TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/fail_var_false")
TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/fail_var_equal")
TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/fail_var_not_equal")
TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/fail_var_equals_literal")
TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/fail_var_value_equal_undefined")
TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/fail_var_value_equal_mismatch")
