## Main
#
# BIMCM module which track storage repository.
#
# BIM Shared storage is storage in which global links are gathered.
# 
# List of functions
# - BIMCM_STORAGE_TEMPLATE_INSTANCE
# 
#

IF(NOT BIMCM_USE_STORAGE)
	_BIMCM_LIBRARY_DEBUG_MESSAGE("BIMSTORAGE disabled")
	RETURN()
ENDIF()

IF(DEFINED BIMCM_STORAGE_INCLUDED)
	_BIMCM_LIBRARY_DEBUG_MESSAGE("BIMCM_REQUIRED_ENV already included")
	RETURN()
ENDIF()

SET(BIMCM_STORAGE_INCLUDED 1)

_BIMCM_LIBRARY_MANAGER(BIMCM_REQUIRED_ENV)
_BIMCM_LIBRARY_MANAGER(BIMCM_DEPENDENCY)

SET(_BIMCM_STORAGE_REPOSITORY_NAME "cmake-lib-storage.git"
	CACHE INTERNAL
	"Name of the storage repository"
)



##
#
# Function which apply set of key-value sets to
# given template string.
#
# [Definitions]
#
# Under S we suggest S(ASCII). S = S(ASCII)
#
# Let the non-empty string from S is called Key.
# Let the string from S is called Pattern.
# Let the string from S is called Template.
#
# Let the KeySet is finite set of all Keys.
# Let the TemplateSet is finite set of all Templates.
# Let the PatternSet is finite set of all Patterns.
#
# Function KeyToPattern: KeySet --> PatternSet is defined as
# KeyToPattern(key) = '<' + key + '>'. (it'a bijection!)
#
# We say that Template is divisible by pattern p from PatternSet if there are
# string a,b from S: Template = a + p + b
#
# We say that Template contains Pattern if is divisible by Pattern.
#
# We say that Template is immutable against given Pattern if the Template
# is not divisible by Pattern.
#
# The base of this function is apply Pattern on given Template
# If we want to "replace" Pattern we need value which will replace pattern.
#
# Let the string from S is called Value.
# Let the ValueSet is finite set of all Values.
#
# Define function KeyToValue: KeySet --> ValueSet which for each k from KeySet
# assign one v from ValueSet.
#
# Lets define function Apply(t, k, KeyToValue): TemplateSet x KeySet --> TemplateSet
#    t in TemplateSet, k in KeySet;
#    Lets define p from PatternSet as p = KeyToPattern(k);
#    The division of 't' against 'p' must exist, t = a + p + b (where a, b from S)
#    Then x = Apply(t, k) = Apply(a, k) + KeyToValue(k) + Apply(b, k) ==> x is immutable against p = KeyToPattern(k).
#
# Example:
# t = "MyNiceBread_<keya>Jupik<keyb><keya>Supik", k = "keya", KeyToValue(k) = "TEST"
# Apply(t, k) = "MyNiceBread_TESTJupik<keyb>TESTSupik"
#
# [Function arguments]
#
# <function>(
#		<output_var>
#		<template>
#		[<key_1> <value_1> ... <key_x> <value_x>] // KeyToValue mapping
# )
#
FUNCTION(BIMCM_STORAGE_TEMPLATE_INSTANCE output_var)
	LIST(GET ARGN 0 template_name)
	IF(NOT (DEFINED ${template_name}))
		MESSAGE(FATAL_ERROR "Template var '${template_name}' is not defined in current context")
	ENDIF()

	_BIMCM_LIBRARY_DEBUG_MESSAGE("BIMCM_STORAGE_TEMPLATE: Lower arguments in template ${template_name}")

	STRING(REGEX MATCHALL "<([^>]+)>" template_arguments "${${template_name}}")
	SET(template_arguments_lower)
	FOREACH(T IN LISTS template_arguments)
		STRING(TOLOWER "${T}" T_lower)
		_BIMCM_LIBRARY_DEBUG_MESSAGE("BIMCM_STORAGE_TEMPLATE: template arguments - key: '${T}' key_lower: '${T_lower}'")
		LIST(APPEND template_arguments_lower ${T_lower})
	ENDFOREACH()

	LIST(LENGTH ARGN argn_length)
	MATH(EXPR arguments_length "${argn_length} - 1")

	MATH(EXPR is_divisible_be_two "(${arguments_length} % 2)")
	IF(NOT is_divisible_be_two EQUAL 0)
		MESSAGE(FATAL_ERROR "Invalid number of template arguments! Not all are key-value pairs")
	ENDIF()

	SET(template_expanded "${${template_name}}")
	IF(NOT arguments_length LESS 2)
		LIST(SUBLIST ARGN 1 ${arguments_length} arguments)
		MATH(EXPR arguments_list_index "${arguments_length} - 1")
		FOREACH(i RANGE 0 ${arguments_list_index} 2)
			MATH(EXPR value_index "${i} + 1")
			LIST(GET arguments ${i} key)
			LIST(GET arguments ${value_index} value)
			STRING(TOLOWER "${key}" key_lower)

			_BIMCM_LIBRARY_DEBUG_MESSAGE("BIMCM_STORAGE_TEMPLATE: key: ${key}, key_lower: ${key_lower}, value: ${value}")

			LIST(FIND template_arguments_lower "<${key_lower}>" found_index)
			IF(found_index EQUAL -1)
				MESSAGE(FATAL_ERROR "Could not find '${key}' in template '${template_name}'")
			ENDIF()

			LIST(GET template_arguments ${found_index} _arg)
			STRING(REPLACE "${_arg}" "${value}" template_expanded "${template_expanded}")
			_BIMCM_LIBRARY_DEBUG_MESSAGE("BIMCM_STORAGE_TEMPLATE: replaced value '${template_expanded}'")
		ENDFOREACH()
	ENDIF()
	SET(${output_var} ${template_expanded} PARENT_SCOPE)
ENDFUNCTION()



##
# Initialize BIMCM_STORAGE module.
#
# Track module under { BIMCM STORAGE } keywords
# and include BIMSTORAGE.cmake file.
#
# <function>(
# )
#
MACRO(BIMCM_STORAGE_INIT)
	SET(storage_uri ${BIMCM_REQUIRED_ENV_REMOTE_URL}/${_BIMCM_STORAGE_REPOSITORY_NAME})
	BIMCM_DEPENDENCY(
		KEYWORDS BIMCM BIMSTORAGE
		TYPE DIRECTORY
		URI "${storage_uri}"
		URI_TYPE GIT
		OUTPUT_PATH_VAR storage_path
	)	
	SET(module_entry "${storage_path}/BIMSTORAGE.cmake")
	IF(NOT EXISTS "${module_entry}")
		MESSAGE(FATAL_ERROR "Invalid BIMSTORAGE repository. BIMSTORAGE.cmake missing.")
	ENDIF()
	INCLUDE(${module_entry})
ENDMACRO()



##
#
#
BIMCM_STORAGE_INIT()
