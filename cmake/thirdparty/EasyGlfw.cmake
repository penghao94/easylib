#
# Copyright(c) 2019 Hao Peng<ph1994wh@gmail.com>.
# Distributed under the BSD License 
#
#Dependices
include(EasyOpenGL)
include(EasyGlad)

set(GLFW_ROOT_DIR "${EXTERNAL_DIR}/glfw")

  if(NOT TARGET  elib::glfw)
    message(STATUS "download glfw ..." )
    download_glfw()
    option(GLFW_BUILD_DOCS OFF)
    option(GLFW_BUILD_EXAMPLES OFF)
    option(GLFW_BUILD_TESTS OFF)
    option(GLFW_INSTALL OFF)
    add_subdirectory("${GLFW_ROOT_DIR}" "glfw")
  endif()
  compile_module("glfw")
  target_link_libraries(elib_glfw ${ELIB_SCOPE} elib_opengl elib_glad  glfw )
  set(GLFW_INCLUDE_DIR "${GLFW_ROOT_DIR}/include")
  target_include_directories(elib_glfw ${ELIB_SCOPE} ${GLFW_INCLUDE_DIR})