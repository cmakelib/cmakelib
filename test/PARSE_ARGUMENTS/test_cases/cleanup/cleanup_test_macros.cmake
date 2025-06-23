##
# CLEANUP_TEST_MACRO - Comprehensive test for CMLIB_PARSE_ARGUMENTS_CLEANUP functionality
#
# <macro>()
#
# PURPOSE:
#   Tests that CMLIB_PARSE_ARGUMENTS_CLEANUP properly cleans up internal variables
#   while preserving parsed argument variables in macro context.
#
# TEST PROCEDURE:
#   1. BASELINE CAPTURE: Records all CMake variables before any parsing operations
#   2. ARGUMENT PARSING: Calls CMLIB_PARSE_ARGUMENTS with multiple argument types
#      (OPTIONS, ONE_VALUE, MULTI_VALUE) to create internal and parsed variables
#   3. PARSING VERIFICATION: Validates that argument parsing worked correctly
#   4. CLEANUP EXECUTION: Calls CMLIB_PARSE_ARGUMENTS_CLEANUP() to clean internal variables
#   5. VARIABLE ANALYSIS: Identifies which variables were created by parsing:
#      - Compares variable lists before/after parsing to find new variables
#      - Separates parsed variables (prefixed with "__") from internal variables
#   6. CLEANUP VALIDATION: Verifies cleanup effectiveness by:
#      - Comparing actual vs expected variable counts after cleanup
#      - Ensuring only original variables + parsed variables remain
#      - Uses simplified regex patterns to exclude test-related variables
#      - Detects unexpected variables that should have been cleaned
#      - Detects expected variables that were incorrectly removed
#   7. PARSED VARIABLE PRESERVATION: Confirms parsed variables still exist and contain correct values
#   8. REUSABILITY TEST: Performs another CMLIB_PARSE_ARGUMENTS call to demonstrate
#      that cleanup allows subsequent parsing operations without conflicts
#
# VALIDATION CRITERIA:
#   - Internal variables (options, multi_value_args, _tmp_*, etc.) are removed
#   - Parsed variables (__TEST_SINGLE, __TEST_OPTION, __TEST_MULTI) are preserved
#   - Parsed variables retain their correct values after cleanup
#   - Subsequent parsing operations execute successfully (proving reusability)
#   - No memory leaks or variable pollution occurs
#
# ERROR DETECTION:
#   - FATAL_ERROR if cleanup fails to remove internal variables
#   - FATAL_ERROR if cleanup removes variables it shouldn't
#   - Test failures if parsed variables lose their values
#   - Parse failures indicate cleanup broke subsequent operations
#
MACRO(CLEANUP_TEST_MACRO)
	GET_CMAKE_PROPERTY(vars_before_parsing VARIABLES)

	CMLIB_PARSE_ARGUMENTS(
		OPTIONS TEST_OPTION
		ONE_VALUE TEST_SINGLE
		MULTI_VALUE TEST_MULTI
		REQUIRED TEST_SINGLE
		P_ARGN
			TEST_OPTION ON
			TEST_SINGLE "cleanup_test"
			TEST_MULTI "item1" "item2"
	)

	GET_CMAKE_PROPERTY(vars_after_parsing VARIABLES)

	TEST_VAR_EQUALS_LITERAL(__TEST_SINGLE "cleanup_test")

	CMLIB_PARSE_ARGUMENTS_CLEANUP()

	GET_CMAKE_PROPERTY(vars_after_cleanup VARIABLES)

	SET(new_vars)
	FOREACH(var ${vars_after_parsing})
		LIST(FIND vars_before_parsing "${var}" found_index)
		IF(found_index EQUAL -1)
			LIST(APPEND new_vars "${var}")
		ENDIF()
	ENDFOREACH()

	SET(parsed_vars)
	FOREACH(var ${new_vars})
		IF(var MATCHES "^__")
			LIST(APPEND parsed_vars "${var}")
		ENDIF()
	ENDFOREACH()

	SET(expected_vars_after_cleanup ${vars_before_parsing} ${parsed_vars})

	LIST(LENGTH vars_after_cleanup actual_count)
	LIST(LENGTH expected_vars_after_cleanup expected_count)

	IF(NOT actual_count EQUAL expected_count)
		SET(unexpected_vars)
		FOREACH(var ${vars_after_cleanup})
			LIST(FIND expected_vars_after_cleanup "${var}" found_index)
			IF(found_index EQUAL -1)
				IF(NOT var MATCHES "^(vars_after_parsing|vars_before_parsing)$")
					LIST(APPEND unexpected_vars "${var}")
				ENDIF()
			ENDIF()
		ENDFOREACH()

		SET(missing_vars)
		FOREACH(var ${expected_vars_after_cleanup})
			LIST(FIND vars_after_cleanup "${var}" found_index)
			IF(found_index EQUAL -1)
				LIST(APPEND missing_vars "${var}")
			ENDIF()
		ENDFOREACH()

		IF(unexpected_vars)
			MESSAGE(FATAL_ERROR "CMLIB_PARSE_ARGUMENTS_CLEANUP failed to clean up internal variables: ${unexpected_vars}")
		ENDIF()
		IF(missing_vars)
			MESSAGE(FATAL_ERROR "Missing variables after cleanup: ${missing_vars}")
		ENDIF()
	ENDIF()

	TEST_VAR_EQUALS_LITERAL(__TEST_SINGLE "cleanup_test")
	TEST_VAR_TRUE(__TEST_OPTION)

	LIST(LENGTH __TEST_MULTI multi_length)
	SET(expected_multi_length 2)
	TEST_VAR_EQUAL(multi_length expected_multi_length)

	CMLIB_PARSE_ARGUMENTS(
		ONE_VALUE TEST_VALUE2
		P_ARGN
			TEST_VALUE2 "after_cleanup"
	)
	TEST_VAR_EQUALS_LITERAL(__TEST_VALUE2 "after_cleanup")
	TEST_VAR_EQUALS_LITERAL(__TEST_SINGLE "cleanup_test")
ENDMACRO()
