## Test TEST_VAR_VALUE_EQUAL failure case - value mismatch
LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../")
FIND_PACKAGE(CMLIB REQUIRED)
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")

SET(test_var "actual_value")
TEST_VAR_VALUE_EQUAL(test_var "expected_value")
