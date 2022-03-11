#
# Test if hash is computed correstly
#

IF(NOT  DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(CMLIB_CACHE_TEST)
ENDIF()

SET(VALID_GIT_URI         "https://github.com/cmakelib/cmakelib-test.git")
SET(VALID_GIT_URI_ARCHIVE "git@gitlab.com:cmakelib/cmakelib-test.git")



SET(output_path_same "${CMAKE_CURRENT_BINARY_DIR}/same.zip")
CMLIB_FILE_DOWNLOAD(
    URI "${VALID_GIT_URI}"
    GIT_PATH "cmake/smame/same.zip"
    STATUS_VAR status
    OUTPUT_PATH "${output_path_same}"
    FILE_HASH_OUTPUT_VAR test_branch_hash
)

SET(output_path_same2 "${CMAKE_CURRENT_BINARY_DIR}/test_branch_same.zip")
CMLIB_FILE_DOWNLOAD(
    URI "${VALID_GIT_URI}"
    GIT_PATH "cmake/smame/same.zip"
    STATUS_VAR status
    OUTPUT_PATH "${output_path_same2}"
    FILE_HASH_OUTPUT_VAR test_branch_hash
)