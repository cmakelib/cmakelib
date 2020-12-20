#
# CMLIB_DEPENDENCY examples
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.16)
PROJECT(CMLIB_CACHE_TEST)

SET(CMLIB_DEPENDENCY_CONTROL OFF
	CACHE BOOL
	"Disable dependency cache control"
)


#
# In production this may be omitted because
# the path to the CMLIB library is stored in
# global variable. Look at the <git_root>/README
#
LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../")
FIND_PACKAGE(CMLIB)

SET(HTTP_DOWNLOAD_URI_ZIP "https://github.com/cmakelib/cmakelib-test/archive/v1.0.0.zip")
SET(GIT_DOWNLOAD_URI "${CMLIB_REQUIRED_ENV_REMOTE_URL}/cmakelib-test.git")
SET(GIT_TEST_BRANCH "test-branch")
SET(GIT_CMAKE_MODULE_PATH "TEST_MODULE.cmake")
SET(GIT_CMAKE_MODULE_NAME "TEST_MODULE")



#
# Add file dependency.
# Cache file under keywords A;B;FILE
# and store path to the file to 'output_path' variable
#
CMLIB_DEPENDENCY(
	KEYWORDS A B FILE
	TYPE FILE
	URI "${HTTP_DOWNLOAD_URI_ZIP}"
	OUTPUT_PATH_VAR output_path
)
MESSAGE(STATUS "DEPENDENCY: ${output_path}")

#
# Add Archive dependency.
# Download and extract archive and add extracted content as dependency
# Return extracted archive path in 'output_path' variable
#
UNSET(output_path)
CMLIB_DEPENDENCY(
	KEYWORDS A B ARCHIVE ZIP
	TYPE ARCHIVE
	URI "${HTTP_DOWNLOAD_URI_ZIP}"
	OUTPUT_PATH_VAR output_path
)
MESSAGE(STATUS "DEPENDENCY: ${output_path}")

#
# Add Directory dependency.
# Download whole git repository and cache result.
# Return directory path in 'output_path' variable
#
UNSET(output_path)
CMLIB_DEPENDENCY(
	KEYWORDS A B DIRECTORY
	TYPE DIRECTORY
	URI "${GIT_DOWNLOAD_URI}"
	GIT_PATH "./"
	OUTPUT_PATH_VAR output_path
)
MESSAGE(STATUS "DEPENDENCY: ${output_path}")

#
# Download "./cmake" directory from given git repository.
# A;B;DIRECTORY already exist and will not be created.
# Instead the previous cache entry represented by A;B;DIRECTORY
# will be used.
# This is useful if we have dependency already registered but we want to
# obtain only path from cache.
# The TYPE is not used by CMLIB_DEPENDENCY but cannot be omitted.
#
UNSET(output_path)
CMLIB_DEPENDENCY(
	KEYWORDS A B DIRECTORY
	TYPE DIRECTORY
	OUTPUT_PATH_VAR output_path
)
MESSAGE(STATUS "DEPENDENCY: ${output_path}")

#
# Download whole git repository from TEST branch
# Return directory path in 'output_path' variable
#
UNSET(output_path)
CMLIB_DEPENDENCY(
	KEYWORDS A B TESTBRANCH
	TYPE DIRECTORY
	URI        "${GIT_DOWNLOAD_URI}"
	GIT_PATH   "./"
	GIT_REVISION "${GIT_TEST_BRANCH}"
	OUTPUT_PATH_VAR output_path
)
MESSAGE(STATUS "DEPENDENCY: ${output_path}")

#
# Download file as MODULE.
# DEPENDENCY function
#	- download file from remote server
#	- add module path to CMAKE_MODULE_PATH
# 'output_path' is ignored
#
UNSET(output_path)
SET(_tmp_cmake_module_path ${CMAKE_MODULE_PATH})
CMLIB_DEPENDENCY(
	KEYWORDS A B TESTMODULE
	TYPE MODULE
	URI        "${GIT_DOWNLOAD_URI}"
	GIT_PATH   "${GIT_CMAKE_MODULE_PATH}"
	GIT_REVISION "${GIT_TEST_BRANCH}"
	OUTPUT_PATH_VAR output_path
)
MESSAGE(STATUS "DEPENDENCY: ${output_path}")

INCLUDE(${GIT_CMAKE_MODULE_NAME})
TEST_MODULE_MACRO()

#
# Download file as MODULE.
# If we do not specify GIT_REVISION the master branch is taken.
#
SET(CMAKE_MODULE_PATH "${_tmp_cmake_module_path}")
CMLIB_DEPENDENCY(
	KEYWORDS A B MASTERTESTMODULE
	TYPE MODULE
	URI        "${GIT_DOWNLOAD_URI}"
	GIT_PATH   "${GIT_CMAKE_MODULE_PATH}"
	OUTPUT_PATH_VAR output_path
)

#
# output_path is not modified for type "MODULE".
#
MESSAGE(STATUS "DEPENDENCY: ${output_path}")

INCLUDE(${GIT_CMAKE_MODULE_NAME})
TEST_MODULE_MACRO()

UNSET(output_path)
