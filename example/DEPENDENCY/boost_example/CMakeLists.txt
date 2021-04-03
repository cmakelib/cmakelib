CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(boost-dependency)

#
# In production this may be omitted because
# the path to the CMLIB library is stored in
# global variable. Look at the <git_root>/README
#
LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../")
FIND_PACKAGE(CMLIB)

##
#
# Generates URI under which the Boost is stored
#
# <function>(
#		<boost_version>
#		<boost_uri_out>
# )
#
FUNCTION(GET_BOOST_URI version output_var)
	cmake_host_system_information(RESULT os_name QUERY OS_NAME)
	SET(system_name)
	IF("${os_name}" STREQUAL "Linux")
		FIND_PROGRAM(lsb_release lsb_release REQUIRED)
		EXECUTE_PROCESS(COMMAND "${lsb_release}" -cs
			OUTPUT_VARIABLE _os_codename
			OUTPUT_STRIP_TRAILING_WHITESPACE
		)
		EXECUTE_PROCESS(COMMAND "${lsb_release}" -is
			OUTPUT_VARIABLE _os_id
			OUTPUT_STRIP_TRAILING_WHITESPACE
		)
		STRING(TOLOWER "${_os_codename}" os_codename)
		STRING(TOLOWER "${_os_id}" os_id)
		SET(system_name "${os_id}_${os_codename}")
	ELSEIF("${os_name}" STREQUAL "macOS")
		EXECUTE_PROCESS(COMMAND "/usr/libexec/PlistBuddy"
				-c "Print:ProductVersion"
				/System/Library/CoreServices/SystemVersion.plist
			OUTPUT_VARIABLE _macos_version
			OUTPUT_STRIP_TRAILING_WHITESPACE
		)
		STRING(REGEX REPLACE "^([0-9]+\\.[0-9]+)\\.[0-9]+$" "\\1" macos_version "${_macos_version}")
		STRING(REPLACE "." "_" macos_version_with_underscore "${macos_version}")
		SET(system_name "macos_${macos_version_with_underscore}")
	ELSE()
		MESSAGE(FATAL_ERROR "Only Linux and Mac OS is are supported!")
	ENDIF()
	STRING(REPLACE "." "_" version_with_underscore "${version}")
	SET(uri "https://github.com/koudis/boost-build/releases/download/${version_with_underscore}/boost-${version_with_underscore}-${system_name}-PIC.tar.bz2")
	SET(${output_var} "${uri}" PARENT_SCOPE)
ENDFUNCTION()

##
#
# Download Boost by CMake-lib DEPENDENCY function
#
# <function>(
#	boost_version
#	boost_root
# )
#
FUNCTION(DOWNLOAD_BOOST version output_var)
	GET_BOOST_URI(${version} boost_uri)
	MESSAGE(STATUS "URI: ${boost_uri}")
	MESSAGE(STATUS "Downloading Boost ${version}")
	CMLIB_DEPENDENCY(
		URI "${boost_uri}"
		TYPE ARCHIVE
		OUTPUT_PATH_VAR _path
	)
	MESSAGE(STATUS "Boost download OK")
	SET(${output_var} "${_path}" PARENT_SCOPE)
ENDFUNCTION()



SET(BOOST_VERSION 1.72.0)

DOWNLOAD_BOOST(${BOOST_VERSION} BOOST_ROOT)

SET(Boost_USE_STATIC_LIBS ON
	CACHE BOOL
	"Link boost as static"
)

SET(Boost_NO_SYSTEM_PATHS ON
	CACHE BOOL
	"Link boost as static"
)

FIND_PACKAGE(Boost ${BOOST_VERSION}
	COMPONENTS
		log_setup log
	REQUIRED
)

ADD_EXECUTABLE(main main.cpp)
TARGET_LINK_LIBRARIES(main PUBLIC 
	Boost::headers
	Boost::log_setup Boost::log
	Boost::disable_autolinking)
