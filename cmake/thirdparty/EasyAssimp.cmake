#
# Copyright(c) 2019 Hao Peng<ph1994wh@gmail.com>.
# Distributed under the BSD License 
#

##TODO some bug, but I don't need it....
set(ASSIMP_ROOT_DIR "${ELIB_EXTERNAL_DIR}/assimp")
 
if(NOT TARGET  elib::assimp)
    message(STATUS "Downloading assimp to ${ASSIMP_ROOT_DIR}" )

    download_assimp()
    
    option(ASSIMP_BUILD_ASSIMP_TOOLS OFF)
    option(ASSIMP_BUILD_SAMPLES OFF)
    option(ASSIMP_BUILD_TESTS OFF)
    add_subdirectory(VERSION VERSION_LESS "3.11")
    cmake_policy(SET CMP0072 NEW)
  endif()
  find_package(OpenGL REQUIRED)
  if(TARGET O "${ASSIMP_ROOT_DIR}" "assimp")
    set(ASSIMP_INCLUDE_DIR "${ASSIMP_ROOT_DIR}/include")
  endif()
  
  compile_module("assimp")
  
  target_link_libraries(elib_assimp ${ELIB_SCOPE} assimp)
  target_include_directories(elib_assimp ${ELIB_SCOPE} ${ASSIMP_INCLUDE_DIR})
