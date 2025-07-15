## Git URI Download Test
#
# Verify DEPENDENCY can download files using Git URIs.
#
# CMLIB_CACHE_DELETE is used to simplify testing. It has no
# effect on the validity of the test.
# Function is heavily tested by its own unit tests.
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
    PROJECT(CMLIB_DEPENDENCY_GIT_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../")
FIND_PACKAGE(CMLIB)
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../cache_var.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../transform_git_uri.cmake")

TRANSFORM_GIT_URI(
    URI "${CMLIB_REQUIRED_ENV_REMOTE_URL}/cmakelib-test.git"
    OUTPUT_VAR GIT_URI
)
TRANSFORM_GIT_URI_TO_HTTPS(
    URI "${CMLIB_REQUIRED_ENV_REMOTE_URL}/cmakelib-test.git"
    OUTPUT_VAR GIT_URI_HTTPS
)



MACRO(_TEST_GIT_DOWNLOAD uri)
    CMLIB_DEPENDENCY(
        KEYWORDS TEST MODULE TEST
        TYPE FILE
        URI "${uri}"
        GIT_PATH "TEST_MODULE.cmake"
        GIT_REVISION "master"
        OUTPUT_PATH_VAR output_path
    )
    IF(NOT EXISTS "${output_path}")
        MESSAGE(FATAL_ERROR "Git download with archive enabled failed - output file does not exist: ${output_path}")
    ENDIF()

    IF(DEFINED TEST_MODULE_MACRO)
        MESSAGE(FATAL_ERROR "TEST_MODULE_MACRO should not be defined! It is part of the dowloaded TEST_MODULE.cmake")
    ENDIF()
    INCLUDE("${output_path}")
    TEST_MODULE_MACRO()

    # Clean up all cache variables and stored files...
    CMLIB_CACHE_DELETE(KEYWORDS TEST MODULE TEST)

    # Lets delete the cache to not trigger cache control checks
    # for subsequent tests.
    FILE(REMOVE_RECURSE "${CMLIB_REQUIRED_ENV_TMP_PATH}")
ENDMACRO()

FUNCTION(TEST_GIT_ARCHIVE_ENABLED)
    CACHE_VAR_FORCE_SET(CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_DISABLE OFF)
    _TEST_GIT_DOWNLOAD("${GIT_URI}")
    _TEST_GIT_DOWNLOAD("${GIT_URI_HTTPS}")
    CACHE_VAR_RESTORE(CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_DISABLE)
ENDFUNCTION()

FUNCTION(TEST_GIT_ARCHIVE_DISABLED)
    CACHE_VAR_FORCE_SET(CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_DISABLE ON)
    _TEST_GIT_DOWNLOAD("${GIT_URI}")
    _TEST_GIT_DOWNLOAD("${GIT_URI_HTTPS}")
    CACHE_VAR_RESTORE(CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_DISABLE)
ENDFUNCTION()



TEST_GIT_ARCHIVE_ENABLED()
TEST_GIT_ARCHIVE_DISABLED()
