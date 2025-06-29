## Main
#
# Check if DEPENDENCY emit and error if
# we try to add same resurce under explicit keywords and
# without explicit keywords
#
# TEST must FAIL
#

IF(NOT  DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(CMLIB_ARCHIVE_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../")
FIND_PACKAGE(CMLIB)
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../../transform_git_uri.cmake")

TRANSFORM_GIT_URI(
    URI "${CMLIB_REQUIRED_ENV_REMOTE_URL}/cmakelib-test.git"
    OUTPUT_VAR GIT_DOWNLOAD_URI
)



CMLIB_DEPENDENCY(
	TYPE FILE
	URI "${GIT_DOWNLOAD_URI}"
	GIT_REVISION "test-branch"
	GIT_PATH     "TEST_MODULE.cmake"
	OUTPUT_PATH_VAR output_path
)

CMLIB_DEPENDENCY(
	TYPE FILE
	KEYWORDS A B C
	URI "${GIT_DOWNLOAD_URI}"
	GIT_REVISION "test-branch"
	GIT_PATH     "TEST_MODULE.cmake"
	OUTPUT_PATH_VAR output_path
)
