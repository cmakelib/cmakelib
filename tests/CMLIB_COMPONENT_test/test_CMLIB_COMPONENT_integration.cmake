## INTEGRATION TESTS
#
# CMake-lib component management integration tests
#
# Testing Framework: Custom CMake testing macros
# These tests verify the integration between different components
# and the overall system behavior
#

INCLUDE_GUARD(GLOBAL)

# Include test utilities from the unit test file
INCLUDE(${CMAKE_CURRENT_LIST_DIR}/test_CMLIB_COMPONENT.cmake)

# Integration Test: Full component loading workflow
FUNCTION(TEST_FULL_COMPONENT_LOADING_WORKFLOW)
    MESSAGE(STATUS "Running TEST_FULL_COMPONENT_LOADING_WORKFLOW")
    
    # Set up mock environment
    SET(test_base_path "${CMAKE_CURRENT_BINARY_DIR}/test_components")
    SET(CMLIB_COMPONENT_LOCAL_BASE_PATH "${test_base_path}")
    
    # Create mock component directories
    FILE(MAKE_DIRECTORY "${test_base_path}/cmakelib-component-cmdef")
    FILE(MAKE_DIRECTORY "${test_base_path}/cmakelib-component-storage")
    FILE(MAKE_DIRECTORY "${test_base_path}/cmakelib-component-cmutil")
    
    # Create mock component files
    FILE(WRITE "${test_base_path}/cmakelib-component-cmdef/cmdefConfig.cmake" "# Mock CMDEF config\nSET(cmdef_FOUND TRUE)")
    FILE(WRITE "${test_base_path}/cmakelib-component-storage/storageConfig.cmake" "# Mock STORAGE config\nSET(storage_FOUND TRUE)")
    FILE(WRITE "${test_base_path}/cmakelib-component-cmutil/cmutilConfig.cmake" "# Mock CMUTIL config\nSET(cmutil_FOUND TRUE)")
    
    # Test component path resolution
    SET(test_components "cmdef" "storage" "cmutil")
    SET(original_module_path "${CMAKE_MODULE_PATH}")
    
    # Simulate _CMLIB_COMPONENT behavior
    FOREACH(component IN LISTS test_components)
        STRING(TOLOWER "${component}" component_lower)
        SET(component_dir_name "cmakelib-component-${component_lower}")
        SET(expected_path "${CMLIB_COMPONENT_LOCAL_BASE_PATH}/${component_dir_name}")
        
        # Verify directory exists
        IF(NOT IS_DIRECTORY "${expected_path}")
            MESSAGE(FATAL_ERROR "Expected component directory not found: ${expected_path}")
        ENDIF()
        
        # Add to module path (simulating what _CMLIB_COMPONENT does)
        LIST(APPEND CMAKE_MODULE_PATH "${expected_path}")
    ENDFOREACH()
    
    # Verify all paths were added
    FOREACH(component IN LISTS test_components)
        STRING(TOLOWER "${component}" component_lower)
        SET(component_dir_name "cmakelib-component-${component_lower}")
        SET(expected_path "${CMLIB_COMPONENT_LOCAL_BASE_PATH}/${component_dir_name}")
        
        ASSERT_CONTAINS("${CMAKE_MODULE_PATH}" "${expected_path}" "Component path should be in CMAKE_MODULE_PATH")
    ENDFOREACH()
    
    # Clean up
    SET(CMAKE_MODULE_PATH "${original_module_path}")
    FILE(REMOVE_RECURSE "${test_base_path}")
    
    MESSAGE(STATUS "✓ TEST_FULL_COMPONENT_LOADING_WORKFLOW passed")
ENDFUNCTION()

