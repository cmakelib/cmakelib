## Test TEST_RUN Function
#
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(TEST_RUN_TESTS)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../")
FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")

##
# Test Case 1: Should PASS (project succeeds)
# We call TEST_RUN directly because we expect it to pass
#
FUNCTION(TEST_RUN_CASE_1_SHOULD_PASS)
	TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_run_should_pass")
	MESSAGE(STATUS "TEST_RUN case 1 (should pass): PASSED")
ENDFUNCTION()

##
# Test Case 2: Should FAIL (project fails)
# We use EXECUTE_PROCESS because we expect TEST_RUN to fail
#
FUNCTION(TEST_RUN_CASE_2_SHOULD_FAIL)
	EXECUTE_PROCESS(
		COMMAND ${CMAKE_COMMAND} -P "${CMAKE_CURRENT_LIST_DIR}/test_case_2_caller.cmake"
		WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}"
		RESULT_VARIABLE result
		ERROR_VARIABLE error_output
		OUTPUT_VARIABLE output
	)
	
	IF(result EQUAL 0)
		MESSAGE(FATAL_ERROR "TEST_RUN should have failed when project fails but didn't")
	ENDIF()
	
	IF(NOT error_output MATCHES "Test.*failed")
		MESSAGE(FATAL_ERROR "TEST_RUN failed for wrong reason: ${error_output}")
	ENDIF()
	
	MESSAGE(STATUS "TEST_RUN case 2 (should fail): PASSED")
ENDFUNCTION()

##
# Test Case 3: Should FAIL (non-existent directory)
# We use EXECUTE_PROCESS because we expect TEST_RUN to fail
#
FUNCTION(TEST_RUN_CASE_3_SHOULD_FAIL)
	EXECUTE_PROCESS(
		COMMAND ${CMAKE_COMMAND} -P "${CMAKE_CURRENT_LIST_DIR}/test_case_3_caller.cmake"
		WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}"
		RESULT_VARIABLE result
		ERROR_VARIABLE error_output
		OUTPUT_VARIABLE output
	)
	
	IF(result EQUAL 0)
		MESSAGE(FATAL_ERROR "TEST_RUN should have failed for non-existent directory but didn't")
	ENDIF()
	
	IF(NOT error_output MATCHES "test does not exist")
		MESSAGE(FATAL_ERROR "TEST_RUN failed for wrong reason: ${error_output}")
	ENDIF()
	
	MESSAGE(STATUS "TEST_RUN case 3 (should fail): PASSED")
ENDFUNCTION()



TEST_RUN_CASE_1_SHOULD_PASS()
TEST_RUN_CASE_2_SHOULD_FAIL()
TEST_RUN_CASE_3_SHOULD_FAIL()
