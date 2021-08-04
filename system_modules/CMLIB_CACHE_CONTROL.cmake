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

SET(CMLIB_CACHE_CONTROL_META_CONTROL_DIR "${CMLIB_REQUIRED_ENV_TMP_PATH}/keys_control"
	CACHE INTERNAL
	"Base directory for control files of cache control"
)

# Value of the KEYDELIM var is used in Cmake regex
# Please avaid using special regex characters
SET(CMLIB_CACHE_CONTROL_KEYWORDS_KEYDELIM "/"
	CACHE INTERNAL
	"Delimiter for keywords in control file. Do NOT use ';'"
)

SET(CMLIB_CACHE_CONTROL_ITEMS_DELIM ","
	CACHE INTERNAL
	"Delimiter for items in control template. Look at CMLIB_CACHE_CONTROL_TEMPLATE."
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
#
# <function>(
#		HASH      <hash>
#		FILE_HASH <file_hash>
# )
#
FUNCTION(CMLIB_CACHE_CONTROL_FILE_HASH_CHECK)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			GIT_REVISION GIT_PATH URI
			HASH
		MULTI_VALUE
			ORIGINAL_KEYWORDS
		REQUIRED
			URI GIT_REVISION GIT_PATH
			HASH
		P_ARGN ${ARGN}
	)

	_CMLIB_CACHE_CONTROL_GET_FILE_HASH_PATH(file_hash_path ${__FILE_HASH})
	_CMLIB_CACHE_CONTROL_CREATE_ALL_META_DIRS()

	SET(file_hash_hash)
	IF(NOT EXISTS "${file_hash_path}")
		FILE(WRITE "${file_hash_path}" ${__HASH})
		SET(file_hash_hash "${__HASH}")
	ELSE()
		FILE(READ "${file_hash_path}" ${file_hash_hash})
	ENDIF()

	_CMLIB_CACHE_CONTROL_GET_TEMPLATE_INSTANCE_ITEM(
		HASH       ${__HASH}
		KEY        FILE_HASH
		OUTPUT_VAR file_hash
	)
	IF(NOT DEFINED file_hash)
	ENDIF()
ENDFUNCTION()



