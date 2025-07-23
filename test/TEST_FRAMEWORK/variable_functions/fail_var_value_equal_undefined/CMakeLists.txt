## Test TEST_VAR_VALUE_EQUAL failure case - undefined variable
LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../")
FIND_PACKAGE(CMLIB REQUIRED)
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")

UNSET(test_undefined_var)
TEST_VAR_VALUE_EQUAL(test_undefined_var "expected_value")
