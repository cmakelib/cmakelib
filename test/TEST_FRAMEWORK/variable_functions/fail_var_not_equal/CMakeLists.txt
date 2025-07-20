LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../")
FIND_PACKAGE(CMLIB REQUIRED)
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")

SET(test_var_a "same_value")
SET(test_var_b "same_value")
TEST_VAR_NOT_EQUAL(test_var_a test_var_b)
