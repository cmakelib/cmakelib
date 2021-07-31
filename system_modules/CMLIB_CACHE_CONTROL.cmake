## MAIN
#
# CACHE CONTROL which ensures that the cache is consistent.
#

INCLUDE_GUARD(GLOBAL)

_CMLIB_LIBRARY_MANAGER(CMLIB_REQUIRED_ENV)
_CMLIB_LIBRARY_MANAGER(CMLIB_TEMPLATE)
_CMLIB_LIBRARY_MANAGER(CMLIB_CACHE)

SET(CMLIB_CACHE_CONTROL_META_BASE_DIR "${CMLIB_REQUIRED_ENV_TMP_PATH}/cache_control"
	CACHE INTERNAL
	"Bas drectory for meta information for cache control"
)

SET(CMLIB_CACHE_CONTROL_META_CONTROL_DIR "${CMLIB_CACHE_CONTROL_META_BASE_DIR}/keys_control"
	CACHE INTERNAL
	"Base directory for control files of cache control"
)

# Value of the KEYDELIM var is used in Cmake regex
# Please avaid using special regex characters
SET(CMLIB_CACHE_CONTROL_KEYWORDS_KEYDELIM "|"
	CACHE INTERNAL
	"Delimiter for keywords in control file"
)

SET(CMLIB_CACHE_CONTROL_ITEMS_DELIM ","
	CACHE INTERNAL
	""
)

SET(d ${CMLIB_CACHE_CONTROL_ITEMS_DELIM})
SET(CMLIB_CACHE_CONTROL_TEMPLATE
	"<KEYWORDS_STRING>${d}<URI>${d}<GIT_PATH>${d}<GIT_REVISION>${d}<FILE_HASH>"
	CACHE INTERNAL
	"Template for cache control file.AS delimiter the '${d}' must be used"
)
UNSET(d)



##
#
# <function>(
# )
#
FUNCTION(CMLIB_CACHE_CONTROL_FILE_HASH_CHECK)
ENDFUNCTION()



##
#
# Check if HASH and ORIGINAL_KEYWORDS are in sync.
# Multiple invocation of this funct with same HASH must have
# same ORIGINAL_KEYWORDS or error occurred.
#
# <function>(
#		HASH              <hash>
#		ORIGINAL_KEYWORDS <original_keywords>
# )
#
FUNCTION(CMLIB_CACHE_CONTROL_KEYWORDS_CHECK)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			GIT_REVISION GIT_PATH URI
		MULTI_VALUE
			ORIGINAL_KEYWORDS
		REQUIRED
			URI
		P_ARGN ${ARGN}
	)

	SET(keywords_delim "${CMLIB_CACHE_CONTROL_KEYWORDS_KEYDELIM}")

	CMLIB_CACHE_CONTROL_COMPUTE_HASH(
		URI             "${__URI}"
		GIT_PATH        "${__GIT_PATH}"
		OUTPUT_HASH_VAR hash
	)

	_CMLIB_CACHE_CONTROL_IS_RAW(HASH ${hash} OUTPUT_VAR is_raw)
	IF(is_raw)
		STRING(JOIN "${keywords_delim}" keywords_string ${__ORIGINAL_KEYWORDS})
		_CMLIB_LIBRARY_DEBUG_MESSAGE("_CMLIB_DEPENDENCY_CONTROL_FILE_CHECK Cache control file create")
		IF(DEFINED __ORIGINAL_KEYWORDS)
			CMLIB_CACHE_HAS_FILE(
				KEYWORDS ${__ORIGINAL_KEYWORDS}
				PATH_VAR cache_path
			)
			IF(cache_path)
				STRING(JOIN "${keywords_delim}" original_keywords_string "${__ORIGINAL_KEYWORDS}")
				MESSAGE(FATAL_ERROR "The cache under keywords '${original_keywords_string}' already exist for different remote")
			ENDIF()
		ENDIF()
		STRING(JOIN "${keywords_delim}" keywords_string ${__ORIGINAL_KEYWORDS})
		_CMLIB_CACHE_CONTROL_CONCRETIZE(
			HASH ${hash}
			ITEMS
				KEYWORDS_STRING "${keywords_string}"
				URI             "${__URI}"
				GIT_PATH        "${__GIT_PATH}"
				GIT_REVISION    "${__GIT_REVISION}"
		)
		RETURN()
	ENDIF()
	_CMLIB_CACHE_CONTROL_GET_TEMPLATE_INSTANCE_ITEMS(
		HASH ${hash}
		KEY KEYWORDS_STRING
		OUTPUT_VAR cached_keywords
	)
	_CMLIB_LIBRARY_DEBUG_MESSAGE("_CMLIB_DEPENDENCY_CONTROL_FILE_CHECK cached_keywords '${cached_keywords}'")
	_CMLIB_CACHE_CONTROL_GET_TEMPLATE_INSTANCE_ITEMS(
		HASH ${hash}
		KEY GIT_REVISION
		OUTPUT_VAR cached_branch_name
	)

	IF(NOT cached_keywords)
		MESSAGE(FATAL_ERROR "DEPENDENCY hash mishmash - cache created without keywords"
			" but keywords provided '${__ORIGINAL_KEYWORDS}'")
	ELSEIF(NOT DEFINED __ORIGINAL_KEYWORDS)
		MESSAGE(FATAL_ERROR "DEPENDENCY hash mishmash - cache created with keywords ${cached_keywords}"
			" but no keywords provided")
	ELSEIF(NOT __GIT_REVISION STREQUAL cached_branch_name)
		MESSAGE(FATAL_ERROR
			"DEPENDENCY version mishmash - different versions of the same file '${cached_branch_name}' vs '${__GIT_REVISION}'")
	ELSEIF(NOT "${ORIGINAL_KEYWORDS}" STREQUAL "${cached_keywords}")
		MESSAGE(FATAL_ERROR
			"DEPENDENCY hash mishmash - cached keywords '${cached_keywords}'"
			" are not same as required keywords '${__ORIGINAL_KEYWORDS}'")
	ENDIF()
