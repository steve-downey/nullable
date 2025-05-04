# cmake-format: off
# etc/clang-20-toolchain.cmake -*-cmake-*-
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
# cmake-format: on

include_guard(GLOBAL)

set(CMAKE_C_COMPILER clang-20)
set(CMAKE_CXX_COMPILER clang++-20)

include("${CMAKE_CURRENT_LIST_DIR}/clang-flags.cmake")
