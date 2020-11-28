##
#
#
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.16)
	PROJECT(CMLIB_ARCHIVE_TEST)
ENDIF()

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../TEST.cmake")

SET(keywords_expected_errmsg
	"DEPENDENCY hash mishmash - cached keywords 'GIT,ZIP,FILE'"
	"[ ]*are not same as required keywords 'GIT;ZIP;FILE3'")

SET(without_keywords_expected_errmsg
	)


TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/keywords" "${keywords_expected_errmsg}")
TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/mixed_keywords_first")
TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/mixed_no_keywords_first")
