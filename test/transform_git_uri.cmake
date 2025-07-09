## 
#
# Functions are duplicated from CMURIL component to not need CMUTI to test CMLIB.
# CMLIB is amain repository. Do not relay on other components to test itself.
#



## Transform Git URI Function
#
# Converts HTTP(S) Git URIs to SSH format
#
# HTTP(S) to SSH format:
# https://github.com/user/repo.git --> git@github.com:user/repo.git
# https://gitlab.com/user/repo.git --> git@gitlab.com:user/repo.git
# git@gitlab.com:user/repo.git     --> git@gitlab.com:user/repo.git
#
# <function>(
#     URI <uri>
#     OUTPUT_VAR <output_variable>
# )
#
FUNCTION(TRANSFORM_GIT_URI)
    CMLIB_PARSE_ARGUMENTS(
        ONE_VALUE
            URI
            OUTPUT_VAR
        REQUIRED
            URI
            OUTPUT_VAR
        P_ARGN ${ARGN}
    )

    SET(uri "${__URI}")

    STRING(REGEX MATCH "^git@.*" git_ssh_uri "${uri}")
    IF(git_ssh_uri)
        SET(${__OUTPUT_VAR} "${uri}" PARENT_SCOPE)
        RETURN()
    ENDIF()

    STRING(REGEX MATCH "^https?://" git_http_uri "${uri}")
    IF(NOT git_http_uri)
        MESSAGE(FATAL_ERROR "URI '${uri}' is not a valid HTTP(S) or git@ Git URI")
    ENDIF()

    STRING(REGEX MATCH "^https?://([^/]+)/(.+)$" http_match "${uri}")
    IF(NOT http_match)
        MESSAGE(FATAL_ERROR "URI '${uri}' is not a valid HTTP(S) or git@ Git URI")
    ENDIF()

    STRING(REGEX REPLACE "^https?://([^/]+)/(.+)$" "\\1" hostname "${uri}")
    STRING(REGEX REPLACE "^https?://([^/]+)/(.+)$" "\\2" path "${uri}")

    SET(ssh_uri "git@${hostname}:${path}")
    SET(${__OUTPUT_VAR} "${ssh_uri}" PARENT_SCOPE)
ENDFUNCTION()


## Transform Git URI to HTTPS Function
#
# Converts SSH Git URIs to HTTPS format
#
# SSH to HTTPS format:
# git@github.com:user/repo.git     --> https://github.com/user/repo.git
# git@gitlab.com:user/repo.git     --> https://gitlab.com/user/repo.git
# https://github.com/user/repo.git --> https://github.com/user/repo.git
#
# <function>(
#     URI <uri>
#     OUTPUT_VAR <output_variable>
# )
#
FUNCTION(TRANSFORM_GIT_URI_TO_HTTPS)
    CMLIB_PARSE_ARGUMENTS(
        ONE_VALUE
            URI
            OUTPUT_VAR
        REQUIRED
            URI
            OUTPUT_VAR
        P_ARGN ${ARGN}
    )

    SET(uri "${__URI}")

    STRING(REGEX MATCH "^https?://" git_http_uri "${uri}")
    IF(git_http_uri)
        SET(${__OUTPUT_VAR} "${uri}" PARENT_SCOPE)
        RETURN()
    ENDIF()

    STRING(REGEX MATCH "^git@.*" git_ssh_uri "${uri}")
    IF(NOT git_ssh_uri)
        MESSAGE(FATAL_ERROR "URI '${uri}' is not a valid git@ or HTTP(S) Git URI")
    ENDIF()

    STRING(REGEX MATCH "^git@([^:]+):(.+)$" ssh_match "${uri}")
    IF(NOT ssh_match)
        MESSAGE(FATAL_ERROR "URI '${uri}' is not a valid git@ or HTTP(S) Git URI")
    ENDIF()

    STRING(REGEX REPLACE "^git@([^:]+):(.+)$" "\\1" hostname "${uri}")
    STRING(REGEX REPLACE "^git@([^:]+):(.+)$" "\\2" path "${uri}")

    SET(https_uri "https://${hostname}/${path}")
    SET(${__OUTPUT_VAR} "${https_uri}" PARENT_SCOPE)
ENDFUNCTION()


