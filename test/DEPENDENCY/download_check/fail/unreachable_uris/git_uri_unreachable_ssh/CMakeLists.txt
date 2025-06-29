## Git URI Unreachable Test (git@ SSH scheme)
#
# Test DEPENDENCY failure when Git URI using git@ SSH scheme is unreachable
# TEST must FAIL
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
    PROJECT(CMLIB_DEPENDENCY_GIT_FAIL_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../../../")
FIND_PACKAGE(CMLIB)

SET(UNREACHABLE_GIT_URI "git@nonexistent.domain.invalid:repo.git")

CMLIB_DEPENDENCY(
    TYPE FILE
    URI "${UNREACHABLE_GIT_URI}"
    GIT_PATH "file.txt"
    OUTPUT_PATH_VAR output_path
)
