# CMakeLists.txt                                                    -*-CMake-*-
#
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

cmake_minimum_required(VERSION 3.27)

project(beman_nullable VERSION 0.0.0 LANGUAGES CXX)

# Includes
include(CTest)
include(FetchContent)

set(TARGETS_EXPORT_NAME ${CMAKE_PROJECT_NAME}Targets)

option(
    NULLABLE_ENABLE_TESTING
    "Enable building tests and test infrastructure"
    ${PROJECT_IS_TOP_LEVEL}
)

set(CMAKE_VERIFY_INTERFACE_HEADER_SETS ON)

# Create the library target and named header set for beman_nullable
add_library(beman_nullable INTERFACE)
add_library(beman::nullable ALIAS beman_nullable)
target_sources(
    beman_nullable
    PUBLIC FILE_SET beman_nullable_headers TYPE HEADERS BASE_DIRS include
)

if(NULLABLE_ENABLE_TESTING)
    find_package(GTest QUIET)
    if(GTest_FOUND)
        # Create the library target and named header set for testing beman_nullable
        # and mark the set private
        add_executable(beman_nullable_test)
        target_sources(
            beman_nullable_test
            PRIVATE
                FILE_SET beman_nullable_test_headers
                TYPE HEADERS
                BASE_DIRS tests
        )
        # Tests
        add_subdirectory(tests/beman/nullable)
    else()
        message(
            WARNING
            "
No provider for GTest. Unable to build tests.
Consider using CMAKE_PROJECT_TOP_LEVEL_INCLUDES=./cmake/use-fetch-content.cmake as documented in the README.md
"
        )
    endif()
endif()

add_subdirectory(include/beman/nullable)

add_subdirectory(examples)

include(CMakePackageConfigHelpers)

# This will be used to replace @PACKAGE_cmakeModulesDir@
set(cmakeModulesDir cmake/beman)
configure_package_config_file(
    cmake/Config.cmake.in
    BemanNullableConfig.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/beman/nullable/
    PATH_VARS cmakeModulesDir
    NO_SET_AND_CHECK_MACRO
    NO_CHECK_REQUIRED_COMPONENTS_MACRO
)

install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/BemanNullableConfig.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/beman/nullable/
    COMPONENT beman_nullable_development
)

# Coverage
configure_file("cmake/gcovr.cfg.in" gcovr.cfg @ONLY)

add_custom_target(
    process_coverage
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "Running gcovr to process coverage results"
    COMMAND mkdir -p coverage
    COMMAND gcovr --config gcovr.cfg .
)
