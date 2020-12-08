## Main
#
# CMake cache
# It enables store files/directories into a cache
# and retrieve them if needed.
#
# Each cache entry is identified by
# - ordered set of keywords refered as cache id.
#   Keywords order is done by user (so under in which keywords are listed)
# - file system repsentation --> we can reconstruct cache if we lost
#   cache entries in CMake cache.
#
# Cache entry is represented by CMake Cache variable.
# Cache variable - <_CMLIB_CACHE_VAR_ENTRY_PREFIX>_{keywords, ...}.join('_')
# These variables are stored as list in CMLIB_CACHE_ENTRY_LIST cache variable.
#
# Value of cache entry/cache entry variable is path where files are cached.
#
## Cache representation
# Cache consist from set of Cache entries.
# Each cache entry is represented by ordered set called Keywords.
# Cache file (for given cache entry) is stored in Cache Entry Variable
# and saved to File system folder hierarchy.
#
# Keywords is non-empty ordered set of uppercase strings.
# - Let K is keyword set then K_i, i from {1, 2, ... |K|} is
# i-th element of ordered set K (we assume that K = (K_1, K_2, ..., K_n)
# where n is number of elements in K).
# - let A, B are keyword set. We say that A is subset of B when
# there is some _m_ from N, _m_ <= min(|A|, |B|) and forall _i_ in {1, 2, ... _m_}:
# A_i = B_i
#
# Cache Entry Variable is standard CMake cache variable
# in form <_CMLIB_CACHE_VAR_ENTRY_PREFIX>_{keywords, ...}.join('_')
# Cache Entry variables are stored as list in CMLIB_CACHE_ENTRY_LIST CMake cache variable.
#
# File system folder hierarchy represent cached file on host filesystem.
# Directory where the cache file will be stored is constructed
#	Directory cache entry:
#		DIRECTORY_CACHE_PATH = <CMLIB_REQUIRED_ENV_TMP_PATH>/cache/dir/[keywords...].join('/')/<filename>
#	File cache entry:
#		FILE_CACHE_PATH = <CMLIB_REQUIRED_ENV_TMP_PATH>/cache/file/[keywords...].join('/')/
#
# Cache distincts between files and directories.
#
## Cache type constraints
# If the file under PATH is directory then folowwing constraints
# for Keywords must be met:
#	Let KS is set of all already cached keywords set (keywords set which already has a cache entry)
#	and _k_ is keywords set, _k_ not in KS.
#	then for all _x_ in KS where _x_ != _k_, _k_ not subset of _x_ and
#	_x_ not subset of _k_.
# ==> Because we cannot copy directory over directory (we can mess up cache with directory entries)
#
## Cache regenerate
# If the CMakeCache.txt is deleted from CMake binary dir
# all cache entries are lost. For that situation CMLIB_CACHE implement
# mechanism called "cache regenerate" which regenerates cahce entries by
# file system cache representation.
#
# For cache regenerate Cache type constraints must be met.
#
# If the CMLIB_CACHE_HAS_FILE returns defined
# variable (specified be PATH_VAR) function CACHE_ADD use this
# file as a cache instead of file specified by PATH.
# This allow call CMLIB_CACHE_ADD where cache files
# exists but cache entry not. (CMakeCache.txt is deleted etc...).
# File path is returned in CACHE_PATH_VAR variable and
# PATH file/variable remains untouched.
#
# If the CMLIB_CACHE_HAS_FILE does not define variable
# (specified by PATH_VAR) function
# store file under PATH to the cache path
# and return cache path entry (in CACHE_PATH_VAR)
# file represented by PATH is copied to cache path.
#
#
# Cache functions:
# CMLIB_CACHE_ADD - adds cache entry
# CMLIB_CACHE_GET - gets entry for the cache or undef of the entry does not exist
# CMLIB_CACHE_DELETE - deletes cache entry with files and remaining directories
# CMLIB_CACHE_HAS_FILE - check if the file for given keyword set exists
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.16)

IF(DEFINED CMLIB_CACHE_INCLUDED)
	_CMLIB_LIBRARY_DEBUG_MESSAGE("CMLIB_CACHE already included")
	RETURN()
ENDIF()

# Flag that REQUIRED_ENV is already included
SET(CMLIB_CACHE_INCLUDED "1")

_CMLIB_LIBRARY_MANAGER(CMLIB_REQUIRED_ENV)
_CMLIB_LIBRARY_MANAGER(CMLIB_PARSE_ARGUMENTS)

