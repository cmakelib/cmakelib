
IF(NOT  DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(CMLIB_CACHE_TEST)
ENDIF()

SET(CMLIB_DEPENDENCY_CONTROL OFF
	CACHE BOOL
	"Disable cache dependency control"
	FORCE
)

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../")
FIND_PACKAGE(CMLIB)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../TEST.cmake")

SET(HTTP_DOWNLOAD_URI_ZIP       "https://github.com/cmakelib/cmakelib-test/archive/v1.0.0.zip")
SET(HTTP_DOWNLOAD_URI_ZIP2      "https://github.com/cmakelib/cmakelib-test/archive/v1.1.0.zip")
SET(HTTP_DOWNLOAD_URI_ZIP3      "https://github.com/cmakelib/cmakelib-test/archive/v1.2.0.zip")
SET(GIT_DOWNLOAD_URI            "${CMLIB_REQUIRED_ENV_REMOTE_URL}/cmakelib-test.git")
SET(GIT_PATH_FILE               "cmake/README.txt")
SET(GIT_PATH_ZIP                "cmake/same/same.zip")
SET(GIT_PATH_DIRECTORY          "cmake/")
SET(GIT_REVISION_PATH_FILE      "cmake-test/test_branch_README.txt")
SET(GIT_REVISION_PATH_ZIP       "cmake-test/test_branch_same/same.zip")
SET(GIT_REVISION_PATH_DIRECTORY "cmake-test/")
SET(GIT_REVISION_NAME           "test-branch")

# Content of GIT_PATH_ZIP archive
SET(GIT_ZIP_CONTENT cmake1.png Release_CMake.jpg)



FUNCTION(DEPENDENCY_HTTP_DOWNLOAD)
	CMLIB_DEPENDENCY(
		KEYWORDS HTTP A B FILE
		TYPE FILE
		URI "${HTTP_DOWNLOAD_URI_ZIP}"
		OUTPUT_PATH_VAR  output_path
	)
	TEST_VAR_PATH_EXISTS(output_path)

	GET_FILENAME_COMPONENT(filename "${HTTP_DOWNLOAD_URI_ZIP}" NAME)
	GET_FILENAME_COMPONENT(filename_dependency "${output_path}" NAME)
	TEST_VAR_EQUAL(filename filename_dependency)

	CMLIB_DEPENDENCY(
		KEYWORDS A B ARCHIVE
		TYPE ARCHIVE
		URI "${HTTP_DOWNLOAD_URI_ZIP}"
		OUTPUT_PATH_VAR output_path_archive
	)
	TEST_VAR_PATH_EXISTS(output_path_archive)
	TEST_VAR_PATH_IS_DIRECTORY(output_path_archive)
ENDFUNCTION()

FUNCTION(DEPENDENCY_GIT_DOWNLOAD test_branch_files)

	SET(git_revision)
	SET(git_path_zip "${GIT_PATH_ZIP}")
	SET(git_path_directory "${GIT_PATH_DIRECTORY}")
	IF(test_branch_files)
		SET(git_revision GIT_REVISION "${GIT_REVISION_NAME}")
		SET(git_path_zip "${GIT_REVISION_PATH_ZIP}")
		SET(git_path_directory "${GIT_REVISION_PATH_DIRECTORY}")
	ENDIF()

	# Download zip as FILE
	CMLIB_DEPENDENCY(
		KEYWORDS GIT ZIP FILE
		TYPE FILE
		URI "${GIT_DOWNLOAD_URI}"
		GIT_PATH "${git_path_zip}"
		${git_revision}
		OUTPUT_PATH_VAR  output_path
	)
	TEST_VAR_PATH_EXISTS(output_path)

	# Download zip as ARCHIVE
	CMLIB_DEPENDENCY(
		KEYWORDS GIT ZIP ARCHIVE
		TYPE ARCHIVE
		URI "${GIT_DOWNLOAD_URI}"
		GIT_PATH "${git_path_zip}"
		${git_revision}
		OUTPUT_PATH_VAR  output_path_archive
	)
	TEST_VAR_PATH_EXISTS(output_path_archive)
	FILE(GLOB extracted_files "${output_path_archive}/*")
	FOREACH(extracted_file ${extracted_files})
		GET_FILENAME_COMPONENT(filename "${extracted_file}" NAME)
		LIST(FIND GIT_ZIP_CONTENT "${filename}" index)
		IF(index EQUAL -1)
			MESSAGE(FATAL_ERROR "Invalid content ${extracted_file}")
		ENDIF()
	ENDFOREACH()

	SET(output_path_directory)
	CMLIB_DEPENDENCY(
			KEYWORDS GIT DIRECTORY A
			TYPE DIRECTORY
			URI "${GIT_DOWNLOAD_URI}"
			GIT_PATH "${git_path_zip}"
			${git_revision}
			OUTPUT_PATH_VAR  output_path_directory
	)
	TEST_VAR_PATH_EXISTS(output_path_directory)

	SET(_tmp_cmake_path ${CMAKE_MODULE_PATH})
	CMLIB_DEPENDENCY(
		KEYWORDS GIT MODULE MASTER
		TYPE MODULE
		URI "${GIT_DOWNLOAD_URI}"
		GIT_PATH "TEST_MODULE.cmake"
	)
	INCLUDE(TEST_MODULE)
	TEST_MODULE_MACRO()
	SET(CMAKE_MODULE_PATH ${_tmp_cmake_path})

#
# These tests does not pass in Github actions.
# I really do not known why
#
	CMLIB_DEPENDENCY(
		KEYWORDS GIT MODULE TESTBRANCHWF1
		TYPE MODULE
		URI "${GIT_DOWNLOAD_URI}"
		GIT_REVISION "${GIT_REVISION_NAME}"
		URI_TYPE GIT
		OUTPUT_PATH_VAR test_output_path
	)
	INCLUDE(TEST_MODULE)
	TEST_MODULE_MACRO()
	SET(CMAKE_MODULE_PATH ${_tmp_cmake_path})

	CMLIB_DEPENDENCY(
		KEYWORDS GIT MODULE TESTBRANCHWF2
		TYPE MODULE
		URI "${GIT_DOWNLOAD_URI}"
		URI_TYPE GIT
		OUTPUT_PATH_VAR test_output_path
	)
	INCLUDE(TEST_MODULE)
	TEST_MODULE_MACRO()
	SET(CMAKE_MODULE_PATH ${_tmp_cmake_path})
ENDFUNCTION()

FUNCTION(DEPENDENCY_CHECK_CACHE_PATH_WITHOUT_KEYWORDS)
	CMLIB_DEPENDENCY(
		URI "${HTTP_DOWNLOAD_URI_ZIP2}"
		TYPE ARCHIVE
		OUTPUT_PATH_VAR path_var_zip2
	)
	TEST_VAR_PATH_EXISTS(path_var_zip2)
	CMLIB_DEPENDENCY(
		URI "${HTTP_DOWNLOAD_URI_ZIP3}"
		TYPE ARCHIVE
		OUTPUT_PATH_VAR path_var_zip3
	)
	TEST_VAR_PATH_EXISTS(path_var_zip3)
	TEST_VAR_NOT_EQUAL(path_var_zip2 path_var_zip3)
ENDFUNCTION()

FUNCTION(DEPENDENCY_CHECK_CACHE_AND_GET_BY_KEYWORDS)
	CMLIB_DEPENDENCY(
		KEYWORDS HTTP GET BY KEYWORDS
		TYPE FILE
		URI "${HTTP_DOWNLOAD_URI_ZIP}"
		OUTPUT_PATH_VAR  output_path
	)

	CMLIB_DEPENDENCY(
		KEYWORDS HTTP GET BY KEYWORDS
		TYPE FILE
		OUTPUT_PATH_VAR output_path2
	)
	TEST_VAR_PATH_EXISTS(output_path2)
	TEST_VAR_EQUAL(output_path output_path2)
ENDFUNCTION()

FUNCTION(DEPENDENCY_INVALID_ARGUMENTS)
	TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/argument_missing")
ENDFUNCTION()



DEPENDENCY_HTTP_DOWNLOAD()
DEPENDENCY_GIT_DOWNLOAD(ON)
DEPENDENCY_GIT_DOWNLOAD(OFF)
DEPENDENCY_INVALID_ARGUMENTS()
DEPENDENCY_CHECK_CACHE_AND_GET_BY_KEYWORDS()
DEPENDENCY_CHECK_CACHE_PATH_WITHOUT_KEYWORDS()

TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/cache_control")
