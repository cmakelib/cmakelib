
INCLUDE_GUARD(GLOBAL)



##
# CMLIB_PARSE_ARGUMENTS - Enhanced argument parser with REQUIRED validation
#
# <function>(
#   [PREFIX <prefix>]                      // Variable prefix for parsed arguments, results in "<prefix>_" var prefix
#                                          // (default: "_", results in "__" prefix)
#   [OPTIONS <option>...]                  // Boolean arguments that require ON/OFF/TRUE/FALSE values
#   [ONE_VALUE <one_value_keyword>...]     // Single-value arguments (takes first value if multiple provided)
#   [MULTI_VALUE <multi_value_keyword>...] // Multi-value arguments that accept a list of values
#   [REQUIRED <required_keyword>...]       // Arguments that must be provided (FATAL_ERROR if missing)
#   P_ARGN <argument>...                   // Argument list to parse (ARGN of the calling function)
# )
#
# BEHAVIOR:
#   - Default prefix: "__" (underscore + underscore)
#   - Custom prefix: "<prefix>_" (custom + underscore)
#   - OPTIONS default to FALSE, set to TRUE with ON/TRUE values
#   - Undefined ONE_VALUE/MULTI_VALUE arguments are not defined
#     (use IF(DEFINED) to check if argument was provided)
#   - Empty string values may result in undefined variables
#
MACRO(CMLIB_PARSE_ARGUMENTS)
	SET(options)
	SET(multi_value_args P_ARGN REQUIRED
		OPTIONS MULTI_VALUE ONE_VALUE
	)
	SET(one_value_args PREFIX)
	CMAKE_PARSE_ARGUMENTS(_tmp
		"${options}" "${one_value_args}"
		"${multi_value_args}" ${ARGN}
	)
	IF(NOT DEFINED _tmp_PREFIX)
		SET(_tmp_PREFIX "_")
	ENDIF()

	CMAKE_PARSE_ARGUMENTS(${_tmp_PREFIX}
		"" "${_tmp_ONE_VALUE};${_tmp_OPTIONS}"
		"${_tmp_MULTI_VALUE}" ${_tmp_P_ARGN}
	)

	FOREACH(req ${_tmp_REQUIRED})
		IF(NOT DEFINED ${_tmp_PREFIX}_${req})
			MESSAGE(FATAL_ERROR "Key '${req}' is not defined!")
		ENDIF()
	ENDFOREACH()

	FOREACH(opt ${_tmp_OPTIONS})
		IF(NOT ${_tmp_PREFIX}_${opt})
			SET(${_tmp_PREFIX}_${opt} FALSE)
		ELSEIF(${_tmp_PREFIX}_${opt} STREQUAL "FALSE" OR
				${_tmp_PREFIX}_${opt} STREQUAL "OFF")
			SET(${_tmp_PREFIX}_${opt} FALSE)
		ENDIF()
	ENDFOREACH()
ENDMACRO()



##
# CMLIB_PARSE_ARGUMENTS_CLEANUP - Clean up internal variables created by CMLIB_PARSE_ARGUMENTS macro
#
# <function>()
#
# Required when CMLIB_PARSE_ARGUMENTS is called within a MACRO
# Optional in FUNCTION contexts (automatic cleanup)
#
# VARIABLES CLEANED:
#   All internal variables created by CMLIB_PARSE_ARGUMENTS including:
#   options, multi_value_args, one_value_args, _tmp_*, opt, req
#
MACRO(CMLIB_PARSE_ARGUMENTS_CLEANUP)
	UNSET(options)
	UNSET(multi_value_args)
	UNSET(one_value_args)
	UNSET(_tmp)
	UNSET(_tmp_PREFIX)
	UNSET(_tmp_P_ARGN)
	UNSET(_tmp_REQUIRED)
	UNSET(_tmp_OPTIONS)
	UNSET(_tmp_ONE_VALUE)
	UNSET(_tmp_MULTI_VALUE)
	UNSET(opt)
	UNSET(req)
ENDMACRO()
