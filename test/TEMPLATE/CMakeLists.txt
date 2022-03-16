##
#
# Test if the TEMPLATE functionality works as expected
#


IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
	CMAKE_MINIMUM_REQUIRED(VERSION 3.16)
	PROJECT(CMLIB_STORAGE_TEST)
ENDIF()

GET_CMAKE_PROPERTY(orig_variable_names VARIABLES)
LIST(SORT orig_variable_names)
LIST(LENGTH orig_variable_names orig_variable_names_size)

LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../")
FIND_PACKAGE(CMLIB COMPONENTS STORAGE)

#FIND_PACKAGE(CMLIB_STORAGE)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../TEST.cmake")

SET(CMLIB_TEST_TEMPLATE "TestTemplateString<Aaa>Jupik<BAA><B>.txt")

CMLIB_STORAGE_TEMPLATE_INSTANCE(
	output_var
	CMLIB_TEST_TEMPLATE
	AaA OKA
	BAA OKb
	B s
)
IF(NOT "${output_var}" STREQUAL "TestTemplateStringOKAJupikOKbs.txt")
	MESSAGE(FATAL_ERROR "Not equal A")
ENDIF()

CMLIB_STORAGE_TEMPLATE_INSTANCE(
	output_var_uncomplete
	CMLIB_TEST_TEMPLATE
	AaA OKA
	BAA OKb
)
IF(NOT "${output_var_uncomplete}" STREQUAL "TestTemplateStringOKAJupikOKb<B>.txt")
	MESSAGE(FATAL_ERROR "Not equal B")
ENDIF()

SET(output_var)
CMLIB_STORAGE_TEMPLATE_INSTANCE(
	output_var
	output_var_uncomplete
	B works!
)
IF(NOT "${output_var}" STREQUAL "TestTemplateStringOKAJupikOKbworks!.txt")
	MESSAGE(FATAL_ERROR "Not equal C")
ENDIF()
