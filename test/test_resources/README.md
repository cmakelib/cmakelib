
# Test Resources

This directory contains resources used for testing file:// URI handling in CMLIB.

## Usage

To use test resources in a test case, include the `test_resources.cmake` file.

- Call the `TEST_RESOURCES_DOWNLOAD` function.
- Use `TEST_RESOURCES_DOWNLOAD_ENABLE()` and `TEST_RESOURCES_DOWNLOAD_DISABLE()` are used to to control if the download is allowed or not.
- Use TEST_RESROUCES_GET_FILE_URI() to get file:// URI for test files from downloaded repository.
- Test reosurces are downloaded from the `cmakelib-test` repository.

### Get Resource File URI

```cmake
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../test_resources/test_resources.cmake")

# Use test resources
TEST_RESROUCES_GET_FILE_URI("relative/path/to/resource" resource_uri)
MESSAGE(STATUS "Resource FILE URI: ${resource_uri}")
```