ENDFUNCTION()



## Helper
#
# Compute hash from string
#	"${URI}|${GIT_PATH}"
# The hash uniquely identifies resource managed by
# CMLIB_DEPENDENCY function.
#
# <function>(
#		URI          <uri>
#		[GIT_PATH     <git_path>]
# )
#
FUNCTION(CMLIB_CACHE_CONTROL_COMPUTE_HASH)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			URI GIT_PATH
			OUTPUT_HASH_VAR
		REQUIRED
			URI OUTPUT_HASH_VAR
		P_ARGN ${ARGN}
	)

	SET(keywords_delim "${CMLIB_CACHE_CONTROL_KEYWORDS_KEYDELIM}")
	SET(cache_string   "${__URI}${keywords_delim}${__GIT_PATH}")
	STRING(SHA3_512 hash "${cache_string}")

	SET(regex_repeat "")
	FOREACH(I RANGE 5)
		SET(regex_repeat "${regex_repeat}[0-9A-Za-z]")
	ENDFOREACH()
	STRING(REGEX REPLACE "${regex_repeat}([0-9A-Za-z])" "\\1" each_e ${hash})

	STRING(TOUPPER "${each_e}" hash_upper)
	SET(${__OUTPUT_HASH_VAR} "${hash_upper}" PARENT_SCOPE)
ENDFUNCTION()








## Helper
# Concretize given control file.
# If the control file does not exist it creats one and
# write partly/fully concretized 
#
# <function>(
#		HASH <hash>
#		[ITEMS <items>] // key-value pairs of template replacement
# )
#
FUNCTION(_CMLIB_CACHE_CONTROL_CONCRETIZE)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			HASH
		MULTI_VALUE
			ITEMS
		REQUIRED
			HASH ITEMS
		P_ARGN ${ARGN}
	)

	LIST(LENGTH __ITEMS items_length)	
	MATH(EXPR is_divisible_be_two "(${items_length} + 1) % 2")
	IF(NOT is_divisible_be_two)	
		MESSAGE(FATAL_ERROR "Invalid number of items! Not all are key-value pairs!")
	ENDIF()
	
	_CMLIB_CACHE_CONTROL_GET_CONTROL_FILE_PATH(control_file_path ${__HASH})
	SET(control_file_content)
	IF(EXISTS "${control_file_path}")
		FILE(READ "${control_file_path}" control_file_content)
	ELSE()
		SET(control_file_content ${CMLIB_CACHE_CONTROL_TEMPLATE})
	ENDIF()
	_CMLIB_LIBRARY_DEBUG_MESSAGE("_CMLIB_CACHE_CONTROL_CONCRETIZE control file content: '${control_file_content}'")

	MATH(EXPR items_length_last_index "${items_length} - 1")
	FOREACH(key_index RANGE 0 ${items_length_last_index} 2)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("_CMLIB_CACHE_CONTROL_CONCRETIZE key_index: ${key_index}")
		MATH(EXPR value_index "${key_index} + 1")
		LIST(GET __ITEMS ${value_index} value)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("_CMLIB_CACHE_CONTROL_CONCRETIZE value for check: ${value}")
		STRING(REGEX MATCH "^[^;]*$" value_matched "${value}")
		IF(NOT value_matched)
			LIST(GET __ITEMS ${key_index} key)
			MESSAGE(FATAL_ERROR "Value '${value}' of key '${key}' contains forbidden char ','")
		ENDIF()
	ENDFOREACH()

	CMLIB_TEMPLATE_EXPAND(expanded control_file_content ${__ITEMS})

	_CMLIB_CACHE_CONTROL_CREATE_ALL_META_DIRS()
	FILE(WRITE "${control_file_path}" "${expanded}")

