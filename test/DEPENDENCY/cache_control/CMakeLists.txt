##
#
# Test if combinations of cache antrie with explicit keywords 
# and implicit keywords emit an error.
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(CMLIB_ARCHIVE_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../")
FIND_PACKAGE(CMLIB)
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../transform_git_uri.cmake")

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../TEST.cmake")

TRANSFORM_GIT_URI_TO_HTTPS(
    URI "${CMLIB_REQUIRED_ENV_REMOTE_URL}/cmakelib-test.git"
    OUTPUT_VAR cache_control_test_uri
)
TRANSFORM_GIT_URI(
    URI "${CMLIB_REQUIRED_ENV_REMOTE_URL}/cmakelib-test.git"
    OUTPUT_VAR cache_control_ssh_uri
)
SET(keywords_same_file_diff_remote_expected_errmsg
	"The file represented by\n.*${cache_control_test_uri};TEST_MODULE.cmake;master;A;B;XYZ\n.*is already cached under\n.*${cache_control_ssh_uri};TEST_MODULE.cmake;master;A;B;C")

SET(cache_different_remote_expected_msg
	"The cache under keywords 'A;B;C' already exist for different remote")

SET(keywords_expected_errmsg
	"DEPENDENCY hash mishmash - cached keywords 'GIT;ZIP;FILE' are not same as.*required keywords 'GIT;ZIP;FILE3'")

SET(keywords_mismatch_abc_expected_errmsg
	"DEPENDENCY hash mishmash - cached keywords 'GIT;ZIP;FILE' are not same as.*required keywords 'A;B;C'")

SET(cache_created_with_keywords_expected_msg
	"DEPENDENCY hash mishmash - cache created with keywords A;B;C but no.*keywords provided")

SET(cache_created_without_keywords_expected_msg
	"DEPENDENCY hash mishmash - cache created without keywords.*but keywords.*provided 'A;B;C'")

SET(same_files_diff_remotes_expected_msg
	"The file represented by\n.*${cache_control_test_uri};TEST_MODULE.cmake;master;\n.*is already cached under\n.*${cache_control_ssh_uri};TEST_MODULE.cmake;master;A;B;C")



SET(VERSION_MISMATCH_TEMPLATE
	"DEPENDENCY version mishmash - different versions of the same file.*'<REVISION1>' vs '<REVISION2>'")

CMLIB_TEMPLATE_EXPAND(keywords_with_diff_revision_expected_msg VERSION_MISMATCH_TEMPLATE
	REVISION1 "test-branch" REVISION2 "master")

CMLIB_TEMPLATE_EXPAND(same_file_diff_revision_expected_msg VERSION_MISMATCH_TEMPLATE
	REVISION1 "test-branch" REVISION2 "master")



TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/keywords_same_file_diff_remote"
	"${keywords_same_file_diff_remote_expected_errmsg}")

TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/keywords"
	"${keywords_expected_errmsg}")

TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/mixed_keywords_first"
	"${cache_created_with_keywords_expected_msg}")

TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/mixed_no_keywords_first"
	"${cache_created_without_keywords_expected_msg}")

TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/keywords_with_diff_remote"
	"${cache_different_remote_expected_msg}")

TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/keywords_with_diff_revision"
	"${keywords_with_diff_revision_expected_msg}")

TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/same_file_diff_revision"
	"${same_file_diff_revision_expected_msg}")

TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/same_file_diff_remotes"
	"${same_file_diff_remotes_expected_msg}")
