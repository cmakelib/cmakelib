
IF(NOT  DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(CMLIB_CACHE_TEST)
ENDIF()

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../TEST.cmake")

TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/cache_control")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/download_check")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/type_check")

TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/argument_missing"
    "Requirements for OUTPUT_VAR are not met! \\(Not defined\\? Invalid format\\?\\)")
