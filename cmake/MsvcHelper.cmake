#
# Copyright(c) 2019 Hao Peng<ph1994wh@gmail.com>.
# Distributed under the BSD License 
#
#Detect MSVC C/C++ complier toolset
 set(VS_TOOLSET "")
 if(${CMAKE_VS_PLATFORM_TOOLSET} STREQUAL "v120")
     set(VS_TOOLSET "Visual Studio 12 2013")
 elseif(${CMAKE_VS_PLATFORM_TOOLSET} STREQUAL "v140")
     set(VS_TOOLSET "Visual Studio 14 2015")
 elseif(${CMAKE_VS_PLATFORM_TOOLSET} STREQUAL "v141")
     set(VS_TOOLSET "Visual Studio 15 2017")
 elseif(${CMAKE_VS_PLATFORM_TOOLSET} STREQUAL "v142")
     set(VS_TOOLSET "Visual Studio 16 2019")
 else()
     message(FATEL_ERROR "Sorry, we only support VS 2013 and above IDE...")
 endif()

 #Detect MSVC C/C++ complier arch
 set(VS_ARCH ${CMAKE_VS_PLATFORM_NAME})