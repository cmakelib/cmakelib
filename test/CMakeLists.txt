 
IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(CMLIB_CACHE_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../")
FIND_PACKAGE(CMLIB)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/test_resources/test_resources_download.cmake")

# Test the TEST.cmake TEST_*RUN* functions.
# Read the documentation in TEST_FRAMEWORK/README.md for details
MESSAGE(STATUS "TEST.cmake - RUN Functions Validation")
SET(execution_functions_test_path "${CMAKE_CURRENT_LIST_DIR}/TEST_FRAMEWORK/execution_functions")
SET(script_mode)
IF(DEFINED CMAKE_SCRIPT_MODE_FILE)
	SET(script_mode "-P")
ENDIF()
EXECUTE_PROCESS(
	COMMAND "${CMAKE_COMMAND}" ${script_mode} "${execution_functions_test_path}/CMakeLists.txt"
	WORKING_DIRECTORY "${execution_functions_test_path}"
	RESULT_VARIABLE result_var
	ERROR_VARIABLE errout
	OUTPUT_VARIABLE stdout
)
IF(NOT result_var EQUAL 0)
    MESSAGE(FATAL_ERROR "TEST_FRAMEWORK/execution_functions failed: ${errout}\n${stdout}")
ENDIF()

# Test the TEST.cmake TEST_* functions which are not RUN functions
# By standard way :).
TEST_RUN(TEST_FRAMEWORK)

TEST_RUN(ARCHIVE)
TEST_RUN(CACHE)
TEST_RUN(FILE_DOWNLOAD)
TEST_RUN(PARSE_ARGUMENTS)
TEST_RUN(REQUIRED_ENV)
TEST_RUN(DEPENDENCY)
TEST_RUN(COMPONENT)
TEST_RUN(TEMPLATE)
