## Main
#
# Check if the DEPENDENCY omit an error if
# OUTPUT_PATH_VAR is missing.
#
# We test this only for FILE type. (it's not necessary to
# test for all types. We add these tests if needed)
#
#



IF(NOT  DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(CMLIB_ARCHIVE_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../")
FIND_PACKAGE(CMLIB)

GET_FILENAME_COMPONENT(base_url "${CMLIB_REQUIRED_ENV_REMOTE_URL}" DIRECTORY)

SET(GIT_DOWNLOAD_URI "${base_url}/cmakelib-test.git")

#
# Download zip as FILE
# Comment out OUTPUT_PATH_VAR --> function omit error
#
CMLIB_DEPENDENCY(
	KEYWORDS GIT ZIP FILE
	TYPE FILE
	URI "${GIT_DOWNLOAD_URI}"
	GIT_PATH "TEST_MODULE.cmake"
#OUTPUT_PATH_VAR output_path
)
