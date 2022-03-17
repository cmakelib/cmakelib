## Main
#
# Check if DEPENDENCY emit an error if we
# try to add same file with different URI
# under explicit diffirent keyword sets.
#

IF(NOT  DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(CMLIB_ARCHIVE_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../../")
FIND_PACKAGE(CMLIB)

SET(GIT_DOWNLOAD_URI  "git@github.com:cmakelib/cmakelib-test.git")
SET(GIT_DOWNLOAD_URI2 "https://github.com/cmakelib/cmakelib-test.git")



CMLIB_DEPENDENCY(
	KEYWORDS A B C
	TYPE FILE
	URI "${GIT_DOWNLOAD_URI}"
	GIT_REVISION "master"
	GIT_PATH     "TEST_MODULE.cmake"
	OUTPUT_PATH_VAR output_path
)

CMLIB_DEPENDENCY(
	KEYWORDS A B XYZ
	TYPE FILE
	URI "${GIT_DOWNLOAD_URI2}"
	GIT_REVISION "master"
	GIT_PATH     "TEST_MODULE.cmake"
	OUTPUT_PATH_VAR output_path
)

