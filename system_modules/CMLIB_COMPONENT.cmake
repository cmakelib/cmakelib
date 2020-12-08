## Main
#
#
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.16)

IF(DEFINED CMLIB_COMPONENT_INCLUDED)
	_CMLIB_LIBRARY_DEBUG_MESSAGE("CMLIB_DEPENDENCY already included")
	RETURN()
ENDIF()

# Flag that REQUIRED_COMPONENT is already included
SET(CMLIB_COMPONENT_INCLUDED "1")

SET(_CMLIB_COMPONENT_REPO_NAME_PREFIX "cmakelib-component-"
	CACHE INTERNAL
	"Filename prefix for components"
)

SET(_CMLIB_COMPONENT_AVAILABLE_LIST basedef
	CACHE INTERNAL
	"List of available components."
)





##
#
# <function> (
#		COMPONENTS <components> M
# )
#
FUNCTION(CMLIB_COMPONENT)
	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE
		MULTI_VALUE
			COMPONENTS
		REQUIRED
			COMPONENTS
		P_ARGN ${ARGN}
	)

	FOREACH(component IN LISTS __COMPONENTS)
		STRING(TOUPPER component_upper "${component}")
		STRING(TOLOWER component_lower "${component}")

		SET(component_registered OFF)
		FOREACH(avail_component IN LISTS _CMLIB_COMPONENT_AVAILABLE_LIST)
			STRING(TOLOWER avail_component_lower "${avail_component}")
			IF("${component_lower}" STREQUAL "${avail_component_lower}")
				SET(component_registered ON)
				BREAK()
			ENDIF()
		ENDFOREACH()
		IF(NOT component_registered)
			MESSAGE(FATAL_ERROR "Component '${component}' is not registered!")
		ENDIF()

		SET(component_uri ${CMLIB_REQUIRED_ENV_REMOTE_URL}/${_CMLIB_COMPONENT_REPO_NAME_PREFIX}${component})

		CMLIB_DEPENDENCY(
			KEYWORDS CMLIB COMPONENT ${component_upper}
			TYPE DIRECTORY
			URI "${storage_uri}"
			URI_TYPE GIT
			OUTPUT_PATH_VAR storage_path
		)

	ENDFOREACH()
	
ENDFUNCTION()



## Helper
#
# <function> (
# )
#
FUNCTION(_CMLIB_COMPONENT_READ_CONFIG component_name)
	GET_CMAKE_PROPERTY(variable_list VARIABLES)
	LIST(LENGTH variable_list_orig_length)

	SET(${})

ENDFUNCTION()
