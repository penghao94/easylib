#
# Copyright(c) 2019 Hao Peng<ph1994wh@gmail.com>.
# Distributed under the BSD License 
#

#Set tetgen directory
set(TETGEN_DIR "${ELIB_EXTERNAL_DIR}/tetgen")
if(NOT TARGET tetgen)
    message(STATUS "Downloading tetgen to ${TETGEN_DIR}")
    download_tetgen()# Download or upgrade tetgen
    add_subdirectory(${TETGEN_DIR} tetgen)
    compile_module("tetgen")# Generate elib::tetgen module
    
    target_include_directories(elib_tetgen ${ELIB_SCOPE} ${TETGEN_DIR})
    target_link_libraries(elib_tetgen ${ELIB_SCOPE} tetgen)
    
endif()

