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

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../TEST.cmake")

SET(keywords_same_file_diff_remote_expected_errmsg
	"The file represented by\n *https://github.com/cmakelib/cmakelib-test.git;TEST_MODULE.cmake;master;A;B;XYZ\n *is already cached under\n *git@github.com:cmakelib/cmakelib-test.git;TEST_MODULE.cmake;master;A;B;C")

SET(keywords_expected_errmsg
	"DEPENDENCY hash mishmash - cached keywords 'GIT;ZIP;FILE' are not same as\n *required keywords 'GIT;ZIP;FILE3'")

SET(mixed_keywords_first_expected_errmsg
	"DEPENDENCY hash mishmash - cache created with keywords A;B;C but no\n *keywords provided")

SET(mixed_no_keywords_first_expected_errmsg
	"DEPENDENCY hash mishmash - cache created without keywords but keywords\n *provided 'A;B;C'")

SET(keywords_with_diff_remote_expected_msg 
	"The cache under keywords 'A;B;C' already exist for different remote")

SET(keywords_with_diff_revision_expected_msg 
	"DEPENDENCY version mishmash - different versions of the same file\n *'test-branch' vs 'master'")

SET(same_file_diff_revision_expected_msg 
	"DEPENDENCY version mishmash - different versions of the same file\n *'test-branch' vs 'master'")

SET(same_file_diff_remotes_expected_msg 
	"The file represented by\n *https://gitlab.com/cmakelib/cmakelib-test.git;TEST_MODULE.cmake;master; is\n *already cached under\n *git@github.com:cmakelib/cmakelib-test.git;TEST_MODULE.cmake;master;")


TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/keywords_same_file_diff_remote"
	"${keywords_same_file_diff_remote_expected_errmsgg}")
TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/keywords"
	"${keywords_expected_errmsg}")
TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/mixed_keywords_first"
	"${mixed_keywords_first_expected_errmsg}")
TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/mixed_no_keywords_first"
	"${mixed_no_keywords_first_expected_errmsg}")
TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/keywords_with_diff_remote"
	"${keywords_with_diff_remote_expected_errmsg}")
TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/keywords_with_diff_revision"
	"${keywords_with_diff_revision_expected_errmsg}")
TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/same_file_diff_revision"
	"${same_file_diff_revision_expected_msg}")
TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/same_file_diff_remotes"
	"${same_file_diff_remotes_expected_msg}")
