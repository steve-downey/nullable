# src/beman/nullable/tests/CMakeLists.txt -*-cmake-*-
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

target_sources(beman_nullable_test PRIVATE nullable.t.cpp)

target_link_libraries(
    beman_nullable_test
    PRIVATE beman_nullable GTest::gtest GTest::gtest_main
)
include(GoogleTest)
gtest_add_tests(TARGET beman_nullable_test "" AUTO)
