## Main
#
# Tests for all TEST.cmake functions and macros
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(TEST_FRAMEWORK_ALL)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../")
FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../TEST.cmake")

# execution_functions are tested in the top-level CMakeLists.txt
# Read the documentation in TEST_FRAMEWORK/README.md for details
#TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/execution_functions")

TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/variable_functions")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/path_functions")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/target_property_functions")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/cache_var_functions")
