#
# Copyright(c) 2019 Hao Peng<ph1994wh@gmail.com>.
# Distributed under the BSD License 
#

#Dependices
include(EasyGlfw.cmake)

set(IMGUI_ROOT_DIR "${ELIB_EXTERNAL_DIR}/imgui")

  if(NOT TARGET  elib::imgui)
    message(STATUS "Downloading Imgui to ${GLAD_DIR}" )
    download_imgui()
    file(GLOB IMGUI_SOURCE "${IMGUI_ROOT_DIR}/*.cpp" "${IMGUI_ROOT_DIR}/examples/imgui_impl_glfw.cpp" "${IMGUI_ROOT_DIR}/examples/imgui_impl_opengl3.cpp")
    add_library(imgui "${IMGUI_SOURCE}")
    set(INGUI_INCLUDE_DIR "")
    list(APPEND IMGUI_INCLUDE_DIR ${IMGUI_ROOT_DIR})
    list(APPEND IMGUI_INCLUDE_DIR ${IMGUI_ROOT_DIR}/examples)
    target_include_directories(imgui PUBLIC ${IMGUI_INCLUDE_DIR})
    target_link_libraries(imgui PUBLIC elib_glfw)
    target_compile_definitions(imgui PUBLIC -DIMGUI_IMPL_OPENGL_LOADER_GLAD)
  endif()
  compile_module("imgui")
  target_link_libraries(elib_imgui ${ELIB_SCOPE_WITH_IMGUI} imgui )