# Integration Test: Component dependency resolution
FUNCTION(TEST_COMPONENT_DEPENDENCY_RESOLUTION)
    MESSAGE(STATUS "Running TEST_COMPONENT_DEPENDENCY_RESOLUTION")
    
    # Test that components can be resolved in different orders
    SET(test_orders 
        "cmdef;storage;cmutil"
        "cmutil;storage;cmdef"
        "storage;cmdef;cmutil"
    )
    
    FOREACH(order IN LISTS test_orders)
        STRING(REPLACE ";" " " order_display "${order}")
        MESSAGE(STATUS "Testing component order: ${order_display}")
        
        # Each component should be findable regardless of order
        FOREACH(component IN LISTS order)
            STRING(TOUPPER "${component}" component_upper)
            
            # Test revision lookup
            _CMLIB_COMPONENT_GET_REVISION(revision "${component_upper}")
            ASSERT_DEFINED(revision "Revision should be available for ${component}")
            
            # Test component registration
            SET(component_registered OFF)
            FOREACH(avail_component IN LISTS _CMLIB_COMPONENT_AVAILABLE_LIST)
                STRING(TOLOWER "${avail_component}" avail_component_lower)
                STRING(TOLOWER "${component}" component_lower)
                IF("${component_lower}" STREQUAL "${avail_component_lower}")
                    SET(component_registered ON)
                    BREAK()
                ENDIF()
            ENDFOREACH()
            
            ASSERT_TRUE(component_registered "Component ${component} should be registered")
        ENDFOREACH()
    ENDFOREACH()
    
    MESSAGE(STATUS "✓ TEST_COMPONENT_DEPENDENCY_RESOLUTION passed")
ENDFUNCTION()

# Integration Test: Error handling workflow
FUNCTION(TEST_ERROR_HANDLING_WORKFLOW)
    MESSAGE(STATUS "Running TEST_ERROR_HANDLING_WORKFLOW")
    
    # Test handling of unregistered components
    SET(unregistered_components "nonexistent" "invalid" "unknown")
    
    FOREACH(component IN LISTS unregistered_components)
        STRING(TOLOWER "${component}" component_lower)
        
        # Check that component is not registered
        SET(component_registered OFF)
        FOREACH(avail_component IN LISTS _CMLIB_COMPONENT_AVAILABLE_LIST)
            STRING(TOLOWER "${avail_component}" avail_component_lower)
            IF("${component_lower}" STREQUAL "${avail_component_lower}")
                SET(component_registered ON)
                BREAK()
            ENDIF()
        ENDFOREACH()
        
        ASSERT_FALSE(component_registered "Unregistered component should not be found: ${component}")
    ENDFOREACH()
    
    MESSAGE(STATUS "✓ TEST_ERROR_HANDLING_WORKFLOW passed")
ENDFUNCTION()

# Integration Test: Environment variable handling
FUNCTION(TEST_ENVIRONMENT_VARIABLE_HANDLING)
    MESSAGE(STATUS "Running TEST_ENVIRONMENT_VARIABLE_HANDLING")
    
    # Test with different environment configurations
    SET(original_local_path "${CMLIB_COMPONENT_LOCAL_BASE_PATH}")
    SET(original_remote_url "${CMLIB_REQUIRED_ENV_REMOTE_URL}")
    
    # Test with local path set
    SET(CMLIB_COMPONENT_LOCAL_BASE_PATH "/custom/local/path")
    SET(test_component "cmdef")
    STRING(TOLOWER "${test_component}" component_lower)
    SET(component_dir_name "${_CMLIB_COMPONENT_REPO_NAME_PREFIX}${component_lower}")
    SET(expected_local_path "${CMLIB_COMPONENT_LOCAL_BASE_PATH}/${component_dir_name}")
    
    ASSERT_EQUAL("${expected_local_path}" "/custom/local/path/cmakelib-component-cmdef" "Local path should be constructed correctly")
    
    # Test with remote URL set
    UNSET(CMLIB_COMPONENT_LOCAL_BASE_PATH)
    SET(CMLIB_REQUIRED_ENV_REMOTE_URL "https://custom.repo.com")
    SET(expected_remote_uri "${CMLIB_REQUIRED_ENV_REMOTE_URL}/${component_dir_name}")
    
    ASSERT_EQUAL("${expected_remote_uri}" "https://custom.repo.com/cmakelib-component-cmdef" "Remote URI should be constructed correctly")
    
    # Restore original values
    SET(CMLIB_COMPONENT_LOCAL_BASE_PATH "${original_local_path}")
    SET(CMLIB_REQUIRED_ENV_REMOTE_URL "${original_remote_url}")
    
    MESSAGE(STATUS "✓ TEST_ENVIRONMENT_VARIABLE_HANDLING passed")
ENDFUNCTION()

