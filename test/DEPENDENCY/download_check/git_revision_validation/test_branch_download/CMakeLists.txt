## GIT_REVISION Test Branch Test
#
# Verify DEPENDENCY downloads correct content from test-branch
# This test validates that non-default branches work correctly and
# connects to cache_control tests by ensuring different revisions
# produce different content when they should
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
    PROJECT(CMLIB_DEPENDENCY_GIT_REVISION_TESTBRANCH_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../../")
FIND_PACKAGE(CMLIB)
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../transform_git_uri.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../cache_var.cmake")

TRANSFORM_GIT_URI(
    URI "${CMLIB_REQUIRED_ENV_REMOTE_URL}/cmakelib-test.git"
    OUTPUT_VAR GIT_URI
)

FUNCTION(TEST_GIT_REVISION_TESTBRANCH_DOWNLOAD)
    CMLIB_DEPENDENCY(
        KEYWORDS GIT REVISION TESTBRANCH DIRECTORY TEST
        TYPE DIRECTORY
        URI "${GIT_URI}"
        GIT_REVISION "test-branch"
        OUTPUT_PATH_VAR testbranch_output_directory
    )

    IF(NOT EXISTS "${testbranch_output_directory}")
        MESSAGE(FATAL_ERROR "directory does not exist: ${testbranch_output_directory}")
    ENDIF()

    SET(testbranch_files
        "cmake-test/test_branch_dir_a/test.zip"
        "cmake-test/test_branch_dir_b/AnotherFile.txt"
        "cmake-test/test_branch_same/same.zip"
        "cmake-test/test_branch_README.txt"
    )

    FOREACH(file_path IN LISTS testbranch_files)
        SET(full_file_path "${testbranch_output_directory}/${file_path}")
        IF(NOT EXISTS "${full_file_path}")
            MESSAGE(FATAL_ERROR "Expected test-branch file does not exist: ${full_file_path}")
        ENDIF()
    ENDFOREACH()

    CMLIB_CACHE_DELETE(KEYWORDS GIT REVISION TESTBRANCH DIRECTORY TEST)
    FILE(REMOVE_RECURSE "${CMLIB_REQUIRED_ENV_TMP_PATH}")
ENDFUNCTION()

CACHE_VAR_FORCE_SET(CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_DISABLE OFF)
TEST_GIT_REVISION_TESTBRANCH_DOWNLOAD()
CACHE_VAR_RESTORE(CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_DISABLE)

CACHE_VAR_FORCE_SET(CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_DISABLE ON)
TEST_GIT_REVISION_TESTBRANCH_DOWNLOAD()
CACHE_VAR_RESTORE(CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_DISABLE)
