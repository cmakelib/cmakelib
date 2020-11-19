#
#
#
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.16)
PROJECT(CMLIB_CACHE_TEST)

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../")
FIND_PACKAGE(CMLIB)


#
# We can check that the cache file exist
#
CMLIB_CACHE_HAS_FILE(
	KEYWORDS A C B
	PATH_VAR path_var
)
IF(DEFINED path_var)
	#
	# Even if the file exist we can
	# call CACHE_ADD.
	# Macro automatically regeneretes it's own
	# cache content untill cache dir remains untouched.
	# CACHE_ADD can be called after CMAke cache is deleted
	# --> cache is regenerated if there are cache files for given keywords set.
	#
	CMLIB_CACHE_ADD(
		KEYWORDS A C B
		PATH "${CMAKE_CURRENT_LIST_DIR}/A_B_C.txt"
		CACHE_PATH_VAR var_a_c_b
		KEYWORDS_PERMUTATION_ALLOWED ON
	)

	#
	# Delete cache entry because we cannot call CACHE_ADD
	# for same keywords set two times.
	#
	CMLIB_CACHE_DELETE(KEYWORDS A C B)
ENDIF()

#
# Add A,B,C Cache entry
#
CMLIB_CACHE_ADD(
	KEYWORDS A B C
	PATH "${CMAKE_CURRENT_LIST_DIR}/A_B_C.txt"
	CACHE_PATH_VAR var_a_b_c
)
MESSAGE(STATUS "A_B_C Cache: ${var_a_b_c}")

#
# If the cache entry already exist we can use
# flag GET_IF_EXISTS to not add file to cache again
# but return existing one in CACHE_PATH_VAR (CACHE_PATH_VAR is not mandatory).
#
UNSET(path_var)
CMLIB_CACHE_ADD(
	KEYWORDS A B C
	PATH "${CMAKE_CURRENT_LIST_DIR}/Directory/A.txt"
	GET_IF_EXISTS ON
	CACHE_PATH_VAR path_var
)

#
# Without KEYWORDS_PERMUTATION_ALLOWED
# this call omit error. (because we cannot have
# two permutation of the same keywords set)
#
CMLIB_CACHE_ADD(
	KEYWORDS A C B
	PATH "${CMAKE_CURRENT_LIST_DIR}/A_B_C.txt"
	CACHE_PATH_VAR var_a_c_b
	KEYWORDS_PERMUTATION_ALLOWED ON
)
MESSAGE(STATUS "A_C_B Cache: ${var_a_c_b}")

#
# Cache whole directory
#
CMLIB_CACHE_ADD(
	KEYWORDS A B C DIRECTORY
	PATH "${CMAKE_CURRENT_LIST_DIR}/Directory"
	CACHE_PATH_VAR var_a_b_c_directory
)
MESSAGE(STATUS "A_B_C_Directory Cache: ${var_a_b_c_directory}")

#
# Cache directory with different keywords
#
CMLIB_CACHE_ADD(
	KEYWORDS DIRECTORY TEST
	PATH "${CMAKE_CURRENT_LIST_DIR}/Directory"
	CACHE_PATH_VAR var_directory_test
)
MESSAGE(STATUS "directory_test Cache: ${var_directory_test}")

#
# Obtain cache entry and store result to
# get_var_a_b_c.
# If no cache entry is found get_var_a_b_c is
# not defined. (we can you IF(DEFINED <>) ...)
#
CMLIB_CACHE_GET(
	KEYWORDS A B C
	CACHE_PATH_VAR get_var_a_b_c
)
MESSAGE(STATUS "Cache entry: ${get_var_a_b_c}")

#
# Delete all cache entries and cache files.
# Delete whole directory structure if there are
# no files left.
#
CMLIB_CACHE_DELETE(KEYWORDS A B C)
CMLIB_CACHE_DELETE(KEYWORDS A B C DIRECTORY)
CMLIB_CACHE_DELETE(KEYWORDS DIRECTORY TEST)
