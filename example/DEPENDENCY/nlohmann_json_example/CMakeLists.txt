CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(nlohmann-json-dependency)

#
# In production this may be omitted because
# the path to the CMLIB library is stored in
# global variable. Look at the <git_root>/README
#
LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../")
FIND_PACKAGE(CMLIB REQUIRED)

SET(JSON_VERSION 3.12.0)
SET(JSON_URI "https://github.com/nlohmann/json/releases/download/v${JSON_VERSION}/json.tar.xz")

CMLIB_DEPENDENCY(
	URI "${JSON_URI}"
	TYPE ARCHIVE
	OUTPUT_PATH_VAR EXTRACTED_JSON_DIR
	KEYWORDS NLOHMANN JSON
)

# Nlohmann JSON releases only source archives which
# can be used to create real-case package or add to a project by ADD_SUBDIRECTORY.
ADD_SUBDIRECTORY(${EXTRACTED_JSON_DIR}/json)

ADD_EXECUTABLE(main main.cpp)
TARGET_LINK_LIBRARIES(main PRIVATE nlohmann_json::nlohmann_json)