##
#
#
# <function>(
#		HASH              <hash>
#		ORIGINAL_KEYWORDS <original_keywords>
#		URI               <uri>
#		GIT_REVISION      <git_revision>
#		GIT_PATH          <git_path>
# )
#
FUNCTION(CMLIB_CACHE_CONTROL_KEYWORDS_CHECK)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			GIT_REVISION GIT_PATH URI
			HASH
		MULTI_VALUE
			ORIGINAL_KEYWORDS
		REQUIRED
			URI GIT_REVISION GIT_PATH
			HASH
		P_ARGN ${ARGN}
	)

	SET(keywords_delim "${CMLIB_CACHE_CONTROL_KEYWORDS_KEYDELIM}")
	STRING(JOIN "${keywords_delim}" keywords_string ${__ORIGINAL_KEYWORDS})

	_CMLIB_LIBRARY_DEBUG_MESSAGE("_CMLIB_DEPENDENCY_CONTROL_FILE_CHECK hash: ${__HASH}")

	LIST(APPEND control_items
		URI          "${__URI}"
		GIT_PATH     "${__GIT_PATH}"
		GIT_REVISION "${__GIT_REVISION}"
	)
	IF(DEFINED __ORIGINAL_KEYWORDS)
		STRING(JOIN "${CMLIB_CACHE_CONTROL_KEYWORDS_KEYDELIM}" keywords_string ${__ORIGINAL_KEYWORDS})
		LIST(APPEND control_items KEYWORDS_STRING "${keywords_string}")
	ENDIF()

	_CMLIB_CACHE_CONTROL_HAS_CONTROL_FILE(HASH ${__HASH} OUTPUT_VAR has_control_file)
	IF(has_control_file)
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
		_CMLIB_CACHE_CONTROL_CONCRETIZE(HASH ${__HASH}
			ITEMS ${control_items}
		)
		RETURN()
	ENDIF()

	_CMLIB_CACHE_CONTROL_IS_SAME(HASH ${__HASH}
		OUTPUT_VAR is_same
		ITEMS ${control_items}
	)
	IF(is_same)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("_CMLIB_DEPENDENCY_CONTROL_FILE_CHECK cache control OK")
		RETURN()
	ENDIF()

	_CMLIB_CACHE_CONTROL_GET_TEMPLATE_INSTANCE_ITEM(
		HASH       ${__HASH}
		KEY        KEYWORDS_STRING
		OUTPUT_VAR cached_keywords
	)
	_CMLIB_LIBRARY_DEBUG_MESSAGE("_CMLIB_DEPENDENCY_CONTROL_FILE_CHECK cached_keywords '${cached_keywords}'")
	_CMLIB_CACHE_CONTROL_GET_TEMPLATE_INSTANCE_ITEM(
		HASH       ${__HASH}
		KEY        GIT_REVISION
		OUTPUT_VAR cached_branch_name
	)
	_CMLIB_LIBRARY_DEBUG_MESSAGE("_CMLIB_DEPENDENCY_CONTROL_FILE_CHECK cached_branch '${cached_branch_name}'")

	IF(NOT __GIT_REVISION STREQUAL cached_branch_name)
		MESSAGE(FATAL_ERROR
			"DEPENDENCY version mishmash - different versions of the same file '${cached_branch_name}' vs '${__GIT_REVISION}'")
	ENDIF()

	IF(NOT cached_keywords)
		MESSAGE(FATAL_ERROR "DEPENDENCY hash mishmash - cache created without keywords"
			" but keywords provided '${__ORIGINAL_KEYWORDS}'")
	ELSEIF(NOT DEFINED __ORIGINAL_KEYWORDS)
		MESSAGE(FATAL_ERROR "DEPENDENCY hash mishmash - cache created with keywords ${cached_keywords}"
			" but no keywords provided")
	ELSE()
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
# Check if the control file represented by ITEMS is same
# as control file represented by HASH.
#
# If control file for the given HASH exist the function reads
# the control file content, construct new one by ITEMS and compare them.
# If they are equal set OUTPUT_VAR to ON.
# If they are not equal set OUTPUT_VAR to OFF.
#
# If control file for the given HASH does not exit
# set OUTPUT_VAR to OFF. 
#
# <function>(
#		HASH       <hash>       // control hash
#		ITEMS      <items>      // key-value pairs of template replacement
#		OUTPUT_VAR <output_var>
# )
#
FUNCTION(_CMLIB_CACHE_CONTROL_IS_SAME)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			HASH OUTPUT_VAR
		MULTI_VALUE
			ITEMS
		REQUIRED
			HASH ITEMS OUTPUT_VAR
		P_ARGN ${ARGN}
	)

	_CMLIB_CACHE_CONTROL_GET_CONTROL_FILE_PATH(control_file_path ${__HASH})
	IF(NOT EXISTS "${control_file_path}")
		SET(${__OUTPUT_VAR} OFF PARENT_SCOPE)
		RETURN()
	ENDIF()

	FILE(READ "${control_file_path}" control_file_content)
	_CMLIB_CACHE_CONTROL_CONSTRUCT_CONTENT(
		HASH              ${__HASH}
		TEMPLATE_INSTANCE "${CMLIB_CACHE_CONTROL_TEMPLATE}"
		ITEMS             ${__ITEMS}
		OUTPUT_VAR        constructed_content
	)
	IF(control_file_content STREQUAL constructed_content)
		SET(${__OUTPUT_VAR} ON PARENT_SCOPE)
	ELSE()
		_CMLIB_LIBRARY_DEBUG_MESSAGE("_CMLIB_CACHE_CONTROL_IS_SAME '${control_file_content}' is not same as '${constructed_content}'")
		SET(${__OUTPUT_VAR} OFF PARENT_SCOPE)
	ENDIF()
ENDFUNCTION()



## Helper
# Concretize given control file.
# It generates content by _CMLIB_CACHE_CONTROL_CONSTRUCT_CONTENT
# and write it to the control file.
# If the control file does not exist it creates one and as template instance
# the CMLIB_CACHE_CONTROL_TEMPLATE is used.
# If the file exist it uses control file content as a template instance.
#
# If OUTPUT_CONTENT_VAR is specified no control file is created
# instead the OUTPUT_CONTENT_VAR variable is filled up with
# the control file content.
#
# If OUTPUT_CONTENT_VAR is not specified the control file is concretized
# or created if does not exist.
#
# <function>(
#		HASH                <hash>
#		ITEMS               <items>       // key-value pairs of template replacement
#		[OUTPUT_CONTENT_VAR <output_var>] 
# )
#
FUNCTION(_CMLIB_CACHE_CONTROL_CONCRETIZE)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			HASH OUTPUT_CONTENT_VAR
		MULTI_VALUE
			ITEMS
		REQUIRED
			HASH ITEMS
		P_ARGN ${ARGN}
	)
	
	_CMLIB_CACHE_CONTROL_GET_CONTROL_FILE_PATH(control_file_path ${__HASH})
	SET(control_file_content)
	IF(EXISTS "${control_file_path}")
		FILE(READ "${control_file_path}" control_file_content)
	ELSE()
		SET(control_file_content ${CMLIB_CACHE_CONTROL_TEMPLATE})
	ENDIF()
	_CMLIB_LIBRARY_DEBUG_MESSAGE("_CMLIB_CACHE_CONTROL_CONCRETIZE control file content: '${control_file_content}'")

	_CMLIB_CACHE_CONTROL_CONSTRUCT_CONTENT(
		HASH              ${__HASH}
		TEMPLATE_INSTANCE "${control_file_content}"
		ITEMS             ${__ITEMS}
		OUTPUT_VAR        expanded
	)

	IF(DEFINED __OUTPUT_CONTENT_VAR)
		SET(${__OUTPUT_CONTENT_VAR} ${expanded} PARENT_SCOPE)
	ELSE()
		_CMLIB_CACHE_CONTROL_CREATE_ALL_META_DIRS()
		FILE(WRITE "${control_file_path}" "${expanded}")
	ENDIF()

