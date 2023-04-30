set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

set(triple x86_64-w64-mingw32)

set(CMAKE_C_COMPILER /cross/bin/${triple}-gcc)
set(CMAKE_CXX_COMPILER /cross/bin/${triple}-g++)
set(CMAKE_RC_COMPILER /cross/bin/${triple}-windres)
set(CMAKE_ASM_COMPILER /cross/bin/${triple}-as)

set(CMAKE_FIND_ROOT_PATH @TOP_DIR@/opt)
set(CMAKE_INSTALL_PREFIX @TOP_DIR@/opt)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
