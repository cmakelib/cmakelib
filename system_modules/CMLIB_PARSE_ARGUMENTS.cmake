
INCLUDE_GUARD(GLOBAL)



##
#
# Same behavior as CMAKE_PARSE_ARGUMENTS, but with "required" addon :)..
#
# <function>(
#		[PREFIX <prefix>]
#		[OPTIONS <options>]     M
#		[MULTI_VALUE <mva>]     M
#		[ONE_VALUE <ova>]       M
#		[REQUIRED <required>]   M
#		P_ARGN <p_argn>         M
# 	)
# If we do not specify PREFIX, the prefix is se to "__".
#
# If we do not specify argument listed in MULTI_VALUE, ONE_VALUE
# the arguments is UNDEFINED. So we can use IF(DEFINED) statement.
#
# If we do not specify argument listed in OPTIONS - arguments
# are false!
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
#
# Cleanup context after CMLIB_PARSE_ARGUMENTS call.
#
# Because the CMLIB_PARSE_ARGUMENTS is a macro and use variables it can
# mess up the context in which the function is called.
# This function just clean up all local variables from CMLIB_PARSE_ARGUMENTS
#
# Usable if CMLIB_PARSE_ARGUMENTS is called in MACRO.
#
# <function>(
# )
#
MACRO(CMLIB_PARSE_ARGUMENTS_CLEANUP)
	UNSET(options)
	UNSET(multi_value_args)
	UNSET(one_value_args)
	UNSET(_tmp)
ENDMACRO()
