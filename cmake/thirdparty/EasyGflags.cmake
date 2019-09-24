#
# Copyright(c) 2019 Hao Peng<ph1994wh@gmail.com>.
# Distributed under the BSD License 
#
#set gflags root dir
set(GFLAGS_ROOT_DIR "${ELIB_EXTERNAL_DIR}/gflags")
if(NOT TARGET  elib::gflags)
    message(STATUS "\nDownloading gflags to ${GFLAGS_ROOT_DIR}")
    download_gflags()

    if(WIN32)
        if(MSVC)
            #Configure gflags
            message(STATUS "\ncmake -S ${GFLAGS_ROOT_DIR} -B ${GFLAGS_ROOT_DIR}/gflags-build -G ${VS_TOOLSET} -A ${VS_ARCH} -DCMAKE_INSTALL_PREFIX=${GFLAGS_ROOT_DIR}/install -DBUILD_TESTING=false\n")
            execute_process(COMMAND cmake -S ${GFLAGS_ROOT_DIR} -B ${GFLAGS_ROOT_DIR}/gflags-build -G ${VS_TOOLSET} -A ${VS_ARCH} -DCMAKE_INSTALL_PREFIX=${GFLAGS_ROOT_DIR}/install -DBUILD_TESTING=false WORKING_DIRECTORY ${GFLAGS_ROOT_DIR} OUTPUT_QUIET)

            #Build and install gflags
            set(GFLAGS_BUILD_TYPE "Debug" "Release")
            foreach(gfbt ${GFLAGS_BUILD_TYPE})
                message(STATUS "cmake --build . --target INSTALL --config ${gfbt}\n" )
                execute_process(COMMAND cmake --build . --target INSTALL --config ${gfbt} WORKING_DIRECTORY ${GFLAGS_ROOT_DIR}/gflags-build OUTPUT_QUIET )
            endforeach()
        else()
            message(FATEL_ERROR "Sorry, we just support MSVC complier on Windows platform...")
        endif()
    else()
        #Configure gflags
        message(STATUS "cmake -S cmake -S ${GFLAGS_ROOT_DIR} -B ${GFLAGS_ROOT_DIR}/gflags-build -DCMAKE_INSTALL_PREFIX=${GFLAGS_ROOT_DIR}/install -DBUILD_TESTING=false\n")
        execute_process(COMMAND cmake -S ${GFLAGS_ROOT_DIR} -B ${GFLAGS_ROOT_DIR}/gflags-build -DCMAKE_INSTALL_PREFIX=${GFLAGS_ROOT_DIR}/install -DBUILD_TESTING=false WORKING_DIRECTORY ${GFLAGS_ROOT_DIR} OUTPUT_QUIET)

        #Build and install gflags
        set(GFLAGS_BUILD_TYPE "Debug" "Release")
        foreach(gfbt ${GFLAGS_BUILD_TYPE})
            message(STATUS "cmake --build . --config ${gfbt}\n" )
            execute_process(COMMAND cmake --build . --config ${gfbt}WORKING_DIRECTORY ${GFLAGS_ROOT_DIR}/gflags-build OUTPUT_QUIET)
        endforeach()
    endif()

    # Check for Gflags and dependencies
    set(GFLAGS_INSTALL_PREFIX  ${GFLAGS_ROOT_DIR}/install)
    get_config_path(NAME gflags INSTALL_PREFIX ${GFLAGS_INSTALL_PREFIX})
    find_package(gflags CONFIG)

    if(gflags_FOUND)
        compile_module("gflags")
        target_include_directories(elib_gflags ${ELIB_SCOPE} ${GFLAGS_INCLUDE_DIR})
        target_link_libraries(elib_gflags ${ELIB_SCOPE} ${GFLAGS_LIBRARIES})
    endif()
endif()