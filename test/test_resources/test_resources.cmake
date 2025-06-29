## Download Test Resources
#
# Downloads cmakelib-test repository for local file:// URI testing
# Provides helper functions to access test resources via file:// URIs
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
    PROJECT(DOWNLOAD_TEST_RESOURCES)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../")
FIND_PACKAGE(CMLIB)

SET(_TEST_RESOURCES_BASE_DIR
    "${CMAKE_CURRENT_LIST_DIR}"
    CACHE INTERNAL "Test resources base directory"
)

SET(_TEST_RESOURCES_DIR
    "${_TEST_RESOURCES_BASE_DIR}/resources"
    CACHE INTERNAL "Test resources directory"
)

SET(_TEST_RESOURCES_DOWNLOAD_ENABLED
    OFF
    CACHE INTERNAL "Test resources directory"
)



## Download Test Resources Function
#
# <function> ()
#
# Downloads the cmakelib-test repository to provide local test resources
# for file:// URI testing across all test cases
#
FUNCTION(TEST_RESOURCES_DOWNLOAD)
    IF(NOT _TEST_RESOURCES_DOWNLOAD_ENABLED)
        MESSAGE(FATAL_ERROR "Test resources download disabled by _TEST_RESOURCES_DOWNLOAD_ENABLED = OFF!")
        RETURN()
    ENDIF()
    SET(test_repo_uri "${CMLIB_REQUIRED_ENV_REMOTE_URL}/cmakelib-test.git")
    CMLIB_FILE_DOWNLOAD(
        TYPE        GIT
        URI         "${test_repo_uri}"
        STATUS_VAR  download_status
        OUTPUT_PATH "${_TEST_RESOURCES_DIR}"
    )
    IF(NOT download_status)
        MESSAGE(FATAL_ERROR "Failed to download test resources from ${test_repo_uri}")
    ENDIF()
ENDFUNCTION()

##
#
# Enable test resources download.
# It is used to actively control if the Download functionality can be used or not.
# It is not desired to call Download in test cases!
#
# <function>()
#
FUNCTION(TEST_RESOURCES_DOWNLOAD_ENABLE)
    SET_PROPERTY(CACHE _TEST_RESOURCES_DOWNLOAD_ENABLED PROPERTY VALUE ON)
ENDFUNCTION()

##
#
# Disable test resources download.
#
# It is used to actively control if the Download functionality can be used or not.
# It is not desired to call Download in test cases!
#
# <function>()
#
FUNCTION(TEST_RESOURCES_DOWNLOAD_DISABLE)
    SET_PROPERTY(CACHE _TEST_RESOURCES_DOWNLOAD_ENABLED PROPERTY VALUE OFF)
ENDFUNCTION()

##
#
# Helper function to get file:// URI for test files from downloaded repository
#
# <function>(
#     <relative_path>  // Path relative to test repository root
#     <output_var>     // Variable to store the file:// URI
# )
#
FUNCTION(TEST_RESROUCES_GET_FILE_URI relative_path output_var)
    IF(NOT DEFINED _TEST_RESOURCES_DIR)
        MESSAGE(FATAL_ERROR "Test resources not downloaded!")
    ENDIF()

    SET(full_path "${_TEST_RESOURCES_DIR}/${relative_path}")
    GET_FILENAME_COMPONENT(full_path "${full_path}" ABSOLUTE)

    IF(NOT EXISTS "${full_path}")
        MESSAGE(FATAL_ERROR "Test resource file does not exist: ${full_path}")
    ENDIF()

    SET(${output_var} "file://${full_path}" PARENT_SCOPE)
ENDFUNCTION()

##
#
# Get base directory for test resources 
#
# <function>(
#     <output_var> // Variable name to store the base directory
# )
#
FUNCTION(TEST_RESOURCES_GET_BASE_DIR  output_var)
    SET(${output_var} "${_TEST_RESOURCES_BASE_DIR}" PARENT_SCOPE)
ENDFUNCTION()
