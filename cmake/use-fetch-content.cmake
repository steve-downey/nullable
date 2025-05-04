cmake_minimum_required(VERSION 3.24)

if(NOT BEMAN_NULLABLE_LOCKFILE)
    set(BEMAN_NULLABLE_LOCKFILE
        "lockfile.json"
        CACHE FILEPATH
        "Path to the dependency lockfile for the Beman Nullable."
    )
endif()

set(BemanNullable_projectDir "${CMAKE_CURRENT_LIST_DIR}/..")
message(TRACE "BemanNullable_projectDir=\"${BemanNullable_projectDir}\"")

message(TRACE "BEMAN_NULLABLE_LOCKFILE=\"${BEMAN_NULLABLE_LOCKFILE}\"")
file(
    REAL_PATH
    "${BEMAN_NULLABLE_LOCKFILE}"
    BemanNullable_lockfile
    BASE_DIRECTORY "${BemanNullable_projectDir}"
    EXPAND_TILDE
)
message(DEBUG "Using lockfile: \"${BemanNullable_lockfile}\"")

# Force CMake to reconfigure the project if the lockfile changes
set_property(
    DIRECTORY "${BemanNullable_projectDir}"
    APPEND
    PROPERTY CMAKE_CONFIGURE_DEPENDS "${BemanNullable_lockfile}"
)

# For more on the protocol for this function, see:
# https://cmake.org/cmake/help/latest/command/cmake_language.html#provider-commands
function(BemanNullable_provideDependency method package_name)
    # Read the lockfile
    file(READ "${BemanNullable_lockfile}" BemanNullable_rootObj)

    # Get the "dependencies" field and store it in BemanNullable_dependenciesObj
    string(
        JSON
        BemanNullable_dependenciesObj
        ERROR_VARIABLE BemanNullable_error
        GET "${BemanNullable_rootObj}"
        "dependencies"
    )
    if(BemanNullable_error)
        message(FATAL_ERROR "${BemanNullable_lockfile}: ${BemanNullable_error}")
    endif()

    # Get the length of the libraries array and store it in BemanNullable_dependenciesObj
    string(
        JSON
        BemanNullable_numDependencies
        ERROR_VARIABLE BemanNullable_error
        LENGTH "${BemanNullable_dependenciesObj}"
    )
    if(BemanNullable_error)
        message(FATAL_ERROR "${BemanNullable_lockfile}: ${BemanNullable_error}")
    endif()

    # Loop over each dependency object
    math(EXPR BemanNullable_maxIndex "${BemanNullable_numDependencies} - 1")
    foreach(BemanNullable_index RANGE "${BemanNullable_maxIndex}")
        set(BemanNullable_errorPrefix
            "${BemanNullable_lockfile}, dependency ${BemanNullable_index}"
        )

        # Get the dependency object at BemanNullable_index
        # and store it in BemanNullable_depObj
        string(
            JSON
            BemanNullable_depObj
            ERROR_VARIABLE BemanNullable_error
            GET "${BemanNullable_dependenciesObj}"
            "${BemanNullable_index}"
        )
        if(BemanNullable_error)
            message(
                FATAL_ERROR
                "${BemanNullable_errorPrefix}: ${BemanNullable_error}"
            )
        endif()

        # Get the "name" field and store it in BemanNullable_name
        string(
            JSON
            BemanNullable_name
            ERROR_VARIABLE BemanNullable_error
            GET "${BemanNullable_depObj}"
            "name"
        )
        if(BemanNullable_error)
            message(
                FATAL_ERROR
                "${BemanNullable_errorPrefix}: ${BemanNullable_error}"
            )
        endif()

        # Get the "package_name" field and store it in BemanNullable_pkgName
        string(
            JSON
            BemanNullable_pkgName
            ERROR_VARIABLE BemanNullable_error
            GET "${BemanNullable_depObj}"
            "package_name"
        )
        if(BemanNullable_error)
            message(
                FATAL_ERROR
                "${BemanNullable_errorPrefix}: ${BemanNullable_error}"
            )
        endif()

        # Get the "git_repository" field and store it in BemanNullable_repo
        string(
            JSON
            BemanNullable_repo
            ERROR_VARIABLE BemanNullable_error
            GET "${BemanNullable_depObj}"
            "git_repository"
        )
        if(BemanNullable_error)
            message(
                FATAL_ERROR
                "${BemanNullable_errorPrefix}: ${BemanNullable_error}"
            )
        endif()

        # Get the "git_tag" field and store it in BemanNullable_tag
        string(
            JSON
            BemanNullable_tag
            ERROR_VARIABLE BemanNullable_error
            GET "${BemanNullable_depObj}"
            "git_tag"
        )
        if(BemanNullable_error)
            message(
                FATAL_ERROR
                "${BemanNullable_errorPrefix}: ${BemanNullable_error}"
            )
        endif()

        if(method STREQUAL "FIND_PACKAGE")
            if(package_name STREQUAL BemanNullable_pkgName)
                string(
                    APPEND
                    BemanNullable_debug
                    "Redirecting find_package calls for ${BemanNullable_pkgName} "
                    "to FetchContent logic fetching ${BemanNullable_repo} at "
                    "${BemanNullable_tag} according to ${BemanNullable_lockfile}."
                )
                message(STATUS "${BemanNullable_debug}")
                FetchContent_Declare(
                    "${BemanNullable_name}"
                    GIT_REPOSITORY "${BemanNullable_repo}"
                    GIT_TAG "${BemanNullable_tag}"
                    EXCLUDE_FROM_ALL
                )
                set(INSTALL_GTEST OFF) # Disable GoogleTest installation
                FetchContent_MakeAvailable("${BemanNullable_name}")

                # Important! <PackageName>_FOUND tells CMake that `find_package` is
                # not needed for this package anymore
                message(STATUS "setting ${BemanNullable_pkgName}_FOUND to true")
                set("${BemanNullable_pkgName}_FOUND" TRUE PARENT_SCOPE)
            endif()
        endif()
    endforeach()

    # set(GTest_FOUND TRUE PARENT_SCOPE)
endfunction()

cmake_language(
    SET_DEPENDENCY_PROVIDER BemanNullable_provideDependency
    SUPPORTED_METHODS FIND_PACKAGE
)