##
#
# Test TRANSFORM_GIT_URI function for proper functionality :).
#
# <function>()
#
FUNCTION(TRANSFORM_GIT_URI_HTTP_TO_GIT_TEST)

    LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../")
    FIND_PACKAGE(CMLIB)
    INCLUDE("${CMAKE_CURRENT_LIST_DIR}/TEST.cmake")

    # Test HTTP to SSH transformation
    TRANSFORM_GIT_URI(
        URI "https://github.com/username/repository.git"
        OUTPUT_VAR result
    )
    TEST_VAR_EQUALS_LITERAL(result "git@github.com:username/repository.git")

    # Test HTTPS to SSH transformation
    TRANSFORM_GIT_URI(
        URI "https://gitlab.com/user/repo.git"
        OUTPUT_VAR result
    )
    TEST_VAR_EQUALS_LITERAL(result "git@gitlab.com:user/repo.git")

    # Test HTTP (non-secure) to SSH transformation
    TRANSFORM_GIT_URI(
        URI "http://example.com/path/to/repo.git"
        OUTPUT_VAR result
    )
    TEST_VAR_EQUALS_LITERAL(result "git@example.com:path/to/repo.git")

    # Test git@ URI passthrough
    TRANSFORM_GIT_URI(
        URI "git@github.com:user/repo.git"
        OUTPUT_VAR result
    )
    TEST_VAR_EQUALS_LITERAL(result "git@github.com:user/repo.git")

    # Test complex path
    TRANSFORM_GIT_URI(
        URI "https://gitlab.example.com/group/subgroup/project.git"
        OUTPUT_VAR result
    )
    TEST_VAR_EQUALS_LITERAL(result "git@gitlab.example.com:group/subgroup/project.git")

    # Test repository without .git extension
    TRANSFORM_GIT_URI(
        URI "https://github.com/user/repo"
        OUTPUT_VAR result
    )
    TEST_VAR_EQUALS_LITERAL(result "git@github.com:user/repo")

    # Test with port number
    TRANSFORM_GIT_URI(
        URI "https://git.example.com:8080/user/repo.git"
        OUTPUT_VAR result
    )
    TEST_VAR_EQUALS_LITERAL(result "git@git.example.com:8080:user/repo.git")
ENDFUNCTION()


##
#
# Test TRANSFORM_GIT_URI_TO_HTTPS function for proper functionality :).
#
# <function>()
#
FUNCTION(TRANSFORM_GIT_URI_GIT_TO_HTTPS_TEST)

    LIST(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../")
    FIND_PACKAGE(CMLIB)
    INCLUDE("${CMAKE_CURRENT_LIST_DIR}/TEST.cmake")

    # Test SSH to HTTPS transformation
    TRANSFORM_GIT_URI_TO_HTTPS(
        URI "git@github.com:username/repository.git"
        OUTPUT_VAR result
    )
    TEST_VAR_EQUALS_LITERAL(result "https://github.com/username/repository.git")

    # Test SSH to HTTPS transformation with GitLab
    TRANSFORM_GIT_URI_TO_HTTPS(
        URI "git@gitlab.com:user/repo.git"
        OUTPUT_VAR result
    )
    TEST_VAR_EQUALS_LITERAL(result "https://gitlab.com/user/repo.git")

    # Test SSH to HTTPS transformation with custom domain
    TRANSFORM_GIT_URI_TO_HTTPS(
        URI "git@example.com:path/to/repo.git"
        OUTPUT_VAR result
    )
    TEST_VAR_EQUALS_LITERAL(result "https://example.com/path/to/repo.git")

    # Test HTTPS URI passthrough
    TRANSFORM_GIT_URI_TO_HTTPS(
        URI "https://github.com/user/repo.git"
        OUTPUT_VAR result
    )
    TEST_VAR_EQUALS_LITERAL(result "https://github.com/user/repo.git")

    # Test HTTP URI passthrough
    TRANSFORM_GIT_URI_TO_HTTPS(
        URI "http://example.com/user/repo.git"
        OUTPUT_VAR result
    )
    TEST_VAR_EQUALS_LITERAL(result "http://example.com/user/repo.git")

    # Test complex path with SSH
    TRANSFORM_GIT_URI_TO_HTTPS(
        URI "git@gitlab.example.com:group/subgroup/project.git"
        OUTPUT_VAR result
    )
    TEST_VAR_EQUALS_LITERAL(result "https://gitlab.example.com/group/subgroup/project.git")

    # Test repository without .git extension
    TRANSFORM_GIT_URI_TO_HTTPS(
        URI "git@github.com:user/repo"
        OUTPUT_VAR result
    )
    TEST_VAR_EQUALS_LITERAL(result "https://github.com/user/repo")
ENDFUNCTION()

TRANSFORM_GIT_URI_HTTP_TO_GIT_TEST()
TRANSFORM_GIT_URI_GIT_TO_HTTPS_TEST()