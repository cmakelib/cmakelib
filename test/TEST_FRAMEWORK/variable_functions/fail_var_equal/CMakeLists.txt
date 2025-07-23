## Test TEST_VAR_EQUAL failure case

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../")
FIND_PACKAGE(CMLIB REQUIRED)
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")

SET(test_var_a "value1")
SET(test_var_b "value2")
TEST_VAR_EQUAL(test_var_a test_var_b)
