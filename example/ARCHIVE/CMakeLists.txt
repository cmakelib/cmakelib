##
#
# ARCHIVE module examples
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.16)
PROJECT(CMLIB_CACHE_TEST)

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../")
FIND_PACKAGE(CMLIB)



#
# Extract BZ2 archive into binary directory.
# ARCHVI_TYPE will be determined from archive_name
#
FILE(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/archive.bz2/")
CMLIB_ARCHIVE_EXTRACT(
	ARCHIVE_PATH "${CMAKE_CURRENT_LIST_DIR}/archive/archive.bz2"
	OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/archive.bz2/"
)

#
# Extract archive into binary directory.
# ARCHIVE_TYPE must be explicitly specified because
# AUTO deduction of ARCHIVE_TYPE is done by file extension
#
FILE(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/archive_bz2/")
CMLIB_ARCHIVE_EXTRACT(
	ARCHIVE_PATH "${CMAKE_CURRENT_LIST_DIR}/archive/archive_bz2"
	ARCHIVE_TYPE BZ2
	OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/archive_bz2/"
)

#
# We can extract multi archives (tar.bz2, tar.gz).
#
FILE(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/archive.tar.bz2/")
CMLIB_ARCHIVE_EXTRACT(
	ARCHIVE_PATH "${CMAKE_CURRENT_LIST_DIR}/archive/archive.tar.bz2"
	OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/archive.tar.bz2/"
)

#
# If we want to only decompress (obtain .tar instead of .tar content)
# we must explicitly specify ARCHIVE_TYPE.
#
FILE(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/archive.tar.bz2_tar_only/")
CMLIB_ARCHIVE_EXTRACT(
	ARCHIVE_PATH "${CMAKE_CURRENT_LIST_DIR}/archive/archive.tar.bz2"
	ARCHIVE_TYPE BZ2
	OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/archive.tar.bz2_tar_only/"
)
