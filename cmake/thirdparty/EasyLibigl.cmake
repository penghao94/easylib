#
# Copyright(c) 2019 Hao Peng<ph1994wh@gmail.com>.
# Distributed under the BSD License 
#

#Set Libigl root dir
set(LIBIGL_ROOT_DIR ${ELIB_EXTERNAL_DIR}/libigl)

if(NOT TARGET elib::libigl)
# For libigl, we just want to use its fundamental methods in igl/inlcude, but we allow user to option by adding libigl_with_xxx.
set(LIBIGL_USE_STATIC_LIBRARY TRUE CACHE BOOL "" FORCE)
include(${LIBIGL_ROOT_DIR}/cmake/libigl.cmake)

compile_module("libigl")

set(LIBIGL_LIBRARIES igl::core)

if(LIBIGL_WITH_CGAL)
    list(APPEND LIBIGL_LIBRARIES igl::cgal)
endif()

if(LIBIGL_WITH_COMISO)
    list(APPEND LIBIGL_LIBRARIES igl::comiso)
endif()

if(LIBIGL_WITH_CORK)
    list(APPEND LIBIGL_LIBRARIES igl::cork)
endif()

if(LIBIGL_WITH_EMBREE)
    list(APPEND LIBIGL_LIBRARIES igl::embree)
endif()

if(LIBIGL_WITH_MATLAB)
    list(APPEND LIBIGL_LIBRARIES igl::matlab)
endif()

if(LIBIGL_WITH_MOSEK)
    list(APPEND LIBIGL_LIBRARIES igl::mosek)
endif()

if(LIBIGL_WITH_PNG)
    list(APPEND LIBIGL_LIBRARIES igl::png)
endif()

if(LIBIGL_WITH_TRIANGLE)
    list(APPEND LIBIGL_LIBRARIES igl::triangle)
endif()

if(LIBIGL_WITH_XML)
    list(APPEND LIBIGL_LIBRARIES igl::xml)
endif()

target_link_libraries(elib_libigl ${ELIB_SCOPE_WITH_LIBIGL} ${LIBIGL_LIBRARIES})

endif()