SET(_CMLIB_CACHE_VAR_ENTRY_PREFIX "CMLIB_CACHE_ENTRY"
	CACHE INTERNAL
	"Cache entry var prefix"
)

SET(_CMLIB_CACHE_VAR_ENTRY_LIST_DESC "List of all cache entries"
	CACHE INTERNAL
	"Var entry cache description"
)

SET(_CMLIB_CACHE_VAR_DIRECTORY_NAME "cache"
	CACHE INTERNAL
	"Name of the directory in ehich the cache in the TMP will be located"
)

SET(CMLIB_CACHE_ENTRY_LIST ""
	CACHE STRING
	"List of all cache entries"
)



##
#
# Function Add cache entry (with given file/directory).
#
# Function cannot be called multiple times with same argument set if the
# argument set was successfully inserted into cache.
# (cannot be called if CACHE_PATH_VAR was defined in previous function call)
# If the option GET_IF_EXISTS is set to ON then
#	- if cache entry already exist and CACHE_PATH_VAR is specified
#	  store given cache entry to CACHE_PATH_VAR and return
#	- if cache entry does not exist then cache entry is created or regenerated
#	  and cache entry value is returned in CACHE_PATH_VAR if CACHE_PATH_VAR is specified.
#
# Cache copy file represented by PATH to own cache store.
#
# <function>(
#		KEYWORDS <keywords> [M]
#		[PATH <path>]
#		[DESCRIPTION <description>]    // CMake Cache var description for cache entry var
#		[CACHE_PATH_VAR <var_name>]
#		[KEYWORDS_PERMUTATION_ALLOWED <ON|OFF>]
#		[GET_IF_EXISTS <ON|OFF>]
# )
#
FUNCTION(CMLIB_CACHE_ADD)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			PATH
			CACHE_PATH_VAR
			DESCRIPTION
		MULTI_VALUE
			KEYWORDS
		OPTIONS
			KEYWORDS_PERMUTATION_ALLOWED
			GET_IF_EXISTS
		REQUIRED
			KEYWORDS
		P_ARGN ${ARGN}
	)
	_CMLIB_CACHE_KEYWORDS_CHECK(${__KEYWORDS})

	_CMLIB_CACHE_LIST_GET_ENTRY(cache_var ${__KEYWORDS})
	IF(cache_var)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("Cache already exist: ${cache_var}: ${${cache_var}}")
		IF(__GET_IF_EXISTS)
			IF(DEFINED __CACHE_PATH_VAR)
				SET(${__CACHE_PATH_VAR} "${${cache_var}}" PARENT_SCOPE)
			ENDIF()
		ELSE()
			MESSAGE(FATAL_ERROR "Cache entry found. Cannot override existing cache entry: ${cache_var}: ${${cache_var}}.")
		ENDIF()
		RETURN()
	ENDIF()

	# Check permutation first so not danglig files/defines if fail
	IF(NOT __KEYWORDS_PERMUTATION_ALLOWED)
		_CMLIB_CACHE_LIST_CHECK_DUPLICITIES(${__KEYWORDS})
	ENDIF()

	CMLIB_CACHE_HAS_FILE(
		KEYWORDS ${__KEYWORDS}
		PATH_VAR has_file_path
	)
	SET(name)
	SET(cache_path)
	IF(NOT DEFINED has_file_path)
		IF(NOT EXISTS ${__PATH})
			MESSAGE(FATAL_ERROR "Cannot cache '${_PATH}' - path does not exist!")
		ENDIF()
		GET_FILENAME_COMPONENT(name "${__PATH}" NAME)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("Cache file does not exist, name: ${name}")

		IF(IS_DIRECTORY ${__PATH})
			_CMLIB_CACHE_CONSTRUCT_CACHE_PATH(cache_dir "DIRECTORY" ${__KEYWORDS})
			_CMLIB_CACHE_LIST_CHECK_SUBSET_DIR(${__KEYWORDS})
			SET(cache_path "${cache_dir}/")
			EXECUTE_PROCESS(
				COMMAND ${CMAKE_COMMAND} -E make_directory "${cache_dir}/"
				COMMAND ${CMAKE_COMMAND} -E copy_directory "${__PATH}" "${cache_path}"
			)
		ELSE()
			_CMLIB_CACHE_CONSTRUCT_CACHE_PATH(cache_dir "FILE" ${__KEYWORDS})
			SET(cache_path "${cache_dir}/${name}")
			EXECUTE_PROCESS(
				COMMAND ${CMAKE_COMMAND} -E make_directory "${cache_dir}"
				COMMAND ${CMAKE_COMMAND} -E copy "${__PATH}" "${cache_path}"
			)
		ENDIF()
	ELSE()
		_CMLIB_LIBRARY_DEBUG_MESSAGE("Cache file found, ${has_file_path}")
		SET(cache_path "${has_file_path}")
	ENDIF()

	# Add cache entry
	SET(keyword_permutation)
	IF(__KEYWORDS_PERMUTATION_ALLOWED)
		SET(keyword_permutation KEYWORDS_PERMUTATION_ALLOWED 1)
	ENDIF()
	_CMLIB_CACHE_LIST_ADD_ENTRY(
		KEYWORDS ${__KEYWORDS}
		${keyword_permutation}
	)

	# Set cache entry var value
	_CMLIB_CACHE_CONTRUCT_CACHE_ENTRY_VAR(cache_var ${__KEYWORDS})
	SET(${cache_var} "${cache_path}"
		CACHE PATH
		"${__DESCRIPTION}"
		FORCE
	)

	IF(DEFINED __CACHE_PATH_VAR)
		SET(${__CACHE_PATH_VAR} "${${cache_var}}" PARENT_SCOPE)
	ENDIF()
