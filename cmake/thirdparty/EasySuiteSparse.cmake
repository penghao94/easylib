#
# Copyright(c) 2019 Hao Peng<ph1994wh@gmail.com>.
# Distributed under the BSD License 
#
if(NOT TARGET elib::suitesparse)
    set(SUITESPARSE_ROOT_DIR "${ELIB_EXTERNAL_DIR}/suitesparse")
    message(STATUS "\nDownloading suitesparse to ${SUITESPARSE_ROOT_DIR}" )
    download_suitesparse()
    if(WIN32)
        if(MSVC)
            # We need to set LAPACK_DIR to call LAPACK and BLAS
            set(LAPACK_DIR "")
            if(${VS_ARCH} STREQUAL "x64")
                set(LAPACK_DIR "${SUITESPARSE_ROOT_DIR}/lapack_windows/x64")
            elseif(${VS_ARCH} STREQUAL "Win32")
                set(LAPACK_DIR "${SUITESPARSE_ROOT_DIR}/lapack_windows/x32")
            else()
                message(FATEL_ERROR "Sorry, LAPACK and BLAS only support X86 arch on Windows...")
            endif()
            set(BLAS_LIBRARIES "${LAPACK_DIR}/libblas.lib")
            message(STATUS "\ncmake -S ${SUITESPARSE_ROOT_DIR} -B ${SUITESPARSE_ROOT_DIR}/build -G ${VS_TOOLSET} -A ${VS_ARCH} -DCMAKE_INSTALL_PREFIX=${SUITESPARSE_ROOT_DIR}/SuiteSparse -DSuiteSparse_USE_LAPACK_BLAS=true -DLAPACK_DIR=${LAPACK_DIR}\n" )
            execute_process(COMMAND ${CMAKE_COMMAND} -S ${SUITESPARSE_ROOT_DIR} -B ${SUITESPARSE_ROOT_DIR}/build -G ${VS_TOOLSET} -A ${VS_ARCH} -DCMAKE_INSTALL_PREFIX=${SUITESPARSE_ROOT_DIR}/install -DSuiteSparse_USE_LAPACK_BLAS=true -DLAPACK_DIR=${LAPACK_DIR}
                                    WORKING_DIRECTORY ${SUITESPARSE_ROOT_DIR} OUTPUT_QUIET)
                
            set(SUITESPARSE_BUILD_TYPE "Debug" "Release")

            foreach(SBT ${SUITESPARSE_BUILD_TYPE})
            message(STATUS "cmake --build . --target INSTALL --config ${SBT}\n" )
            execute_process( COMMAND ${CMAKE_COMMAND} --build . --target INSTALL --config ${SBT} 
                                WORKING_DIRECTORY ${SUITESPARSE_ROOT_DIR}/build OUTPUT_QUIET)
            endforeach()
        else()
            message(FATEL_ERROR "Sorry, we just support MSVC complier on Windows platform...")
        endif()
    else()
        #Lapack and blas is required for linux and macos 
        find_package(LAPACK)
        find_package(BLAS)
        if(NOT LAPACK_FOUND AND NOT BLAS_FOUND)
            message(FATAL_ERROR "LAPACK & BLAS is required, you can install them by bash sudo apt-get install liblapack-dev libblas-dev.")
        endif()

        #Install SuiteSparse
        message(STATUS "cmake -S ${SUITESPARSE_ROOT_DIR} -B ${SUITESPARSE_ROOT_DIR}/build -DCMAKE_INSTALL_PREFIX=${SUITESPARSE_ROOT_DIR}/SuiteSparse -DSuiteSparse_USE_LAPACK_BLAS=true -DLAPACK_DIR=${LAPACK_DIR}\n" )
        execute_process(COMMAND ${CMAKE_COMMAND} -S ${SUITESPARSE_ROOT_DIR} -B ${SUITESPARSE_ROOT_DIR}/build -G ${VS_TOOLSET} -A ${CMAKE_VS_PLATFORM_NAME} -DCMAKE_INSTALL_PREFIX=${SUITESPARSE_ROOT_DIR}/install -DSuiteSparse_USE_LAPACK_BLAS=true -DLAPACK_DIR=${LAPACK_DIR}
                                    WORKING_DIRECTORY ${SUITESPARSE_ROOT_DIR} OUTPUT_QUIET)
                
        set(SUITESPARSE_BUILD_TYPE "Debug" "Release")

        foreach(SBT ${SUITESPARSE_BUILD_TYPE})
            message(STATUS "cmake --build . --target INSTALL --config ${SBT}\n" )
            execute_process(COMMAND ${CMAKE_COMMAND} --build . --config ${SBT} 
                                WORKING_DIRECTORY ${SUITESPARSE_ROOT_DIR}/build OUTPUT_QUIET)
        endforeach()
    endif()

    # Check for SuiteSparse and dependencies.
    set(SUITESPARSE_INSTALL_PREFIX ${SUITESPARSE_ROOT_DIR}/install)
    get_config_path(NAME SuiteSparse INSTALL_PREFIX ${SUITESPARSE_INSTALL_PREFIX})
    find_package(SuiteSparse)
    if (SuiteSparse_FOUND)
        compile_module("suitesparse")
        target_include_directories(elib_suitesparse ${ELIB_SCOPE_WITH_SUITESPARSE} ${SuiteSparse_INCLUDE_DIRS})
        target_link_libraries( elib_suitesparse ${ELIB_SCOPE_WITH_SUITESPARSE}  ${SuiteSparse_LIBRARIES})
    endif()
endif()
