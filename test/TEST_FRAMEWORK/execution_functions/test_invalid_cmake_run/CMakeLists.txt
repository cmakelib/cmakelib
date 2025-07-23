## Test TEST_INVALID_CMAKE_RUN Function
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(TEST_INVALID_CMAKE_RUN_TESTS)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../")
FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")

##
# Test Case 1: Should FAIL (project passes when we expect failure)
# We use EXECUTE_PROCESS to run this in a separate cmake process
# because we expect TEST_INVALID_CMAKE_RUN to fail
#
FUNCTION(TEST_INVALID_CMAKE_RUN_CASE_1_SHOULD_FAIL)
	EXECUTE_PROCESS(
		COMMAND ${CMAKE_COMMAND} -P "${CMAKE_CURRENT_LIST_DIR}/test_case_1_caller.cmake"
		WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}"
		RESULT_VARIABLE result
		ERROR_VARIABLE error_output
		OUTPUT_VARIABLE output
	)
	
	IF(result EQUAL 0)
		MESSAGE(FATAL_ERROR "TEST_INVALID_CMAKE_RUN should have failed when project passes but didn't")
	ENDIF()
	
	MESSAGE(STATUS "TEST_INVALID_CMAKE_RUN case 1 (should fail): PASSED")
ENDFUNCTION()

##
# Test Case 2: Should PASS (project fails with matching error)
# We call TEST_INVALID_CMAKE_RUN directly because we expect it to pass
#
FUNCTION(TEST_INVALID_CMAKE_RUN_CASE_2_SHOULD_PASS)
	TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/test_invalid_cmake_run_should_pass_match" 
	                       "Variable.*is not defined")
	MESSAGE(STATUS "TEST_INVALID_CMAKE_RUN case 2 (should pass): PASSED")
ENDFUNCTION()

##
# Test Case 3: Should FAIL (project fails but error doesn't match)
# We use EXECUTE_PROCESS because we expect TEST_INVALID_CMAKE_RUN to fail
#
FUNCTION(TEST_INVALID_CMAKE_RUN_CASE_3_SHOULD_FAIL)
	EXECUTE_PROCESS(
		COMMAND ${CMAKE_COMMAND} -P "${CMAKE_CURRENT_LIST_DIR}/test_case_3_caller.cmake"
		WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}"
		RESULT_VARIABLE result
		ERROR_VARIABLE error_output
		OUTPUT_VARIABLE output
	)
	
	IF(result EQUAL 0)
		MESSAGE(FATAL_ERROR "TEST_INVALID_CMAKE_RUN should have failed when error doesn't match but didn't")
	ENDIF()
	
	IF(NOT error_output MATCHES "Unexpected err message")
		MESSAGE(FATAL_ERROR "TEST_INVALID_CMAKE_RUN failed for wrong reason: ${error_output}")
	ENDIF()
	
	MESSAGE(STATUS "TEST_INVALID_CMAKE_RUN case 3 (should fail): PASSED")
ENDFUNCTION()

TEST_INVALID_CMAKE_RUN_CASE_1_SHOULD_FAIL()
TEST_INVALID_CMAKE_RUN_CASE_2_SHOULD_PASS()
TEST_INVALID_CMAKE_RUN_CASE_3_SHOULD_FAIL()