ENDFUNCTION()



##
#
# Get cache entry from cache.
# If the entry is not found the CACHE_PATH_VAR is
# unset in the scope which the function was call.
#
# If the TRY_REGENERATE is specified and set to ON then
# If the cache entry is not found in the cache <function> recontructs
# cache entry as follows
#	- CMLIB_CACHE_HAS_FILE(...)
#	- If CMLIB_CACHE_HAS_FILE returns true call CMLIB_CACHE_ADD
#	  without PATH var --> regenerate cahce entry in CMake cache
#
# <function>(
#		KEYWORDS <keywords> [M]
#		CACHE_PATH_VAR <cache_path_var>
#		[TRY_REGENERATE <ON|OFF>]
# )
#
FUNCTION(CMLIB_CACHE_GET)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			CACHE_PATH_VAR
		MULTI_VALUE
			KEYWORDS
		OPTIONS
			TRY_REGENERATE
		REQUIRED
			KEYWORDS
			CACHE_PATH_VAR
		P_ARGN ${ARGN}
	)

	_CMLIB_CACHE_KEYWORDS_CHECK(${__KEYWORDS})

	_CMLIB_CACHE_LIST_GET_ENTRY(cache_var ${__KEYWORDS})
	IF((DEFINED cache_var) AND (EXISTS "${${cache_var}}"))
		SET(${__CACHE_PATH_VAR} ${${cache_var}} PARENT_SCOPE)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("Cache entry found: ${${cache_var}}")
		RETURN()
	ELSEIF(DEFINED cache_var)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("Cache entry exist but the cache target cannot be found - ${cache_var}. Cannot get cache")
	ELSEIF(__TRY_REGENERATE)
		CMLIB_CACHE_HAS_FILE(
			KEYWORDS ${__KEYWORDS}
			PATH_VAR file_exist
		)
		IF(DEFINED file_exist)
			CMLIB_CACHE_ADD(
				KEYWORDS ${__KEYWORDS}
				CACHE_PATH_VAR regenerated_cache_path
			)
			IF(DEFINED regenerated_cache_path)
				SET(${__CACHE_PATH_VAR} ${regenerated_cache_path} PARENT_SCOPE)
				RETURN()
			ENDIF()
		ENDIF()
	ENDIF()
	UNSET(${__CACHE_PATH_VAR} PARENT_SCOPE)
ENDFUNCTION()



