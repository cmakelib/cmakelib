## TYPE=DIRECTORY Test
#
# Test DEPENDENCY with TYPE=DIRECTORY using git:// URIs.
# Tests CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_DISABLE cache variable behavior.
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
    PROJECT(CMLIB_DEPENDENCY_TYPE_DIRECTORY_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../")
FIND_PACKAGE(CMLIB)
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../transform_git_uri.cmake")

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../cache_var.cmake")

TRANSFORM_GIT_URI(
    URI "${CMLIB_REQUIRED_ENV_REMOTE_URL}/cmakelib-test.git"
    OUTPUT_VAR GIT_URI
)



MACRO(_TEST_GIT_DIRECTORY_DOWNLOAD)
    CMLIB_DEPENDENCY(
        TYPE DIRECTORY
        URI "${GIT_URI}"
        GIT_REVISION "master"
        KEYWORDS TEST MODULE TEST
        OUTPUT_PATH_VAR git_downloaded_dir
    )

    IF(NOT EXISTS "${git_downloaded_dir}")
        MESSAGE(FATAL_ERROR "Git directory download failed - output directory does not exist: ${git_downloaded_dir}")
    ENDIF()

    IF(NOT EXISTS "${git_downloaded_dir}/TEST_MODULE.cmake")
        MESSAGE(FATAL_ERROR "Git directory download failed - TEST_MODULE.cmake not found")
    ENDIF()
    IF(NOT EXISTS "${git_downloaded_dir}/README.md")
        MESSAGE(FATAL_ERROR "Git directory download failed - README.md not found")
    ENDIF()

    IF(DEFINED TEST_MODULE_MACRO)
        MESSAGE(FATAL_ERROR "TEST_MODULE_MACRO should not be defined! It is part of the downloaded TEST_MODULE.cmake")
    ENDIF()
    INCLUDE("${git_downloaded_dir}/TEST_MODULE.cmake")
    TEST_MODULE_MACRO()

    CMLIB_CACHE_DELETE(KEYWORDS TEST MODULE TEST)
    FILE(REMOVE_RECURSE "${CMLIB_REQUIRED_ENV_TMP_PATH}")
ENDMACRO()

MACRO(_TEST_GIT_SUBDIRECTORY_DOWNLOAD)
    CMLIB_DEPENDENCY(
        TYPE DIRECTORY
        URI "${GIT_URI}"
        GIT_PATH "cmake"
        GIT_REVISION "master"
        KEYWORDS TEST SUBDIR TEST
        OUTPUT_PATH_VAR git_subdir_downloaded_dir
    )

    IF(NOT EXISTS "${git_subdir_downloaded_dir}")
        MESSAGE(FATAL_ERROR "Git subdirectory download failed - output directory does not exist: ${git_subdir_downloaded_dir}")
    ENDIF()

    SET(base_dir "${git_subdir_downloaded_dir}")
    IF(NOT EXISTS "${base_dir}/README.txt")
        MESSAGE(FATAL_ERROR "Git subdirectory download failed - README.txt file not found")
    ENDIF()
    IF(NOT EXISTS "${base_dir}/dir_a")
        MESSAGE(FATAL_ERROR "Git subdirectory download failed - dir_a subdirectory not found")
    ENDIF()
    IF(NOT EXISTS "${base_dir}/dir_a/test.zip")
        MESSAGE(FATAL_ERROR "Git subdirectory download failed - test.zip file in dir_a not found")
    ENDIF()
    IF(NOT EXISTS "${base_dir}/dir_b")
        MESSAGE(FATAL_ERROR "Git subdirectory download failed - dir_b subdirectory not found")
    ENDIF()
    IF(NOT EXISTS "${base_dir}/dir_b/TestFileWithStory")
        MESSAGE(FATAL_ERROR "Git subdirectory download failed - TestFileWithStory not found in dir_b")
    ENDIF()
    IF(NOT EXISTS "${base_dir}/same")
        MESSAGE(FATAL_ERROR "Git subdirectory download failed - same subdirectory not found")
    ENDIF()

    CMLIB_CACHE_DELETE(KEYWORDS TEST SUBDIR TEST)
    FILE(REMOVE_RECURSE "${CMLIB_REQUIRED_ENV_TMP_PATH}")
ENDMACRO()

FUNCTION(TEST_GIT_DIRECTORY_ARCHIVE_ENABLED)
    CACHE_VAR_FORCE_SET(CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_DISABLE OFF)
    _TEST_GIT_DIRECTORY_DOWNLOAD()
    CACHE_VAR_RESTORE(CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_DISABLE)
ENDFUNCTION()

FUNCTION(TEST_GIT_DIRECTORY_ARCHIVE_DISABLED)
    CACHE_VAR_FORCE_SET(CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_DISABLE ON)
    _TEST_GIT_DIRECTORY_DOWNLOAD()
    CACHE_VAR_RESTORE(CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_DISABLE)
ENDFUNCTION()

FUNCTION(TEST_GIT_SUBDIRECTORY_ARCHIVE_ENABLED)
    CACHE_VAR_FORCE_SET(CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_DISABLE OFF)
    _TEST_GIT_SUBDIRECTORY_DOWNLOAD()
    CACHE_VAR_RESTORE(CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_DISABLE)
ENDFUNCTION()

FUNCTION(TEST_GIT_SUBDIRECTORY_ARCHIVE_DISABLED)
    CACHE_VAR_FORCE_SET(CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_DISABLE ON)
    _TEST_GIT_SUBDIRECTORY_DOWNLOAD()
    CACHE_VAR_RESTORE(CMLIB_FILE_DOWNLOAD_GIT_ARCHIVE_DISABLE)
ENDFUNCTION()



TEST_GIT_DIRECTORY_ARCHIVE_ENABLED()
TEST_GIT_DIRECTORY_ARCHIVE_DISABLED()
TEST_GIT_SUBDIRECTORY_ARCHIVE_ENABLED()
TEST_GIT_SUBDIRECTORY_ARCHIVE_DISABLED()
