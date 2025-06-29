## GIT_REVISION Branch-Specific Files Test
#
# Verify DEPENDENCY correctly handles files that exist only on specific branches
# This test validates that GIT_REVISION actually switches between branches by
# attempting to download branch-specific files and ensuring they exist/fail appropriately
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
    PROJECT(CMLIB_DEPENDENCY_GIT_REVISION_SPECIFIC_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../../")
FIND_PACKAGE(CMLIB)
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../transform_git_uri.cmake")

TRANSFORM_GIT_URI(
    URI "${CMLIB_REQUIRED_ENV_REMOTE_URL}/cmakelib-test.git"
    OUTPUT_VAR GIT_URI
)

FUNCTION(TEST_BRANCH_FILES git_revision keywords_suffix expected_files)
    CMLIB_DEPENDENCY(
        KEYWORDS GIT REVISION ${keywords_suffix} DIRECTORY TEST
        TYPE DIRECTORY
        URI "${GIT_URI}"
        GIT_REVISION "${git_revision}"
        OUTPUT_PATH_VAR output_directory
    )

    IF(NOT EXISTS "${output_directory}")
        MESSAGE(FATAL_ERROR "Directory does not exist: ${output_directory}")
    ENDIF()

    FOREACH(file_path IN LISTS expected_files)
        SET(full_file_path "${output_directory}/${file_path}")
        IF(NOT EXISTS "${full_file_path}")
            MESSAGE(FATAL_ERROR "Expected file does not exist in ${git_revision}: ${full_file_path}")
        ENDIF()
    ENDFOREACH()

    CMLIB_CACHE_DELETE(KEYWORDS GIT REVISION ${keywords_suffix} DIRECTORY TEST)
    FILE(REMOVE_RECURSE "${CMLIB_REQUIRED_ENV_TMP_PATH}")
ENDFUNCTION()

SET(master_files
    "cmake/dir_a/test.zip"
    "cmake/dir_b/AnotherFile.txt"
    "cmake/same/same.zip"
    "TEST_MODULE.cmake"
)

SET(testbranch_files
    "cmake-test/test_branch_dir_a/test.zip"
    "cmake-test/test_branch_dir_b/AnotherFile.txt"
    "cmake-test/test_branch_same/same.zip"
    "cmake-test/test_branch_README.txt"
)

TEST_BRANCH_FILES("master"      "MASTER"     "${master_files}")
TEST_BRANCH_FILES("test-branch" "TESTBRANCH" "${testbranch_files}")
