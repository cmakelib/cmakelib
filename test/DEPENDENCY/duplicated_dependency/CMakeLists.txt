##
#
#
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.16)
	PROJECT(CMLIB_ARCHIVE_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../")
FIND_PACKAGE(CMLIB)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../TEST.cmake")

SET(keywords_expected_errmsg
	"DEPENDENCY hash mishmash - cached keywords 'GIT,ZIP,FILE' are not same as\n *required keywords 'GIT;ZIP;FILE3'")

SET(mixed_keywords_first_expected_errmsg
	"DEPENDENCY hash mishmash - cache created with keywords A,B,C but no\n *keywords provided")

SET(mixed_no_keywords_first_expected_errmsg
	"DEPENDENCY hash mishmash - cache created without keywords but keywords\n *provided 'A;B;C'")

TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/keywords"                "${keywords_expected_errmsg}")
TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/mixed_keywords_first"    "${mixed_keywords_first_expected_errmsg}")
TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/mixed_no_keywords_first" "${mixed_no_keywords_first_expected_errmsg}")
