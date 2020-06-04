
CMAKE_MINIMUM_REQUIRED(VERSION 3.16)
PROJECT(BIMCM_CACHE_TEST)

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../")
FIND_PACKAGE(BIMCM)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../TEST.cmake")

SET(HTTP_DOWNLOAD_URI_ZIP "http://data2.bimproject.cz/plugins/release/BPC.AC.WIN.zip")
SET(GIT_DOWNLOAD_URI "ssh://git@stash.bimproject.cz:7999/bpcomm/cmake-lib-test.git")
SET(GIT_PATH_FILE "cmake/README.txt")
SET(GIT_PATH_ZIP "cmake/dir_a/test.zip")
SET(GIT_PATH_DIRECTORY "cmake/")
SET(GIT_REVISION_PATH_FILE "cmake-test/test_branch_README.txt")
SET(GIT_REVISION_PATH_ZIP "cmake-test/test_branch_dir_a/test.zip")
SET(GIT_REVISION_PATH_DIRECTORY "cmake-test/")
SET(GIT_REVISION_NAME "test-branch")

# Content of GIT_PATH_ZIP archive
SET(GIT_ZIP_CONTENT cmake1.png Release_CMake.jpg)



FUNCTION(DEPENDENCY_HTTP_DOWNLOAD)
	BIMCM_DEPENDENCY(
		KEYWORDS HTTP A B FILE
		TYPE FILE
		URI "${HTTP_DOWNLOAD_URI_ZIP}"
		OUTPUT_PATH_VAR  output_path
	)
	TEST_VAR_PATH_EXISTS(output_path)

	GET_FILENAME_COMPONENT(filename "${HTTP_DOWNLOAD_URI_ZIP}" NAME)
	GET_FILENAME_COMPONENT(filename_dependency "${output_path}" NAME)
	TEST_VAR_EQUAL(filename filename_dependency)

	BIMCM_DEPENDENCY(
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
	BIMCM_DEPENDENCY(
		KEYWORDS GIT ZIP FILE
		TYPE FILE
		URI "${GIT_DOWNLOAD_URI}"
		GIT_PATH "${git_path_zip}"
		${git_revision}
		OUTPUT_PATH_VAR  output_path
	)
	TEST_VAR_PATH_EXISTS(output_path)

	# Download zip as ARCHIVE
	BIMCM_DEPENDENCY(
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
	BIMCM_DEPENDENCY(
			KEYWORDS GIT DIRECTORY A
			TYPE DIRECTORY
			URI "${GIT_DOWNLOAD_URI}"
			GIT_PATH "${git_path_zip}"
			${git_revision}
			OUTPUT_PATH_VAR  output_path_directory
	)
	TEST_VAR_PATH_EXISTS(output_path_directory)

	SET(_tmp_cmake_path ${CMAKE_MODULE_PATH})
	BIMCM_DEPENDENCY(
		KEYWORDS GIT MODULE MASTER
		TYPE MODULE
		URI "${GIT_DOWNLOAD_URI}"
		GIT_PATH "TEST_MODULE.cmake"
	)
	INCLUDE(TEST_MODULE)
	TEST_MODULE_MACRO()
	SET(CMAKE_MODULE_PATH ${_tmp_cmake_path})

	SET(test_output_path "testik")
	BIMCM_DEPENDENCY(
		KEYWORDS GIT MODULE TESTBRANCH
		TYPE MODULE
		URI "${GIT_DOWNLOAD_URI}"
		GIT_PATH "TEST_MODULE.cmake"
		GIT_REVISION "${GIT_REVISION_NAME}"
		OUTPUT_PATH_VAR test_output_path
	)
	IF(NOT ("${test_output_path}" STREQUAL "testik"))
		MESSAGE(FATAL_ERROR "test_output_var modified! ${test_output_path}")
	ENDIF()
	INCLUDE(TEST_MODULE)
	TEST_MODULE_MACRO()
	SET(CMAKE_MODULE_PATH ${_tmp_cmake_path})


	BIMCM_DEPENDENCY(
		KEYWORDS GIT MODULE TESTBRANCHWF1
		TYPE MODULE
		URI "${GIT_DOWNLOAD_URI}"
		GIT_REVISION "${GIT_REVISION_NAME}"
		OUTPUT_PATH_VAR test_output_path
	)
	INCLUDE(TEST_MODULE)
	TEST_MODULE_MACRO()
	SET(CMAKE_MODULE_PATH ${_tmp_cmake_path})

	BIMCM_DEPENDENCY(
		KEYWORDS GIT MODULE TESTBRANCHWF2
		TYPE MODULE
		URI "${GIT_DOWNLOAD_URI}"
		OUTPUT_PATH_VAR test_output_path
	)
	INCLUDE(TEST_MODULE)
	TEST_MODULE_MACRO()
	SET(CMAKE_MODULE_PATH ${_tmp_cmake_path})
ENDFUNCTION()

FUNCTION(DEPENDENCY_INVALID_ARGUMENTS)
	TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/argument_missing")
ENDFUNCTION()



DEPENDENCY_HTTP_DOWNLOAD()
DEPENDENCY_GIT_DOWNLOAD(ON)
DEPENDENCY_GIT_DOWNLOAD(OFF)
DEPENDENCY_INVALID_ARGUMENTS()

