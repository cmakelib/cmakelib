## GIT_REVISION Master Branch Test
#
# Verify DEPENDENCY downloads correct content from master branch
# This test connects to the basic download functionality and validates
# that explicit GIT_REVISION "master" works the same as default behavior
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
    PROJECT(CMLIB_DEPENDENCY_GIT_REVISION_MASTER_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../../")
FIND_PACKAGE(CMLIB)
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../transform_git_uri.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../../cache_var.cmake")

TRANSFORM_GIT_URI(
    URI "${CMLIB_REQUIRED_ENV_REMOTE_URL}/cmakelib-test.git"
    OUTPUT_VAR GIT_URI
)

FUNCTION(TEST_MASTER_BRANCH_DOWNLOAD git_revision keywords_suffix)
    CMLIB_DEPENDENCY(
        KEYWORDS GIT REVISION ${keywords_suffix} DIRECTORY TEST
        TYPE DIRECTORY
        URI "${GIT_URI}"
        GIT_REVISION "${git_revision}"
        OUTPUT_PATH_VAR output_directory
    )

    IF(NOT EXISTS "${output_directory}")
        MESSAGE(FATAL_ERROR "directory does not exist: ${output_directory}")
    ENDIF()

    SET(master_files
        "cmake/dir_a/test.zip"
        "cmake/dir_b/AnotherFile.txt"
        "cmake/same/same.zip"
        "TEST_MODULE.cmake"
    )

    FOREACH(file_path IN LISTS master_files)
        SET(full_file_path "${output_directory}/${file_path}")
        IF(NOT EXISTS "${full_file_path}")
            MESSAGE(FATAL_ERROR "Expected master file does not exist: ${full_file_path}")
        ENDIF()
    ENDFOREACH()

    CMLIB_CACHE_DELETE(KEYWORDS GIT REVISION ${keywords_suffix} DIRECTORY TEST)
    FILE(REMOVE_RECURSE "${CMLIB_REQUIRED_ENV_TMP_PATH}")
ENDFUNCTION()

TEST_MASTER_BRANCH_DOWNLOAD("master" "MASTER")
TEST_MASTER_BRANCH_DOWNLOAD(""       "DEFAULT")
