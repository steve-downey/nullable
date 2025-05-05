# cmake-format: off
# examples/CMakeLists.txt -*-makefile-*-
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
# cmake-format: on

set(BEMAN_NULLABLE_LIBRARY "beman::nullable")

include(GNUInstallDirs)

# List of all buildable examples.
set(EXAMPLES main)

foreach(example ${EXAMPLES})
    # Add example executable.
    add_executable(${example} "")

    # Add example source file.
    target_sources(${example} PRIVATE ${example}.cpp)

    # Link example with the library.
    target_link_libraries(${example} "${BEMAN_NULLABLE_LIBRARY}")

    add_test(NAME ${example} COMMAND ${example})

    # Install .
    install(
        TARGETS
            ${example}
            COMPONENT
            beman_nullable_examples
            DESTINATION
            ${CMAKE_INSTALL_BINDIR}
    )
endforeach()
