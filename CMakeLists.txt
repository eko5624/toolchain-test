cmake_minimum_required(VERSION 3.19.0)
project(mpv-cross C)

cmake_policy(SET CMP0097 NEW)
cmake_policy(SET CMP0114 NEW)
if(POLICY CMP0135)
  cmake_policy(SET CMP0135 NEW)
endif()

if (CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set (CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/cross" CACHE PATH "Default install path" FORCE )
endif()
set(MINGW_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX}/x86_64-w64-mingw32)


set(RUSTUP_LOCATION "${CMAKE_CURRENT_BINARY_DIR}/rustup_location" CACHE STRING "Absolute path to store rust toolchain")
set(TOOLCHAIN_FILE ${CMAKE_CURRENT_BINARY_DIR}/toolchain.cmake)
set(MESON_CROSS ${CMAKE_CURRENT_BINARY_DIR}/meson_cross.txt)
