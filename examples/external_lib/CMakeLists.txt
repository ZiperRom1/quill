project(quill_wrapper)

find_package(quill 2.7.0 REQUIRED CONFIG)

add_library(quill_wrapper_shared SHARED quill_wrapper.cpp)
add_library(quill_wrapper_static STATIC quill_wrapper.cpp)

target_include_directories(quill_wrapper_shared PUBLIC /"$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>")
target_include_directories(quill_wrapper_static PUBLIC /"$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>")

target_link_libraries(quill_wrapper_shared PRIVATE quill::quill)
target_link_libraries(quill_wrapper_static PRIVATE quill::quill)
