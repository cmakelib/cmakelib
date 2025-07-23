## Test TEST_VAR_PATH_EXISTS failure case
# This test should fail because the path does not exist

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../")
FIND_PACKAGE(CMLIB REQUIRED)
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")

SET(test_nonexistent_path "/non/existent/path/file.txt")
TEST_VAR_PATH_EXISTS(test_nonexistent_path)
