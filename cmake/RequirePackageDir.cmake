#
# Copyright(c) 2019 Hao Peng<ph1994wh@gmail.com>.
# Distributed under the BSD License 
#
#Possible path
# <prefix>/                                                       (W)
# <prefix>/(cmake|CMake)/                                         (W)
# <prefix>/<name>*/                                               (W)
# <prefix>/<name>*/(cmake|CMake)/                                 (W)
# <prefix>/(lib/<arch>|lib*|share)/cmake/<name>*/                 (U)
# <prefix>/(lib/<arch>|lib*|share)/<name>*/                       (U)
# <prefix>/(lib/<arch>|lib*|share)/<name>*/(cmake|CMake)/         (U)
# <prefix>/<name>*/(lib/<arch>|lib*|share)/cmake/<name>*/         (W/U)
# <prefix>/<name>*/(lib/<arch>|lib*|share)/<name>*/               (W/U)
# <prefix>/<name>*/(lib/<arch>|lib*|share)/<name>*/(cmake|CMake)/ (W/U)

#Usage:
# get_config_path(NAME name
#                 INSTALL_PREFIX path
#                 HINTS hint1 [hint2 hint3....])

macro(GET_CONFIG_PATH)
    include(CMakeParseArguments)
    set(options REQUIRED)
    set(oneValueArgs NAME INSTALL_PREFIX)
    set(multiValueArgs HINTS)
    cmake_parse_arguments(CONFIG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
   
    string(TOLOWER ${CONFIG_NAME} CONFIG_NAME_LOWER)

    set(pkgname "/${CONFIG_NAME}*" "/${CONFIG_NAME_LOWER}*" "/")
    set(cmakeexist "/[Cc]make" "/")
    set(libname "/lib*" "share" "/")
    set(filename  "/${CONFIG_NAME_LOWER}-config.cmake" "/${CONFIG_NAME}Config.cmake")

    set(full_path "")

    foreach(p ${pkgname})
        foreach(l ${libname})
            foreach(k ${pkgname})
                foreach(c ${cmakeexist})
                    foreach(g ${pkgname})
                        foreach(f ${filename})
                            list(APPEND full_path "${CONFIG_INSTALL_PREFIX}${p}${l}${k}${c}${g}${f}")
                        endforeach(f ${filename})
                    endforeach(g ${pkgname})                  
                endforeach(c ${cmakeexist})                
            endforeach(k ${pkgname})            
        endforeach(l ${libname})        
    endforeach(p ${pkgname})

    unset(pkgname)
    unset(cmakeexist)
    unset(libname)
    unset(filename)

    if(${CONFIG_HINTS})
        foreach(h ${CONFIG_HINTS})
            list(APPEND full_path ${h})
        endforeach(h ${CONFIG_HINTS})    
    endif()
   
    set( config_dir "")
    foreach(i ${full_path})
        string(REGEX REPLACE "/+" "/" i ${i})
        list(APPEND  config_dir ${i})
    endforeach(i ${full_path})  

    file(GLOB ${CONFIG_NAME}_DIR ${config_dir})

          
     if(${CONFIG_NAME}_DIR)
        #string(REGEX REPLACE "(${CONFIG_NAME}Config.cmake|${CONFIG_NAME_LOWER}-config.cmake)" "" ${CONFIG_NAME}_DIR ${${CONFIG_NAME}_DIR})
        get_filename_component(${CONFIG_NAME}_DIR ${${CONFIG_NAME}_DIR} DIRECTORY)
        message(STATUS "Find ${CONFIG_NAME} config file at ${${CONFIG_NAME}_DIR}\n")
    else()
        message(WARNING "Can not find ${CONFIG_NAME}_DIR...")
     endif()

    unset(CONFIG_NAME)
    unset(CONFIG_INSTALL_PREFIX)
    unset(CONFIG_HINT)
    unset(full_path)
    unset(config_dir)
endmacro()
