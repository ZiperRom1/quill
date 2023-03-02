cmake_minimum_required(VERSION 3.22)
project(singleton_example)

find_package(quill REQUIRED)

add_subdirectory(external_lib)

add_executable(example_trivial_static example_trivial.cpp)
target_link_libraries(example_trivial_static PRIVATE quill_wrapper_static)

add_executable(example_trivial_shared example_trivial.cpp)
target_link_libraries(example_trivial_shared PRIVATE quill_wrapper_shared quill::quill)
