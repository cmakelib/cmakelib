## Main
#
# Check if DEPENDENCY emit and error if
# we try to add same file from defferent remotes
#
# TEST must FAIL
#

IF(NOT  DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(CMLIB_ARCHIVE_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../")
FIND_PACKAGE(CMLIB)

SET(GIT_DOWNLOAD_URI_A "git@github.com:cmakelib/cmakelib-test.git")
SET(GIT_DOWNLOAD_URI_B "https://gitlab.com/cmakelib/cmakelib-test.git")



CMLIB_DEPENDENCY(
	TYPE FILE
	URI "${GIT_DOWNLOAD_URI_A}"
	GIT_PATH     "TEST_MODULE.cmake"
	OUTPUT_PATH_VAR output_path
)

CMLIB_DEPENDENCY(
	TYPE FILE
	URI "${GIT_DOWNLOAD_URI_B}"
	GIT_PATH     "TEST_MODULE.cmake"
	OUTPUT_PATH_VAR output_path
)

