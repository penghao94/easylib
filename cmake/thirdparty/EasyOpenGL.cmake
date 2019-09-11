#
# Copyright(c) 2019 Hao Peng<ph1994wh@gmail.com>.
# Distributed under the BSD License 
#

# OpenGL module
compile_module("opengl")

# OpenGL library
if (NOT CMAKE_VERSION VERSION_LESS "3.11")
  cmake_policy(SET CMP0072 NEW)
endif()
find_package(OpenGL REQUIRED)
if(TARGET OpenGL::GL)
  target_link_libraries(elib_opengl ${ELIB_SCOPE} OpenGL::GL)
else()
  target_link_libraries(elib_opengl ${ELIB_SCOPE} ${OPENGL_gl_LIBRARY})
  target_include_directories(elib_opengl SYSTEM ${ELIB_SCOPE} ${OPENGL_INCLUDE_DIR})
endif()