##
#
# Delete cache entry and cache files.
# Delete cache file/direcotyr and all empty directories
# hich is part of cache path and belongs to given cache entry.
# For example:
#	We have 2 cache entry for keywords
#		(A, B, C),
#		(A, B, D)
#	Cache path for the given cache entries are
#		<prefix>/A/B/C/D/<cache_file_1>
#		<prefix>/A/B/X/Y/<cache_file_2>
#	Now we want to delete cache entry for (A, B, C, D)
#	Function will delete <cache_file_1> and the empty directory C and D
#	but not A and B (because there is another cache entry in directory B)
#
#	If we now delete (A, B, X, Y) the function will delete
#	all directories - even A and B (because there are empty)
#
# The target of this functionality is implication that if we
# delete all cache entries the cache is clean (in default state)
#
# <function>(
#		KEYWORDS <keywords> [M]
# )
#
FUNCTION(CMLIB_CACHE_DELETE)
	CMLIB_PARSE_ARGUMENTS(
		MULTI_VALUE
			KEYWORDS
		REQUIRED
			KEYWORDS
		P_ARGN ${ARGN}
	)
	_CMLIB_CACHE_KEYWORDS_CHECK(${__KEYWORDS})
	_CMLIB_CACHE_LIST_GET_ENTRY(cache_var ${__KEYWORDS})
	IF(NOT DEFINED cache_var)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("Cannot delete cache entry under keywords ${__KEYWORDS}. It does not exist")
		RETURN()
	ENDIF()

	SET(cache_entry_content "${${cache_var}}")

	SET(keywords_reverse ${__KEYWORDS})
	LIST(REVERSE keywords_reverse)

	# We can remove directory directly, read "constraints" section of doc
	IF(IS_DIRECTORY "${cache_entry_content}")
		EXECUTE_PROCESS(
			COMMAND ${CMAKE_COMMAND} -E remove_directory "${cache_entry_content}"
		)
		# We already delete last keyword, se remove it from keywords list
		LIST(REMOVE_AT keywords_reverse 0)
	ELSE()
		EXECUTE_PROCESS(
			COMMAND ${CMAKE_COMMAND} -E remove -f "${cache_entry_content}"
		)
	ENDIF()

	GET_FILENAME_COMPONENT(parent_directory "${cache_entry_content}" DIRECTORY)
	FOREACH(last_keyword ${keywords_reverse})
		FILE(GLOB parent_dir_content "${parent_directory}/*")
		LIST(LENGTH parent_dir_content parent_dir_content_size)

		STRING(REGEX MATCH ".*${last_keyword}[/]*$" last_keyword_match "${parent_directory}")
		IF(NOT last_keyword_match)
			BREAK()
		ENDIF()

		IF(parent_dir_content_size LESS_EQUAL 0)
			EXECUTE_PROCESS(
				COMMAND ${CMAKE_COMMAND} -E remove_directory "${parent_directory}"
			)
		ELSE()
			BREAK()
		ENDIF()
		GET_FILENAME_COMPONENT(parent_directory "${parent_directory}" DIRECTORY)
	ENDFOREACH()

	_CMLIB_CACHE_CONSTRUCT_CACHE_PATH(cache_dir_file FILE)
	_CMLIB_CACHE_CONSTRUCT_CACHE_PATH(cache_dir_dir DIRECTORY)
	STRING(REGEX MATCH "${cache_dir_file}/?$" cache_dir_file_match "${parent_directory}")
	STRING(REGEX MATCH "${cache_dir_dir}/?$"  cache_dir_dir_match  "${parent_directory}")

	SET(command)
	IF(cache_dir_file_match)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("cache base directory for file will be deleted")
		FILE(GLOB cache_dir_file_content "${cache_dir_file}/*")
		LIST(LENGTH cache_dir_file_content cache_dir_file_content_size)
		IF(cache_dir_file_content_size EQUAL 0)
			LIST(APPEND command COMMAND ${CMAKE_COMMAND} -E remove_directory
				"${cache_dir_file}")
		ENDIF()
	ENDIF()
	IF(cache_dir_dir_match)
		FILE(GLOB cache_dir_dir_content "${cache_dir_dir}/*")
		LIST(LENGTH cache_dir_dir_content cache_dir_dir_content_size)
		IF(cache_dir_dir_content_size EQUAL 0)
			LIST(APPEND command COMMAND ${CMAKE_COMMAND} -E remove_directory
				"${cache_dir_dir}")
		ENDIF()
		_CMLIB_LIBRARY_DEBUG_MESSAGE("cache base directory for dir will be deleted, ${command}")
	ENDIF()
	IF(command)
		EXECUTE_PROCESS(${command})
	ENDIF()

	_CMLIB_CACHE_CONSTRUCT_CACHE_PATH(base_dir BASEDIR)
	FILE(GLOB base_dir_content "${base_dir}/*")
	LIST(LENGTH base_dir_content base_dir_content_size)
	IF(base_dir_content_size EQUAL 0)
		EXECUTE_PROCESS(COMMAND ${CMAKE_COMMAND} -E remove_directory "${base_dir}")
	ENDIF()

	_CMLIB_CACHE_LIST_REMOVE_ENTRY(${__KEYWORDS})
	UNSET(${cache_var} CACHE)

