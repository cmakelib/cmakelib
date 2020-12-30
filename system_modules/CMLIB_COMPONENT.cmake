## Main
#
#
#
#

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

SET(_CMLIB_COMPONENT_AVAILABLE_LIST cmdef storage util
	CACHE INTERNAL
	"List of available components."
)

_CMLIB_LIBRARY_MANAGER(CMLIB_REQUIRED_ENV)
_CMLIB_LIBRARY_MANAGER(CMLIB_PARSE_ARGUMENTS)



##
#
# Download and initialize given component.
#
# Standard FIND_PACKAGE mechanism is used after the component is downloaded.
#
# <function> (
#		COMPONENTS <components> M
# )
#
MACRO(CMLIB_COMPONENT)
	CMLIB_PARSE_ARGUMENTS(
		MULTI_VALUE
			COMPONENTS
		REQUIRED
			COMPONENTS
		P_ARGN ${ARGN}
	)
	CMLIB_PARSE_ARGUMENTS_CLEANUP()
	_CMLIB_COMPONENT(
		COMPONENTS ${__COMPONENTS}
	)
	FOREACH(component IN LISTS __COMPONENTS)
		FIND_PACKAGE(${component} QUIET)
		IF(NOT ${component}_FOUND)
			_CMLIB_LIBRARY_DEBUG_MESSAGE("CMLIB_COMPONENT: '${component}' not found trying 'CMLIB_${component}'")
			FIND_PACKAGE(CMLIB_${component} QUIET)
			IF(NOT CMLIB_${component}_FOUND)
				MESSAGE(FATAL_ERROR "Cannot find component '${component}'")
			ENDIF()
		ENDIF()
	ENDFOREACH()
	UNSET(__COMPONENTS)
ENDMACRO()



## Helper
#
# <function> (
#		COMPONENTS                <components> M
#		OUTPUT_VAR_PACKAGES_ROOTS <var_name>
# )
#
FUNCTION(_CMLIB_COMPONENT)
	CMLIB_PARSE_ARGUMENTS(
		MULTI_VALUE
			COMPONENTS
		REQUIRED
			COMPONENTS
		P_ARGN ${ARGN}
	)

	SET(component_init_files)
	FOREACH(component IN LISTS __COMPONENTS)
		STRING(TOUPPER "${component}" component_upper)
		STRING(TOLOWER "${component}" component_lower)

		SET(component_registered OFF)
		FOREACH(avail_component IN LISTS _CMLIB_COMPONENT_AVAILABLE_LIST)
			STRING(TOLOWER "${avail_component}" avail_component_lower)
			IF("${component_lower}" STREQUAL "${avail_component_lower}")
				SET(component_registered ON)
				BREAK()
			ENDIF()
		ENDFOREACH()
		IF(NOT component_registered)
			MESSAGE(FATAL_ERROR "Component '${component}' is not registered!")
		ENDIF()

		SET(component_uri ${CMLIB_REQUIRED_ENV_REMOTE_URL}/${_CMLIB_COMPONENT_REPO_NAME_PREFIX}${component_lower})
		_CMLIB_LIBRARY_DEBUG_MESSAGE("CMLIB_COMPONENT: ${component_uri}")

		CMLIB_DEPENDENCY(
			KEYWORDS CMLIB COMPONENT ${component_upper}
			TYPE MODULE
			URI "${component_uri}"
			URI_TYPE GIT
			OUTPUT_PATH_VAR component_path
		)
		LIST(APPEND CMAKE_MODULE_PATH "${component_path}")
	ENDFOREACH()
	SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} PARENT_SCOPE)
ENDFUNCTION()
