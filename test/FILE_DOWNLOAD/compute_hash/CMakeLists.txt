#
# Test if hash is computed correctly
#

IF(NOT  DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(CMLIB_CACHE_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../")
FIND_PACKAGE(CMLIB)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../TEST.cmake")

SET(VALID_GIT_URI         "https://github.com/cmakelib/cmakelib-test.git")
SET(VALID_GIT_URI_ARCHIVE "git@gitlab.com:cmakelib/cmakelib-test.git")



FUNCTION(DOWNLOAD_AND_COMPARE out_var uri)
    SET(output_path_same "${CMAKE_CURRENT_BINARY_DIR}/same.zip")
    CMLIB_FILE_DOWNLOAD(
        URI "${uri}"
        GIT_PATH "cmake/same/same.zip"
        STATUS_VAR status
        OUTPUT_PATH "${output_path_same}"
        FILE_HASH_OUTPUT_VAR test_branch_hash
    )
    TEST_VAR_TRUE(status)

    SET(output_path_same2 "${CMAKE_CURRENT_BINARY_DIR}/test_branch_same.zip")
    CMLIB_FILE_DOWNLOAD(
        URI "${uri}"
        GIT_PATH "cmake/same/same.zip"
        STATUS_VAR status
        OUTPUT_PATH "${output_path_same2}"
        FILE_HASH_OUTPUT_VAR test_branch_hash2
    )
    TEST_VAR_TRUE(status)
    TEST_VAR_TRUE(test_branch_hash)
    TEST_VAR_EQUAL(test_branch_hash test_branch_hash2) 
    SET(${out_var} ${test_branch_hash})
ENDFUNCTION()



SET(CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_ONLY ON
    CACHE BOOL
    "Use git-archive only!"
    FORCE
)
DOWNLOAD_AND_COMPARE(hash_archive_on ${VALID_GIT_URI_ARCHIVE})

SET(CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_ONLY OFF
    CACHE BOOL
    "Use git-archive only!"
    FORCE
)
DOWNLOAD_AND_COMPARE(hash_archive_off ${VALID_GIT_URI_ARCHIVE})

TEST_VAR_EQUAL(hash_archive_on hash_archive_off)