ENDFUNCTION()



##
#
# Try to look at filesystem chache path
# and return cache path independently on
# cache path entry.
#
# For given keywords set construct DIRECTORY_CACHE_PATH and
# FILE_CACHE_PATH.
#
# Only DIRECTORY_CACHE_PATH or FILE_CACHE_PATH exist at same time.
# By the definition the FILE_CACHE_PATH must contain only ONE file called FILE and
# set of directories. We take the file and return the path of the FILE.
# If no file is found then undef PATH_VAR variable.
#
# By the definition DIRECTORY_CACHE_PATH cannot contain other directory cache entries.
# We just test if the DIRECTORY_CACHE_PATH for given keyword set exists.
# If exist set DIRECTORY_CACHE_PATH to PATH_VAR, if not exists undef PATH_VAR
#
# <function>(
#		KEYWORDS <keywords> [M]
#		PATH_VAR <path_var>
# )
#
FUNCTION(CMLIB_CACHE_HAS_FILE)
	CMLIB_PARSE_ARGUMENTS(
		MULTI_VALUE
			KEYWORDS
			PATH_VAR
		REQUIRED
			KEYWORDS
			PATH_VAR
		P_ARGN ${ARGN}
	)
	_CMLIB_CACHE_KEYWORDS_CHECK(${__KEYWORDS})
	_CMLIB_CACHE_CONSTRUCT_CACHE_PATH(cache_path_directories DIRECTORY ${__KEYWORDS})
	_CMLIB_CACHE_CONSTRUCT_CACHE_PATH(cache_path_files FILE ${__KEYWORDS})
	IF(EXISTS "${cache_path_files}")
		_CMLIB_CACHE_COUNT_FILES_AND_DIRECTORIES("${cache_path_files}"
			file_count directory_count file_list directory_list)
		IF(file_count EQUAL 1)
			SET(${__PATH_VAR} "${file_list}" PARENT_SCOPE)
			RETURN()
		ENDIF()
	ENDIF()
	IF(EXISTS "${cache_path_directories}")
		SET(${__PATH_VAR} "${cache_path_directories}" PARENT_SCOPE)
		RETURN()
	ENDIF()
	_CMLIB_LIBRARY_DEBUG_MESSAGE("No file count, ${cache_path_directories}\n${cache_path_files}")
	UNSET(${__PATH_VAR} PARENT_SCOPE)
ENDFUNCTION()



##########################################################################
### Helpers
##########################################################################



## HELPER
#
# Add entry to the entry list.
# If the KEYWORDS_PERMUTATION_ALLOWED is not specified then
# only one permutation of the given set of keywords can be
# added to the entry list.
# <function>(
#		KEYWORDS <keywords> [M]
#		[KEYWORDS_PERMUTATION_ALLOWED]
# )
#
FUNCTION(_CMLIB_CACHE_LIST_ADD_ENTRY)
	CMLIB_PARSE_ARGUMENTS(
		MULTI_VALUE
			KEYWORDS
		OPTIONS
			KEYWORDS_PERMUTATION_ALLOWED
		REQUIRED
			KEYWORDS
		P_ARGN ${ARGN}
	)
	SET(keywords ${__KEYWORDS})

	IF(NOT __KEYWORDS_PERMUTATION_ALLOWED)
		_CMLIB_CACHE_LIST_CHECK_DUPLICITIES(${keywords})
	ENDIF()

	_CMLIB_CACHE_CONTRUCT_CACHE_ENTRY_VAR(base_entry_name ${keywords})

	LIST(FIND CMLIB_CACHE_ENTRY_LIST "${base_entry_name}" index)
	IF(index EQUAL -1)
		SET(_tmp ${CMLIB_CACHE_ENTRY_LIST})
		LIST(APPEND _tmp ${base_entry_name})
		SET(CMLIB_CACHE_ENTRY_LIST ${_tmp} CACHE STRING "" FORCE)
	ELSE()
		_CMLIB_LIBRARY_DEBUG_MESSAGE("Entry '${base_entry_name}' already in entry list")
	ENDIF()
