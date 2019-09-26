#
# Copyright(c) 2019 Hao Peng<ph1994wh@gmail.com>.
# Distributed under the BSD License 
#
set(GLM_ROOT_DIR "${EXTERNAL_DIR}/glm")
if(NOT TARGET  elib::glm)
    message(STATUS "Downloading glm to ${GLM_ROOT_DIR}" )
    download_glm()

    option(GLM_TEST_ENABLE OFF)
    option(BUILD_STATIC_LIBS OFF)

    if(USE_STATIC_LIBRARY)
      option(BUILD_STATIC_LIBS ON)
    endif()
    add_subdirectory("${GLM_ROOT_DIR}" "glm")
  endif()
compile_module("glm")
target_include_directories(elib_glm ${ELIB_SCOPE_WITH_GLM}  ${GLM_ROOT_DIR} )
target_link_libraries(elib_glm ${ELIB_SCOPE_WITH_GLM} glm)
