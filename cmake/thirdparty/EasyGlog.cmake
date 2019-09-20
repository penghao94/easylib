#
# Copyright(c) 2019 Hao Peng<ph1994wh@gmail.com>.
# Distributed under the BSD License 
#

#set glog root dir
set(GLOG_DIR ${ELIB_EXTERNAL_DIR}/glog)

if(NOT TARGET glog)
    message(STATUS "Downloading glog to ${GLOG_DIR}")
    download_glog()

    include(EasyGflags)

    if(WIN32)
        if(MSVC)
            #Configure glog
            message(STATUS "cmake -S ${GLOG_DIR} -B ${GLOG_DIR}/glog-build -G ${VS_TOOLSET} -A ${VS_ARCH} -DCMAKE_INSTALL_PREFIX=${GLOG_DIR}/glog-install -DWITH_GFLAGS=true -DGFLAGS_DIR=${GFLAGS_DIR}\n")
            execute_process(COMMAND cmake -S ${GLOG_DIR} -B ${GLOG_DIR}/glog-build -G ${VS_TOOLSET} -A ${VS_ARCH} -DCMAKE_INSTALL_PREFIX=${GLOG_DIR}/glog-install -DWITH_GFLAGS=true -DGFLAGS_DIR=${GFLAGS_DIR}  -DBUILD_TESTING=false WORKING_DIRECTORY ${GLOG_DIR} OUTPUT_QUIET)

            #Build and install glog
            set(GFLAGS_BUILD_TYPE "Debug" "Release")
            foreach(glbt ${GFLAGS_BUILD_TYPE})
                message(STATUS "cmake -S  execute_process(COMMAND cmake --build . --target INSTALL --config ${glbt}\n")
                execute_process(COMMAND cmake --build . --target INSTALL --config ${glbt} WORKING_DIRECTORY ${GLOG_DIR}/glog-build OUTPUT_QUIET )
            endforeach()
        else()
            message(FATEL_ERROR "Sorry, we just support MSVC complier on Windows platform...")
        endif()
    else()
        #Configure glog
        message(STATUS "cmake -S ${GLOG_DIR} -B ${GLOG_DIR}/glog-build -DCMAKE_INSTALL_PREFIX=${GLOG_DIR}/glog-install -DWITH_GFLAGS=true -DGFLAGS_DIR=${GFLAGS_DIR}  -DBUILD_TESTING=false\n")
        execute_process(COMMAND cmake -S ${GLOG_DIR} -B ${GLOG_DIR}/glog-build -DCMAKE_INSTALL_PREFIX=${GLOG_DIR}/glog-install -DWITH_GFLAGS=true -DGFLAGS_DIR=${GFLAGS_DIR}  -DBUILD_TESTING=false WORKING_DIRECTORY ${GLOG_DIR}OUTPUT_QUIET)

        #Build and install glog
        set(GFLAGS_BUILD_TYPE "Debug" "Release")
        foreach(glbt ${GFLAGS_BUILD_TYPE})
            message(STATUS "cmake --build . --config ${glbt}\n")
            execute_process(COMMAND cmake --build . --config ${glbt} WORKING_DIRECTORY ${GLOG_DIR}/glog-build OUTPUT_QUIET)
        endforeach()
    endif()

    # Check for Gflags and dependencies
    set(GLOG_DIR ${${GLOG_DIR}/glog-install/lib/cmake})
    find_package(glog CONFIG HINTS ${GLOG_DIR})

    if(TARGET glog::glog)
        compile_module("glog")
        target_link_libraries(elib_glog ${ELIB_SCOPE} glog::glog)
    endif()
endif()