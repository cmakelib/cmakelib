## Main
#
# Check if DEPENDENCY imit and error if
# we try to add same resurce as a DEPENDENCY
# under multiple keywords
#

IF(NOT  DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.16)
	PROJECT(CMLIB_ARCHIVE_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../")
FIND_PACKAGE(CMLIB)

SET(GIT_DOWNLOAD_URI "${CMLIB_REQUIRED_ENV_REMOTE_URL}/cmakelib-test.git")



CMLIB_DEPENDENCY(
	TYPE FILE
	URI "${GIT_DOWNLOAD_URI}"
	GIT_REVISION "test-branch"
	GIT_PATH     "TEST_MODULE.cmake"
	OUTPUT_PATH_VAR output_path
)

CMLIB_DEPENDENCY(
	TYPE FILE
	URI "${GIT_DOWNLOAD_URI}"
	GIT_PATH     "TEST_MODULE.cmake"
	OUTPUT_PATH_VAR output_path
)

CMLIB_DEPENDENCY(
	TYPE FILE
	URI "${GIT_DOWNLOAD_URI}"
	GIT_REVISION "test-branch"
	GIT_PATH     "TEST_MODULE.cmake"
	OUTPUT_PATH_VAR output_path
)

