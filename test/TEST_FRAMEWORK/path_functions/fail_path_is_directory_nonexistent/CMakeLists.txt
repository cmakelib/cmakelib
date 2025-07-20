## Test TEST_VAR_PATH_IS_DIRECTORY failure case - non-existent path
LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../")
FIND_PACKAGE(CMLIB REQUIRED)
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")

SET(test_nonexistent_path "/non/existent/directory")
TEST_VAR_PATH_IS_DIRECTORY(test_nonexistent_path)
