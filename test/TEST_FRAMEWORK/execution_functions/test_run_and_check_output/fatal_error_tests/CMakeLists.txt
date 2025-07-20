## Test TEST_RUN_AND_CHECK_OUTPUT Fatal Error Message Functionality
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(TEST_RUN_AND_CHECK_OUTPUT_FATAL_ERROR_TESTS)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../../")
FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../TEST.cmake")

##
# Test Case 1: Should PASS (fatal error present and matches)
# We call TEST_RUN_AND_CHECK_OUTPUT directly because we expect it to pass
#
FUNCTION(TEST_FATAL_ERROR_CASE_1_SHOULD_PASS)
	TEST_RUN_AND_CHECK_OUTPUT("test_output_fatal_should_pass"
		FATAL_ERROR_MESSAGE "Test fatal error message")
	MESSAGE(STATUS "TEST_RUN_AND_CHECK_OUTPUT fatal error case 1 (should pass): PASSED")
ENDFUNCTION()

##
# Test Case 2: Should FAIL (fatal error not present)
# We use EXECUTE_PROCESS because we expect TEST_RUN_AND_CHECK_OUTPUT to fail
#
FUNCTION(TEST_FATAL_ERROR_CASE_2_SHOULD_FAIL)
	EXECUTE_PROCESS(
		COMMAND ${CMAKE_COMMAND} -P "${CMAKE_CURRENT_LIST_DIR}/fatal_error_case_2_caller.cmake"
		WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}"
		RESULT_VARIABLE result
		ERROR_VARIABLE error_output
		OUTPUT_VARIABLE output
	)
	
	IF(result EQUAL 0)
		MESSAGE(FATAL_ERROR "TEST_RUN_AND_CHECK_OUTPUT should have failed when fatal error missing but didn't")
	ENDIF()
	
	IF(NOT error_output MATCHES "Expected FATAL_ERROR message not found")
		MESSAGE(FATAL_ERROR "TEST_RUN_AND_CHECK_OUTPUT failed for wrong reason: ${error_output}")
	ENDIF()
	
	MESSAGE(STATUS "TEST_RUN_AND_CHECK_OUTPUT fatal error case 2 (should fail): PASSED")
ENDFUNCTION()

##
# Test Case 3: Should FAIL (fatal error doesn't match)
# We use EXECUTE_PROCESS because we expect TEST_RUN_AND_CHECK_OUTPUT to fail
#
FUNCTION(TEST_FATAL_ERROR_CASE_3_SHOULD_FAIL)
	EXECUTE_PROCESS(
		COMMAND ${CMAKE_COMMAND} -P "${CMAKE_CURRENT_LIST_DIR}/fatal_error_case_3_caller.cmake"
		WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}"
		RESULT_VARIABLE result
		ERROR_VARIABLE error_output
		OUTPUT_VARIABLE output
	)
	
	IF(result EQUAL 0)
		MESSAGE(FATAL_ERROR "TEST_RUN_AND_CHECK_OUTPUT should have failed when fatal error doesn't match but didn't")
	ENDIF()
	
	IF(NOT (error_output MATCHES "Expected FATAL_ERROR message not found"))
		MESSAGE(FATAL_ERROR "TEST_RUN_AND_CHECK_OUTPUT failed for wrong reason: ${error_output}")
	ENDIF()
	
	MESSAGE(STATUS "TEST_RUN_AND_CHECK_OUTPUT fatal error case 3 (should fail): PASSED")
ENDFUNCTION()

##
# Test Case 4: Should FAIL (project succeeds when we expect fatal error)
# We use EXECUTE_PROCESS because we expect TEST_RUN_AND_CHECK_OUTPUT to fail
#
FUNCTION(TEST_FATAL_ERROR_CASE_4_SHOULD_FAIL)
	MESSAGE(STATUS "OK")
	EXECUTE_PROCESS(
		COMMAND ${CMAKE_COMMAND} -P "${CMAKE_CURRENT_LIST_DIR}/fatal_error_case_4_caller.cmake"
		WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}"
		RESULT_VARIABLE result
		ERROR_VARIABLE error_output
		OUTPUT_VARIABLE output
	)
	
	IF(result EQUAL 0)
		MESSAGE(FATAL_ERROR "TEST_RUN_AND_CHECK_OUTPUT should have failed when project succeeds unexpectedly but didn't")
	ENDIF()
	
	IF(NOT (error_output MATCHES "Expected FATAL_ERROR message not found"))
		MESSAGE(FATAL_ERROR "TEST_RUN_AND_CHECK_OUTPUT failed for wrong reason: ${error_output}")
	ENDIF()
	
	MESSAGE(STATUS "TEST_RUN_AND_CHECK_OUTPUT fatal error case 4 (should fail): PASSED")
ENDFUNCTION()

# Run all test cases
TEST_FATAL_ERROR_CASE_1_SHOULD_PASS()
TEST_FATAL_ERROR_CASE_2_SHOULD_FAIL()
TEST_FATAL_ERROR_CASE_3_SHOULD_FAIL()
TEST_FATAL_ERROR_CASE_4_SHOULD_FAIL()
