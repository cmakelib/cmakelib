##
#
# Check if files are extracted correctly.
#
# Content of "archive/archive*" archives is
#   - A.txt has content "A"
#   - B.txt has content "B"
#   - C.txt has content "C"
#
# Content of "archive/symlink*" archives is
#   - dir/test.txt has content "TEST FILE R"
#   - test.txt symlink to "dir/test.txt"
#

IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
	PROJECT(CMLIB_ARCHIVE_TEST)
ENDIF()

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../")
FIND_PACKAGE(CMLIB)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../TEST.cmake")



FUNCTION(TEST_EXTRACT archive_name archive_type)
	SET(output_dir "${CMAKE_CURRENT_BINARY_DIR}/${archive_name}/")
	FILE(MAKE_DIRECTORY ${output_dir})

	SET(archive_type_arg)
	IF(archive_type)
		SET(archive_type_arg ARCHIVE_TYPE ${archive_type})
	ENDIF()

	CMLIB_ARCHIVE_EXTRACT(
		ARCHIVE_PATH "${CMAKE_CURRENT_LIST_DIR}/archive/${archive_name}"
		${archive_type_arg}
		OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${archive_name}/"
	)
	CMLIB_ARCHIVE_EXTRACT(
		ARCHIVE_PATH "${CMAKE_CURRENT_LIST_DIR}/archive/${archive_name}"
		${archive_type_arg}
		OUTPUT_PATH_VAR var
	)
	_CMLIB_LIBRARY_DEBUG_MESSAGE("Output path for archive: ${var}")	
	TEST_VAR_PATH_EXISTS(var)
ENDFUNCTION()

FUNCTION(TEST_EXCTRACT_WITH_SYMLINK archive_name)
	SET(archive_path "${CMAKE_CURRENT_LIST_DIR}/archive/${archive_name}")
	SET(output_dir "${CMAKE_CURRENT_BINARY_DIR}/${archive_name}/")
	FILE(MAKE_DIRECTORY ${output_dir})
	CMLIB_ARCHIVE_EXTRACT(
		ARCHIVE_PATH     "${archive_path}"
		OUTPUT_DIRECTORY "${output_dir}"
	)
	FILE(READ "${output_dir}/test.txt"     root_file_content_symlink)
	FILE(READ "${output_dir}/dir/test.txt" root_file_content_dir)
	TEST_VAR_EQUAL(root_file_content_dir root_file_content_symlink)
ENDFUNCTION()

FUNCTION(TEST_INVALID_TYPE)
	TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/invalid_archive_type_test/")
ENDFUNCTION()

FUNCTION(TEST_INVALID_OUTPUT_ARG)
	TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/invalid_output_var/")
ENDFUNCTION()



TEST_INVALID_TYPE()
TEST_INVALID_OUTPUT_ARG()

TEST_EXTRACT(archive.zip "")
TEST_EXTRACT(archive.bz2 "")
TEST_EXTRACT(archive.gz "")
TEST_EXTRACT(archive.xz "")
TEST_EXTRACT(archive_tar.tar "")
TEST_EXTRACT(archive_tar.tar.bz2 "")
TEST_EXTRACT(archive.tar.xz "")

TEST_EXTRACT(archive_tar_bz2 TAR.BZ2)
TEST_EXTRACT(archive_tar_gz TAR.GZ)
TEST_EXTRACT(archive_tar_xz TAR.XZ)
TEST_EXTRACT(archive_zip ZIP)
TEST_EXTRACT(archive_tar TAR)
TEST_EXTRACT(archive_xz XZ)

# Under windowswe do not want to use symlinks in tar
CMAKE_HOST_SYSTEM_INFORMATION(RESULT system_name QUERY OS_NAME)
IF(NOT system_name STREQUAL "Windows")
	TEST_EXCTRACT_WITH_SYMLINK(symlink.tar)
	TEST_EXCTRACT_WITH_SYMLINK(symlink.zip)
ENDIF()
