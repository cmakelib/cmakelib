##
#
# Test DEPENDENCY download failure scenarios for different URI schemes.
# Tests are organized into unreachable URIs and URI_TYPE mismatches.
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
    PROJECT(CMLIB_DEPENDENCY_DOWNLOAD_FAIL_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../")
FIND_PACKAGE(CMLIB)
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../transform_git_uri.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../test_resources/test_resources.cmake")



SET(DOWNLOAD_ERROR_TEMPLATE
    "Download files problem.[ ]+URI is unreachable, connection was interrupted or([\n]+[ \t]*)+timeout occurred.([\n]+[ \t]*)+Check combination of URI, URI_TYPE and other arguments and try again([\n]+[ \t]*)+URI:(([\n]+[ \t]*) | ([ ]*))+<uri>")

SET(_rg "[\n]*[ \t]*")
SET(URI_TYPE_MISMATCH_TEMPLATE
    "URI${_rg}'<uri>'${_rg}is not valid for <type>${_rg}URI_TYPE!")

SET(FILE_URI_DIRECTORY_TEMPLATE
    "Path specified by URI must be file for FILE URI_TYPE.[ ]+Directory${_rg}'<uri>'${_rg}provided.")

#
# Lets use tempplate. It is a really nice use case for that.
#
CMLIB_TEMPLATE_EXPAND(file_uri_unreachable_expected_msg DOWNLOAD_ERROR_TEMPLATE
    uri "file:///tmp/nonexistent_directory_12345/nonexistent_file.txt")

CMLIB_TEMPLATE_EXPAND(http_uri_unreachable_expected_msg DOWNLOAD_ERROR_TEMPLATE
    uri "https://nonexistent.domain.invalid/file.zip")

CMLIB_TEMPLATE_EXPAND(git_uri_unreachable_https_expected_msg DOWNLOAD_ERROR_TEMPLATE
    uri "https://nonexistent.domain.invalid/repo.git")

CMLIB_TEMPLATE_EXPAND(git_uri_unreachable_git_expected_msg DOWNLOAD_ERROR_TEMPLATE
    uri "git://nonexistent.domain.invalid/repo.git")

CMLIB_TEMPLATE_EXPAND(git_uri_unreachable_ssh_expected_msg DOWNLOAD_ERROR_TEMPLATE
    uri "git@nonexistent.domain.invalid:repo.git")

TRANSFORM_GIT_URI_TO_HTTPS(
    URI "${CMLIB_REQUIRED_ENV_REMOTE_URL}/cmakelib-test/archive/v1.0.0.zip"
    OUTPUT_VAR http_with_file_uri)

CMLIB_TEMPLATE_EXPAND(http_with_file_expected_msg URI_TYPE_MISMATCH_TEMPLATE
    uri "${http_with_file_uri}"
    type "FILE")

TRANSFORM_GIT_URI_TO_HTTPS(
    URI "${CMLIB_REQUIRED_ENV_REMOTE_URL}/cmakelib-test.git"
    OUTPUT_VAR git_with_file_uri)

CMLIB_TEMPLATE_EXPAND(git_with_file_expected_msg URI_TYPE_MISMATCH_TEMPLATE
    uri "${git_with_file_uri}"
    type "FILE")

TEST_RESROUCES_GET_FILE_URI("README.md" file_uri)
CMLIB_TEMPLATE_EXPAND(file_with_http_expected_msg URI_TYPE_MISMATCH_TEMPLATE
    uri "${file_uri}"
    type "HTTP")

CMLIB_TEMPLATE_EXPAND(file_with_git_expected_msg DOWNLOAD_ERROR_TEMPLATE
    uri "${file_uri}")

TRANSFORM_GIT_URI_TO_HTTPS(
    URI "${CMLIB_REQUIRED_ENV_REMOTE_URL}/cmakelib-test/archive/v1.0.0.zip"
    OUTPUT_VAR http_with_git_uri)

CMLIB_TEMPLATE_EXPAND(http_with_git_expected_msg DOWNLOAD_ERROR_TEMPLATE
    uri "${http_with_git_uri}")

TEST_RESOURCES_GET_BASE_DIR(test_resources_dir)
SET(dir_uri "file://${test_resources_dir}")
CMLIB_TEMPLATE_EXPAND(file_uri_directory_expected_msg FILE_URI_DIRECTORY_TEMPLATE
    uri "${dir_uri}")
MESSAGE(STATUS "${dir_uri}")


TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/unreachable_uris/http_uri_unreachable"
    "${http_uri_unreachable_expected_msg}")

TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/unreachable_uris/git_uri_unreachable_https"
    "${git_uri_unreachable_https_expected_msg}")

TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/unreachable_uris/git_uri_unreachable_git"
    "${git_uri_unreachable_git_expected_msg}")

TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/unreachable_uris/git_uri_unreachable_ssh"
    "${git_uri_unreachable_ssh_expected_msg}")

TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/uri_type_mismatches/http_with_file"
    "${http_with_file_expected_msg}")

TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/uri_type_mismatches/http_with_git"
    "${http_with_git_expected_msg}")

TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/uri_type_mismatches/git_with_file"
    "${git_with_file_expected_msg}")

TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/uri_type_mismatches/file_with_http"
    "${file_with_http_expected_msg}")

TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/uri_type_mismatches/file_with_git"
    "${file_with_git_expected_msg}")

TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/file_uri_directory"
    "${file_uri_directory_expected_msg}")