ENDFUNCTION()



## HELPER
#
# Get cache entry.
# If entry is not found the 'output_var' is unset
# in scope in which the function is called
# <function>(
#		<output_var>
# )
#
FUNCTION(_CMLIB_CACHE_LIST_GET_ENTRY var)
	SET(keywords ${ARGN})
	_CMLIB_CACHE_CONTRUCT_CACHE_ENTRY_VAR(base_entry_name ${keywords})
	LIST(FIND CMLIB_CACHE_ENTRY_LIST "${base_entry_name}" index)
	IF(index EQUAL -1)
		UNSET(${var} PARENT_SCOPE)
		RETURN()
	ENDIF()
	SET(${var} ${base_entry_name} PARENT_SCOPE)
ENDFUNCTION()



## HELPER
#
# Remove cache entry form the entry list.
# <function>(
#		<keywords>...
# )
#
FUNCTION(_CMLIB_CACHE_LIST_REMOVE_ENTRY)
	SET(keywords ${ARGN})

	_CMLIB_CACHE_CONTRUCT_CACHE_ENTRY_VAR(base_entry_name ${keywords})

	LIST(FIND CMLIB_CACHE_ENTRY_LIST "${base_entry_name}" index)
	IF(index EQUAL -1)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("Entry '${base_entry_name}' will not be deleted. Not found in the list.")
	ENDIF()
	SET(_tmp ${CMLIB_CACHE_ENTRY_LIST})
	LIST(REMOVE_ITEM _tmp ${base_entry_name})
	SET(CMLIB_CACHE_ENTRY_LIST ${_tmp} CACHE STRING "" FORCE)
ENDFUNCTION()



## HELPER
#
# Check if there are duplicities in the entry list.
# (two different combinations of the same keywords set exist in the list)
# If duplicities are found FATAL_ERROR occured
# <function>(
#		<keywords>...
#)
#
FUNCTION(_CMLIB_CACHE_LIST_CHECK_DUPLICITIES)
	SET(keywords ${ARGN})
	LIST(SORT keywords)
	LIST(JOIN keywords "_" keywords_entry_sorted)
	SET(count 0)
	FOREACH(entry ${CMLIB_CACHE_ENTRY_LIST})
		STRING(REGEX REPLACE "^${_CMLIB_CACHE_VAR_ENTRY_PREFIX}_" "" entry_keywords_string "${entry}")
		STRING(REPLACE "_" ";" entry_split_sorted "${entry_keywords_string}")
		LIST(SORT entry_split_sorted)
		LIST(JOIN entry_split_sorted "_" entry_sorted)
		IF("${keywords_entry_sorted}" STREQUAL "${entry_sorted}")
			MATH(EXPR count "${count} + 1")
		ENDIF()
	ENDFOREACH()
	IF(count GREATER 0)
		MESSAGE(FATAL_ERROR "Keywords combination found for ${keywords}")
	ENDIF()
ENDFUNCTION()



## Helper
#
# Check if here is no previously cached directory
#
# <function>(
# )
#
FUNCTION(_CMLIB_CACHE_LIST_CHECK_SUBSET_DIR)
	SET(keywords ${ARGN})
	LIST(JOIN keywords "_" keywords_entry_sorted)
	FOREACH(entry ${CMLIB_CACHE_ENTRY_LIST})
		STRING(REGEX REPLACE "^${_CMLIB_CACHE_VAR_ENTRY_PREFIX}_" "" entry_keywords_string "${entry}")
		STRING(REPLACE "_" ";" entry_keywords_split "${entry_keywords_string}")
		LIST(JOIN entry_keywords_split "_" entry_sorted)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("Subset variables ${keywords_entry_sorted}:${entry_sorted}")
		STRING(REGEX MATCH "^${keywords_entry_sorted}_(.*)" match_ok "${entry_sorted}")
		STRING(REGEX MATCH "^${entry_sorted}_(.*)" match_ok2 "${keywords_entry_sorted}")
		IF((match_ok OR match_ok2) AND NOT IS_DIRECTORY "${entry}")
			MESSAGE(FATAL_ERROR "Given keywords are subset of existing cahce keywords")
		ENDIF()
	ENDFOREACH()
ENDFUNCTION()



