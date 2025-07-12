
# Test Resources

This directory contains resources used for testing file:// URI handling in CMLIB.

## Usage

To use test resources in a test case, include the `test_resources.cmake` file.

- Call the `TEST_RESOURCES_DOWNLOAD` function.
- Use `TEST_RESOURCES_DOWNLOAD_ENABLE()` and `TEST_RESOURCES_DOWNLOAD_DISABLE()` to control whether downloads are allowed.
- Use `TEST_RESOURCES_GET_FILE_URI()` to get file:// URIs for test files from the downloaded repository.
- Test resources are downloaded from the `cmakelib-test` repository.

## Manual Download

To download manually go to the `test_resources` directory and run

```bash
cd test_resources
cmake -P ./test_resources_download.cmake
```

### Get Resource File URI

```cmake
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/test_resources/test_resources.cmake")

# Use test resources
TEST_RESOURCES_GET_FILE_URI("relative/path/to/resource" resource_uri)
MESSAGE(STATUS "Resource FILE URI: ${resource_uri}")
```