ENDFUNCTION()



## Helper
# Check if the control file for given HASH exist
#
# OUTPUT_VAR is name of the variable where the result will be stored.
# returned values: ON - exist, OFF does not exist
#
# <function>(
#		HASH       <hash>       // control hash
#		OUTPUT_VAR <output_var>
# )
#
FUNCTION(_CMLIB_CACHE_CONTROL_HAS_CONTROL_FILE)
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
	SET(${__OUTPUT_VAR} OFF PARENT_SCOPE)
ENDFUNCTION()



## Helper
# Construct content of the control file.
#
# TEMPLATE_INSTANCE is an instance of the CMLIB_CACHE_CONTROL_TEMPLATE
# or template itself (because template is a template instance...)
#
# <function>(
#		HASH              <hash>              // control hash
#		TEMPLATE_INSTANCE <template_instance> // instance of CMLIB_CACHE_CONTROL_TEMPLATE
#		ITEMS             <items>             // key-value pairs of template replacement
#		OUTPUT_VAR        <output_var>        // 
# )
#
FUNCTION(_CMLIB_CACHE_CONTROL_CONSTRUCT_CONTENT)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
			TEMPLATE_INSTANCE
			HASH OUTPUT_VAR
		MULTI_VALUE
			ITEMS
		REQUIRED
			TEMPLATE_INSTANCE
			HASH ITEMS
		P_ARGN ${ARGN}
	)

	_CMLIB_LIBRARY_DEBUG_MESSAGE("_CMLIB_CACHE_CONTROL_CONSTRUCT_CONTENT tmeplate instance: ${__TEMPLATE_INSTANCE}")
	LIST(LENGTH __ITEMS items_length)	
	MATH(EXPR is_divisible_be_two "(${items_length} + 1) % 2")
	IF(NOT is_divisible_be_two)	
		MESSAGE(FATAL_ERROR "Invalid number of items! Not all are key-value pairs!")
	ENDIF()
	

	MATH(EXPR items_length_last_index "${items_length} - 1")
	FOREACH(key_index RANGE 0 ${items_length_last_index} 2)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("_CMLIB_CACHE_CONTROL_CONSTRUCT_CONTENT key_index: ${key_index}")
		MATH(EXPR value_index "${key_index} + 1")
		LIST(GET __ITEMS ${value_index} value)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("_CMLIB_CACHE_CONTROL_CONSTRUCT_CONTENT value for check: ${value}")
		STRING(REGEX MATCH "^[^;]*$" value_matched "${value}")
		IF(NOT value_matched)
			LIST(GET __ITEMS ${key_index} key)
			MESSAGE(FATAL_ERROR "Value '${value}' of key '${key}' contains forbidden char ','")
		ENDIF()
	ENDFOREACH()

	CMLIB_TEMPLATE_EXPAND(expanded __TEMPLATE_INSTANCE ${__ITEMS})
	SET("${__OUTPUT_VAR}" ${expanded} PARENT_SCOPE)

ENDFUNCTION()



## Helper
# Creates all needed meda directories
#
# <function>(
# )
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
FUNCTION(_CMLIB_CACHE_CONTROL_GET_TEMPLATE_INSTANCE_ITEM)
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
	IF("<${__KEY}>" STREQUAL value)
		_CMLIB_LIBRARY_DEBUG_MESSAGE("_CMLIB_CACHE_CONTROL_GET_TEMPLATE_INSTANCE_ITEM value '${value}' marked as empty")
		UNSET("${__OUTPUT_VAR}" PARENT_SCOPE)
	ELSE()
		STRING(REPLACE "${CMLIB_CACHE_CONTROL_KEYWORDS_KEYDELIM}" ";" value "${value}")
		SET("${__OUTPUT_VAR}" "${value}" PARENT_SCOPE)
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
# Returns file hash control file path for given file hash
#
# <function>(
#		<output_var>
#		<file_hash>
# )
#
MACRO(_CMLIB_CACHE_CONTROL_GET_FILE_HASH_PATH output_var file_hash)
	SET(${output_var} "${CMLIB_CACHE_CONTROL_META_CONTROL_DIR}/${file_hash}")
ENDMACRO()
