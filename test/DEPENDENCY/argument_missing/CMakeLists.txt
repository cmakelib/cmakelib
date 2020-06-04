## Main
#
# Check if the DEPENDENCY omit an error if
# OUTPUT_PATH_VAR is missing.
#
# We test this only for FILE type. (it's not necessary to
# test for all types. We add these tests if needed)
#
#



CMAKE_MINIMUM_REQUIRED(VERSION 3.16)
PROJECT(BIMCM_ARCHIVE_TEST)

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../")
FIND_PACKAGE(BIMCM)

SET(GIT_DOWNLOAD_URI "ssh://git@stash.bimproject.cz:7999/bpcomm/cmake-lib-test.git")

#
# Download zip as FILE
# Comment out OUTPUT_PATH_VAR --> function omit error
#
BIMCM_DEPENDENCY(
	KEYWORDS GIT ZIP FILE
	TYPE FILE
	URI "${GIT_DOWNLOAD_URI}"
	GIT_PATH "TEST_MODULE.cmake"
#OUTPUT_PATH_VAR output_path
)
