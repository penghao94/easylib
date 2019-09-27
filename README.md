# Easylib
 
Easylib是一个能对C/C++ 第三方库依赖进行自动配置，有效管理的配置库。Easylib的目标是能够使C/C++ 第三方库配置在Linux、Mac OS，尤其是Windows上能够像Python库导入那样简单，使用者不必将有限的时间投入到繁琐的配置中，能够高效的管理库文件，方便的在不同的平台下移植。

Esaylib借助于跨平台的C/C++配置与生成工具Cmake来完成C/C++自动生成与管理，Easylib由纯CMake脚本语言编写成，除Cmake以外不依赖其他任何工具，能够做到下载即用。

## Easylib features
1. Easylib本身已经封装好对第三方库的所有配置，使用者只需简单的调用就可以使用他们。Easylib体积很小，只借助于Cmake工具就可以使用，并且可以实现跨平台调用。

2. 借助 Morden Cmake 中对象管理的概念，easylib将基础配置、第三方库依赖，甚至使用者自己的项目都封装成一个个target。 每个target都是self-contained的，包含涉及这个target的所有属性的配置，并且可以暴露一定的属性和接口来被其他target调用。

3. 下图为使用easylib的架构图，在easylib部分。 target: easylib common 封装了整个项目的全局配置属性，target: easylib core 封装了一些不涉及第三方库的公共函数，这两个target作为底层分别被管理第三方库函数的target继承。每个第三方库target都是self-contained的，封装了调用此库所需要的一切配置。虽然target之间会存在相互调用，比如 library C需要调用library A和 library B。但这种调用是隐藏的，用户只需要调用，而不必要显式的调用A和B. 

    ![1.png](https://i.loli.net/2019/09/26/zwETLdRG7giZoUh.png)

4. 实际项目的构建是复杂的，这样的复杂可以在架构上可以表现为:
    + 需要将一个大的项目分解成几个相对独立的子项目进行开发和测试，每个项目都会依赖相当数量的第三方库，有时候子项目的依赖是部分相同的。如果每个子项目都独立编写配置文件，则在最后代码合并过程中会大量编译重复依赖，效率低下，如果强行合并项目配置文件，由于依赖的复杂性，则会给项目整合带来困扰。

    + 如果采用统一的cmake文件来配置和管理第三方库，如果其中一个子项目因为需求变动对配置文件进行了修改，对于其他子项目的影响可能是灾难性的。

    为了解决上面复杂性带来的问题，easylib实现了第三方库之间和库和项目代码之间的解耦。库与库之间是相互独立的，库的增加、删除、修改并不会影响其他库。对于项目，easylib 通过提供一个叫做ELIB_WITH_\<LIBRARY NAME\>的bool变量来控制是否配置\<library name\>。对于项目来说 除了指定的库，其他库都是不存在的。即使其他库发生了增删和修改，也不会影响现有项目。

5. 为了方便项目的分解与合成，easylib把每个子项目也视作一个target，并且可以通过控制bool变量USE_\<project name\>\_AS_LIBRARY 控制子项目的角色。对于子项目依赖的合并只要将ELIB_WITH_\<LIBRARY NAME\> 合并即可。

## How to use easylib
Easylib由两部分组成，第一部分[easylib](https://github.com/swannyPeng/easylib.git)用于管理所有的第三方依赖，第二部分是一个使用easylib的项目代码用例[easylib-example-project](https://github.com/swannyPeng/easylib-example-project.git)。

在开始你的项目之前，你首先要下载这两部分
```shell
git clone https://github.com/swannyPeng/easylib.git
git clone https://github.com/swannyPeng/easylib-example-project.git
```

下载完成后，你可以使用Cmake命令行或者Cmake GUI对easylib-example-project进行配置和编译，但是需要指定easylib的根目录位置<EASYLIB_ROOT_DIR>

+ Cmake命令行
```bash
cd easylib-example-project
mkdir build
cd build
cmake .. -DEASYLIB_ROOT_DIR=<path>/easyib
make
```

+ Cmake GUI

1. 可以在配置之前通过add entry的方法添加 一条path路径

    Name: EASYLIB_ROOT_DIR

    Type: Path
    
    Value: \<path\>/easylib

2. 也可以直接configure，但是第一次会报错。然后你可以在EASYLIB_ROOT_DIR 的条目中填入 easylib 的根目录地址

到目前为止，你已经成功配置了一个easylib项目，但是现在这个项目还是空的，只有最基本的依赖Eigen。 为了能够调用easylib管理的第三方依赖，我们还需要修改easylib-example-project下的CMakelists.txt。

相较于之前的空项目，我们只要多写两行代码，就可以轻松添加一个第三方库，以添加ceres solver为例

1. 在 `include(easylib)` 之前设置
 ```cmake
 set(ELIB_WITH_CERES ON CACHE BOOL " " FORCE)
 ```
 这样easylib会为项目自动配置ceres

 2. 为\<project name\>_core 添加elib::ceres
 ```cmake
 target_link_libraries(${PROJECT_NAME}_core elib::core elib::ceres) #And any library you need in easylib
 ```
配置后的CMakeLists.txt如下所示

```cmake
##easylib-example-project/CMakelists.txt
cmake_minimum_required(VERSION 3.0)
project(example)
#Regrad the project as a library
set(USE_${PROJECT_NAME}_AS_LIBRARY FALSE)
##Find and include easylib
set(EASYLIB_ROOT_DIR "${EASYLIB_ROOT_DIR}" CACHE PATH "Easylib root directory" FORCE)

##options
set(ELIB_WITH_CERES ON CACHE BOOL " " FORCE)

if(NOT EASYLIB_ROOT_DIR)
    message(FATAL_ERROR "You have to specify easylib root directory before call it ...")
else(NOT EASYLIB_ROOT_DIR)
    list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR} ${EASYLIB_ROOT_DIR}/cmake)
    include(easylib)
endif(NOT EASYLIB_ROOT_DIR)

# Add a library <project name>
set(${PROJECT_NAME}_INCLUDE_DIR ${CMAKE_CURRENT_LIST_DIR}/include)
file(GLOB ${PROJECT_NAME}_SOURCE "${CMAKE_CURRENT_LIST_DIR}/src/*.cc" "${CMAKE_CURRENT_LIST_DIR}/src/*.cpp" "${CMAKE_CURRENT_LIST_DIR}/src/*.cxx")
add_library(${PROJECT_NAME}_core ${${PROJECT_NAME}_SOURCE})

target_include_directories(${PROJECT_NAME}_core PUBLIC ${${PROJECT_NAME}_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME}_core elib::core elib::ceres) #And any library you need in easylib
add_library(${PROJECT_NAME}::core ALIAS ${PROJECT_NAME}_core)

if(NOT USE_${PROJECT_NAME}_AS_LIBRARY)
    add_executable(${PROJECT_NAME}_bin main.cpp)
    target_link_libraries(${PROJECT_NAME}_bin ${PROJECT_NAME}::core)
endif()
```
再次编译之后，你就可以成功的在你的项目中使用Ceres solver 了

## Libraries supported by easylib

+ [Assimp(optional)](http://www.assimp.org)     [Windows,Linux]
+ [Ceres solver(optional)](http://www.ceres-solver.org/) [Windows,Linux]
+ [Eigen(default)](http://eigen.tuxfamily.org/index.php?title=Main_Page) [Windows,Linux]
+ [Gflags(optional)](https://gflags.github.io/gflags/) [Windows,Linux]
+ [Glad(optional)](https://glad.dav1d.de/) [Windows,Linux]
+ [Glfw(optional)](https://www.glfw.org/) [Windows,Linux]
+ [Imgui(optional)](https://github.com/ocornut/imgui) [Windows,Linux]
+ [Suitesaprse(optional)](http://faculty.cs.tamu.edu/davis/suitesparse.html) [Windows,Linux]
+ [Tetgen(optional)](http://www.wias-berlin.de/software/tetgen/) [Windows,Linux]

目前支持的库较少，后面会陆续补充常用的库

## How to add a library to easylib

目前easylib支持两种形式第三方库的添加：
+ 支持配置时自动从网上下载的第三方库，如tetgen, ceres;
+ 使用者预装好的第三方库，如boost, matlab；

对于不同类型的库，easylib将采用不同的策略来进行配置。

#### 1. 支持配置时自动从网上下载的第三方库
TODO
#### 2. 使用者预装好的第三方库
TODO