ENDFUNCTION()



## Helper
# The cache control for given HASH is raw if and only if
# there is no cache control file or the file content of the control file is
# the same as the control file template.
#
# <function>(
#		HASH       <hash>
#		OUTPUT_VAR <output_var>
# )
#
FUNCTION(_CMLIB_CACHE_CONTROL_IS_RAW)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			HASH OUTPUT_VAR
		REQUIRED
			HASH OUTPUT_VAR
		P_ARGN ${ARGN}
	)

	_CMLIB_CACHE_CONTROL_GET_CONTROL_FILE_PATH(control_file_path ${__HASH})
	IF(NOT EXISTS "${control_file_path}")
		SET(${__OUTPUT_VAR} ON PARENT_SCOPE)
		RETURN()
	ENDIF()

	FILE(READ "${control_file_path}" control_file_content)
	IF(CMLIB_CACHE_CONTROL_TEMPLATE STREQUAL control_file_path)
		SET(${__OUTPUT_VAR} ON PARENT_SCOPE)
		RETURN()
	ENDIF()

	SET(${__OUTPUT_VAR} OFF PARENT_SCOPE)
ENDFUNCTION()



## Helper
# Creates all needed meda directories
#
# <function>()
#
FUNCTION(_CMLIB_CACHE_CONTROL_CREATE_ALL_META_DIRS)
	IF(NOT EXISTS "${CMLIB_CACHE_CONTROL_META_BASE_DIR}")
		FILE(MAKE_DIRECTORY "${CMLIB_CACHE_CONTROL_META_BASE_DIR}")
	ENDIF()
	IF(NOT EXISTS "${CMLIB_CACHE_CONTROL_META_CONTROL_DIR}")
		FILE(MAKE_DIRECTORY "${CMLIB_CACHE_CONTROL_META_CONTROL_DIR}")
	ENDIF()
ENDFUNCTION()



## Helper
# Returns control file path for given hash
#
# <function>(
#		<output_var>
#		<hash>
# )
#
MACRO(_CMLIB_CACHE_CONTROL_GET_CONTROL_FILE_PATH output_var hash)
	SET(${output_var} "${CMLIB_CACHE_CONTROL_META_BASE_DIR}/${hash}")
ENDMACRO()




## Helper
# It gets value stored under given template key.
# It reads a control file represented by HASH and extracts
# value for give template key.
#
# <function>(
#		HASH       <hash>         // control hash
#		ITEM_KEY   <key>          // Key which will be extracted
#		OUTPUT_VAR <output_var>   // Name of the var. where the value
#                                 // for given key will be stored
# )
#
FUNCTION(_CMLIB_CACHE_CONTROL_GET_TEMPLATE_INSTANCE_ITEMS)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			HASH OUTPUT_VAR
		MULTI_VALUE
			KEY
		REQUIRED
			HASH KEY OUTPUT_VAR
		P_ARGN ${ARGN}
	)

	_CMLIB_CACHE_CONTROL_GET_CONTROL_FILE_PATH(control_file_path ${__HASH})
	IF(NOT EXISTS "${control_file_path}")
		MESSAGE(FATAL_ERROR "Control file path does not exist! You cannot obtain")
	ENDIF()
	FILE(READ "${control_file_path}" control_file_content)

	STRING(REGEX REPLACE "<|>" "" stripped_template "${CMLIB_CACHE_CONTROL_TEMPLATE}")
	STRING(REGEX REPLACE "${CMLIB_CACHE_CONTROL_ITEMS_DELIM}" ";" template_arguments_list "${stripped_template}")
	STRING(REGEX REPLACE "${CMLIB_CACHE_CONTROL_ITEMS_DELIM}" ";" template_instance_list "${control_file_content}")

	LIST(LENGTH template_arguments_list arguments_length)
	LIST(LENGTH template_instance_list instance_length)
	IF(NOT arguments_length EQUAL instance_length)
		MESSAGE(FATAL_ERROR
			"instance template '${control_file_content}' is not in sync with template '${CMLIB_CACHE_CONTROL_TEMPLATE}'")
	ENDIF()

	LIST(FIND template_arguments_list "${__KEY}" index)
	IF(index EQUAL -1)
		MESSAGE(FATAL_ERROR "key '${__KEY}' is not a part of template '${CMLIB_CACHE_CONTROL_TEMPLATE}'")
	ENDIF()
	LIST(GET template_instance_list ${index} value)
	STRING(REPLACE "${CMLIB_CACHE_CONTROL_KEYWORDS_KEYDELIM}" ";" value_rep "${value}")
	SET("${__OUTPUT_VAR}" "${value_rep}" PARENT_SCOPE)
ENDFUNCTION()
