## Main
#
# Only one of can be specified at one time:
#	OUTPUT_DIRECTORY
#	OUTPUT_VAR
#



CMAKE_MINIMUM_REQUIRED(VERSION 3.16)
PROJECT(CMLIB_ARCHIVE_TEST)

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../")
FIND_PACKAGE(CMLIB)

SET(archive_name archive.bz2)
SET(output_dir "${CMAKE_CURRENT_BINARY_DIR}/${archive_name}/")
FILE(MAKE_DIRECTORY ${output_dir})
CMLIB_ARCHIVE_EXTRACT(
	ARCHIVE_PATH "${CMAKE_CURRENT_LIST_DIR}/../archive/${archive_name}"
	ARCHIVE_TYPE "BZ2"
	OUTPUT_DIRECTORY "${output_dir}"
	OUTPUT_PATH_VAR my_output_var
)
