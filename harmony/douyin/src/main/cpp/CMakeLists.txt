cmake_minimum_required(VERSION 3.13)
set(CMAKE_VERBOSE_MAKEFILE on)

set(rnoh_douyin_generated_dir "${CMAKE_CURRENT_SOURCE_DIR}/generated")
file(GLOB_RECURSE rnoh_douyin_generated_SRC "${rnoh_douyin_generated_dir}/*.cpp")
file(GLOB rnoh_douyin_SRC CONFIGURE_DEPENDS *.cpp)
add_library(rnoh_douyin SHARED ${rnoh_douyin_SRC} ${rnoh_douyin_generated_SRC})
target_include_directories(rnoh_douyin PUBLIC ${CMAKE_CURRENT_SOURCE_DIR} ${rnoh_douyin_generated_dir})
target_link_libraries(rnoh_douyin PUBLIC rnoh)