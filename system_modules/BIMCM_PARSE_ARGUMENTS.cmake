
IF(DEFINED BIMCM_PARSE_ARGUMENTS_INCLUDED)
	_BIMCM_LIBRARY_DEBUG_MESSAGE("BIMCM_PARSE_ARGUMENTS already included")
	RETURN()
ENDIF()

# Flag taht REQUIRED_PARSE_ARGUMENTS is alredy included
SET(BIMCM_PARSE_ARGUMENTS_INCLUDED "1")



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
MACRO(BIMCM_PARSE_ARGUMENTS)
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
