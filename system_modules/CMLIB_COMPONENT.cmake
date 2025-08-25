## MAIN
#
# CMake-lib component management
#
#

INCLUDE_GUARD(GLOBAL)

SET(CMLIB_COMPONENT_LOCAL_BASE_PATH "$ENV{CMLIB_COMPONENT_LOCAL_BASE_PATH}"
	CACHE PATH
	"If set the path is used to find components. If not set components are downloaded from the remote server."
)

SET(_CMLIB_COMPONENT_REPO_NAME_PREFIX "cmakelib-component-"
	CACHE INTERNAL
	"Filename prefix for components."
)

SET(_CMLIB_COMPONENT_AVAILABLE_LIST cmdef storage cmutil cmconf
	CACHE INTERNAL
	"List of available components."
)

#
# Revisions to use for each respective component.
# When CMLIB_LOCAL_BASE_PATH is set the revisions as specified by these variables are ignored. 
#

SET(_CMLIB_COMPONENT_REVISION_VARANAME_PREFIX "CMLIB_COMPONENT_REVISION_"
	CACHE INTERNAL
	"Prefix for component revision variable name."
)

SET(CMLIB_COMPONENT_REVISION_CMDEF "v1.0.3"
	CACHE STRING
	"Revision of CMDEF component to use"
)

SET(CMLIB_COMPONENT_REVISION_STORAGE "v1.0.0"
	CACHE STRING
	"Revision of STORAGE component to use"
)

SET(CMLIB_COMPONENT_REVISION_CMUTIL "v1.1.0"
	CACHE STRING
	"Revision of CMUTIL component to use"
)

SET(CMLIB_COMPONENT_REVISION_CMCONF "v1.1.0"
	CACHE STRING
	"Revision of CMCONF component to use"
)

_CMLIB_LIBRARY_MANAGER(CMLIB_REQUIRED_ENV)
_CMLIB_LIBRARY_MANAGER(CMLIB_PARSE_ARGUMENTS)



##
#
# Download and initialize given component.
#
# Standard FIND_PACKAGE mechanism is used after the component is downloaded.
#
# If the variable CMLIB_COMPONENT_LOCAL_BASE_PATH is not set or empty components are downloaded
# from the remote repositories.
#
# If the variable CMLIB_COMPONENT_LOCAL_BASE_PATH is set the value is used
# as a directory where components are searched for and revisions specified by
# CMLIB_COMPONENT_REVISION_<component> are ignored.
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
	SET(_cmlib_find_components ${CMLIB_FIND_COMPONENTS})
	UNSET(CMLIB_FIND_COMPONENTS)
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
	SET(CMLIB_FIND_COMPONENTS ${_cmlib_find_components})
	UNSET(_cmlib_find_components)
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

		SET(component_dir_name ${_CMLIB_COMPONENT_REPO_NAME_PREFIX}${component_lower})

		SET(component_path)
		IF(CMLIB_COMPONENT_LOCAL_BASE_PATH)
			SET(component_path ${CMLIB_COMPONENT_LOCAL_BASE_PATH}/${component_dir_name})
			_CMLIB_LIBRARY_DEBUG_MESSAGE("CMLIB_COMPONENT: ${component_path}")
		ELSE()
			_CMLIB_COMPONENT_GET_REVISION(component_revision ${component_upper})
			SET(component_uri ${CMLIB_REQUIRED_ENV_REMOTE_URL}/${component_dir_name})
			_CMLIB_LIBRARY_DEBUG_MESSAGE("CMLIB_COMPONENT: ${component_uri}")
			# TODO test are needed to check if the GIT_REVISION is taken in place!
			CMLIB_DEPENDENCY(
				KEYWORDS CMLIB COMPONENT ${component_upper}
				TYPE MODULE
				URI "${component_uri}"
				URI_TYPE GIT
				GIT_REVISION ${component_revision}
				OUTPUT_PATH_VAR component_path
			)
		ENDIF()
		_CMLIB_LIBRARY_DEBUG_MESSAGE("CMLIB_COMPONENT: '${component}' path: ${component_path}")
		LIST(APPEND CMAKE_MODULE_PATH "${component_path}")
	ENDFOREACH()
	SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} PARENT_SCOPE)
ENDFUNCTION()



## Helper
#
# <function> (
#		<output_var>     // output variable where to revision will be stored
#		<component_name>
# )
#
FUNCTION(_CMLIB_COMPONENT_GET_REVISION output_var component_name)
	set(varname ${_CMLIB_COMPONENT_REVISION_VARANAME_PREFIX}${component_name})
	IF(NOT DEFINED ${varname})
		MESSAGE(FATAL_ERROR "Component REVISION variable '${varname}' is not defined!")
	ENDIF()
	SET(${output_var} ${${varname}} PARENT_SCOPE)
ENDFUNCTION()
