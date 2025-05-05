# include/beman/nullable/CMakeLists.txt -*-cmake-*-
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

target_sources(
    beman_nullable
    PUBLIC FILE_SET beman_nullable_headers TYPE HEADERS FILES nullable.hpp
)

install(
    TARGETS beman_nullable
    FILE_SET beman_nullable_headers
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
        COMPONENT beman_nullable_development
)

install(
    TARGETS beman_nullable
    EXPORT beman_nullable_export
    DESTINATION
    ${CMAKE_INSTALL_LIBDIR}
    FILE_SET beman_nullable_headers
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
        COMPONENT beman_nullable_development
)

install(
    EXPORT beman_nullable_export
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/beman/nullable/
    NAMESPACE Beman::Nullable::
    FILE beman_nullable.cmake
    EXPORT_LINK_INTERFACE_LIBRARIES
    COMPONENT beman_nullable_development
)
