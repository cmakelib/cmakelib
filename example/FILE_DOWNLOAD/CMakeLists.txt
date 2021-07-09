CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(CMLIB_CACHE_TEST)

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../")
FIND_PACKAGE(CMLIB)

SET(VALID_HTTP_URI           "http://cmake.org/")
SET(VALID_HTTP_CMAKE_URI     "https://github.com/Kitware/CMake/releases/download/v3.18.5/cmake-3.18.5-win64-x64.zip")
SET(VALID_GIT_URI            "${CMLIB_REQUIRED_ENV_REMOTE_URL}/cmakelib-test.git")
SET(VALID_GIT_FILE_PATH      "cmake/README.txt")
SET(VALID_GIT_DIRECTORY_PATH "cmake/")



#
# Download directory from git
#
CMLIB_FILE_DOWNLOAD(
	URI         "${VALID_GIT_URI}"
	GIT_PATH    "${VALID_GIT_DIRECTORY_PATH}"
	OUTPUT_PATH "${CMAKE_CURRENT_BINARY_DIR}/git_directory"
)

#
# Download GIT directory to another dir in filesystem
#
CMLIB_FILE_DOWNLOAD(
	URI         "${VALID_GIT_URI}"
	GIT_PATH    "${VALID_GIT_DIRECTORY_PATH}"
	OUTPUT_PATH "${CMAKE_CURRENT_BINARY_DIR}/git_directory/second"
)

#
# Download file from GIT and store it
# under original name.
#
CMLIB_FILE_DOWNLOAD(
	URI         "${VALID_GIT_URI}"
	GIT_PATH    "${VALID_GIT_FILE_PATH}"
	OUTPUT_PATH "${CMAKE_CURRENT_BINARY_DIR}/"
)

#
# Download file from GIT and store it
# under UTILS_NEW_NAME.cmake
#
CMLIB_FILE_DOWNLOAD(
	URI         "${VALID_GIT_URI}"
	GIT_PATH    "${VALID_GIT_FILE_PATH}"
	OUTPUT_PATH "${CMAKE_CURRENT_BINARY_DIR}/UTILS_NEW_NAME.cmake"
)

#
# Download and store file under remote name
#
CMLIB_FILE_DOWNLOAD(
	URI         "${VALID_HTTP_CMAKE_URI}"
	OUTPUT_PATH "${CMAKE_CURRENT_BINARY_DIR}/"
)

#
# Download and store file under choosen name (http_plugin.zip)
#
CMLIB_FILE_DOWNLOAD(
	URI         "${VALID_HTTP_CMAKE_URI}"
	OUTPUT_PATH "${CMAKE_CURRENT_BINARY_DIR}/cmake.zip"
)