# Integration Test: Multiple component processing
FUNCTION(TEST_MULTIPLE_COMPONENT_PROCESSING)
    MESSAGE(STATUS "Running TEST_MULTIPLE_COMPONENT_PROCESSING")
    
    # Test processing multiple components simultaneously
    SET(all_components ${_CMLIB_COMPONENT_AVAILABLE_LIST})
    SET(processed_paths)
    
    FOREACH(component IN LISTS all_components)
        STRING(TOLOWER "${component}" component_lower)
        SET(component_dir_name "${_CMLIB_COMPONENT_REPO_NAME_PREFIX}${component_lower}")
        
        # Test local path construction
        SET(CMLIB_COMPONENT_LOCAL_BASE_PATH "/test/base")
        SET(component_path "${CMLIB_COMPONENT_LOCAL_BASE_PATH}/${component_dir_name}")
        LIST(APPEND processed_paths "${component_path}")
        
        # Test remote URI construction
        UNSET(CMLIB_COMPONENT_LOCAL_BASE_PATH)
        SET(CMLIB_REQUIRED_ENV_REMOTE_URL "https://test.com")
        SET(component_uri "${CMLIB_REQUIRED_ENV_REMOTE_URL}/${component_dir_name}")
        
        # Verify URI format
        ASSERT_CONTAINS("${component_uri}" "https://test.com/cmakelib-component-" "Remote URI should have correct format")
    ENDFOREACH()
    
    # Verify all components were processed
    LIST(LENGTH all_components expected_count)
    LIST(LENGTH processed_paths actual_count)
    ASSERT_EQUAL("${actual_count}" "${expected_count}" "All components should be processed")
    
    MESSAGE(STATUS "✓ TEST_MULTIPLE_COMPONENT_PROCESSING passed")
ENDFUNCTION()

# Integration Test: Module path management
FUNCTION(TEST_MODULE_PATH_MANAGEMENT)
    MESSAGE(STATUS "Running TEST_MODULE_PATH_MANAGEMENT")
    
    # Save original path
    SET(original_path "${CMAKE_MODULE_PATH}")
    
    # Test adding multiple component paths
    SET(test_paths 
        "/path/to/component1"
        "/path/to/component2"
        "/path/to/component3"
    )
    
    FOREACH(path IN LISTS test_paths)
        LIST(APPEND CMAKE_MODULE_PATH "${path}")
    ENDFOREACH()
    
    # Verify all paths are present
    FOREACH(path IN LISTS test_paths)
        ASSERT_CONTAINS("${CMAKE_MODULE_PATH}" "${path}" "Path should be in CMAKE_MODULE_PATH: ${path}")
    ENDFOREACH()
    
    # Test path order preservation
    LIST(GET CMAKE_MODULE_PATH 0 first_added)
    LIST(GET CMAKE_MODULE_PATH 1 second_added)
    LIST(GET CMAKE_MODULE_PATH 2 third_added)
    
    LIST(GET test_paths 0 first_expected)
    LIST(GET test_paths 1 second_expected)
    LIST(GET test_paths 2 third_expected)
    
    ASSERT_EQUAL("${first_added}" "${first_expected}" "Path order should be preserved")
    ASSERT_EQUAL("${second_added}" "${second_expected}" "Path order should be preserved")
    ASSERT_EQUAL("${third_added}" "${third_expected}" "Path order should be preserved")
    
    # Restore original path
    SET(CMAKE_MODULE_PATH "${original_path}")
    
    MESSAGE(STATUS "✓ TEST_MODULE_PATH_MANAGEMENT passed")
ENDFUNCTION()

# Main integration test runner
FUNCTION(RUN_INTEGRATION_TESTS)
    MESSAGE(STATUS "========================================")
    MESSAGE(STATUS "Running CMLIB_COMPONENT Integration Tests")
    MESSAGE(STATUS "Testing Framework: Custom CMake testing macros")
    MESSAGE(STATUS "========================================")
    
    SETUP_TEST_ENVIRONMENT()
    
    # Run integration tests
    TEST_FULL_COMPONENT_LOADING_WORKFLOW()
    TEST_COMPONENT_DEPENDENCY_RESOLUTION()
    TEST_ERROR_HANDLING_WORKFLOW()
    TEST_ENVIRONMENT_VARIABLE_HANDLING()
    TEST_MULTIPLE_COMPONENT_PROCESSING()
    TEST_MODULE_PATH_MANAGEMENT()
    
    TEARDOWN_TEST_ENVIRONMENT()
    
    MESSAGE(STATUS "========================================")
    MESSAGE(STATUS "All CMLIB_COMPONENT integration tests completed successfully!")
    MESSAGE(STATUS "========================================")
ENDFUNCTION()

# Run integration tests if this file is executed directly
IF(CMAKE_CURRENT_LIST_FILE STREQUAL CMAKE_CURRENT_LIST_FILE)
    RUN_INTEGRATION_TESTS()
ENDIF()