## Helper
#
# Count files and directories in given directory
# <function>(
#		<root_dir>
#		<output_file_count>
#		<output_directory_count>
# )
#
FUNCTION(_CMLIB_CACHE_COUNT_FILES_AND_DIRECTORIES root_dir
		output_file_count output_directory_count
		output_file_list output_directory_list)
	FILE(GLOB root_dir_files "${root_dir}/*")
	SET(file_list)
	SET(directory_list)
	SET(file_count 0)
	SET(directory_count 0)
	FOREACH(file_in_cache_path ${root_dir_files})
		IF(IS_DIRECTORY "${file_in_cache_path}")
			LIST(APPEND directory_list "${file_in_cache_path}")
			MATH(EXPR directory_count "${directory_count} + 1")
		ELSE()
			LIST(APPEND file_list "${file_in_cache_path}")
			MATH(EXPR file_count "${file_count} + 1")
		ENDIF()
	ENDFOREACH()
	SET(${output_file_count} ${file_count} PARENT_SCOPE)
	SET(${output_directory_count} ${directory_count} PARENT_SCOPE)
	SET(${output_file_list} ${file_list} PARENT_SCOPE)
	SET(${output_directory_list} ${directory_list} PARENT_SCOPE)
ENDFUNCTION()



## HELPER
#
# Construct cahce entry CMAke varianble under
# the cache entry is stored
# <function>(
#	<var>        // variable name to store cahce entry var name
#	<keywords>
# )
#
FUNCTION(_CMLIB_CACHE_CONTRUCT_CACHE_ENTRY_VAR var)
	SET(keywords ${ARGN})
	LIST(JOIN keywords "_" _tmp)
	SET("${var}" "${_CMLIB_CACHE_VAR_ENTRY_PREFIX}_${_tmp}" PARENT_SCOPE)
	_CMLIB_LIBRARY_DEBUG_MESSAGE("Cache var name ${_CMLIB_CACHE_VAR_ENTRY_PREFIX}_${_tmp}")
ENDFUNCTION()



## HELPER
#
# Construct portions of cache path.
# If type is DIRECTORY return cache path for directory
# If type is FILE return cache path for FILE
# If type is BASEDIR return base cache directory (in which fil and directory
# entries are stored)
#
# <function>(
#		<output_var>
#		<type> <DIRECTORY|FILE|BASEDIR>
# )
#
FUNCTION(_CMLIB_CACHE_CONSTRUCT_CACHE_PATH var type)
	SET(keywords ${ARGN})
	LIST(JOIN keywords "/" _tmp)
	IF(NOT _tmp STREQUAL "")
		SET(_tmp "/${_tmp}")
	ENDIF()
	IF("${type}" STREQUAL "DIRECTORY")
		SET("${var}" "${CMLIB_REQUIRED_ENV_TMP_PATH}/${_CMLIB_CACHE_VAR_DIRECTORY_NAME}/dir${_tmp}" PARENT_SCOPE)
	ELSEIF("${type}" STREQUAL "FILE")
		SET("${var}" "${CMLIB_REQUIRED_ENV_TMP_PATH}/${_CMLIB_CACHE_VAR_DIRECTORY_NAME}/file${_tmp}" PARENT_SCOPE)
	ELSEIF("${type}" STREQUAL "BASEDIR")
		SET("${var}" "${CMLIB_REQUIRED_ENV_TMP_PATH}/${_CMLIB_CACHE_VAR_DIRECTORY_NAME}" PARENT_SCOPE)
	ELSE()
		MESSAGE(FATAL_ERROR "Canot retrieve path for '${type}'")
	ENDIF()
	_CMLIB_LIBRARY_DEBUG_MESSAGE("Cache path ${${var}}")
ENDFUNCTION()



## HELPER
#
# Check if the keyword is valid.
# If keywords are not valid function omits FATAL_ERROR
# <function>(
#		<keywords>...
# )
#
FUNCTION(_CMLIB_CACHE_KEYWORDS_CHECK)
	FOREACH(keyword ${ARGN})
		STRING(REGEX MATCH "^[A-Z0-9]+$" keyword_regex_ok "${keyword}")
		IF(NOT keyword_regex_ok)
			MESSAGE(FATAL_ERROR "Cache keyword '${keyword}' is not valid! Invalid characters!")
		ENDIF()
		IF("${keyword}" STREQUAL "CACHE")
			MESSAGE(FATAL_ERROR "Cache Keyword 'CACHE' is not allowed.")
		ENDIF()
	ENDFOREACH()
ENDFUNCTION()

