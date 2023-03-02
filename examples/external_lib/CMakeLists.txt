project(quill_wrapper)

find_package(quill REQUIRED)

add_library(quill_wrapper_shared SHARED quill_wrapper.cpp)
add_library(quill_wrapper_static STATIC quill_wrapper.cpp)

target_link_libraries(quill_wrapper_shared PRIVATE quill::quill)
target_link_libraries(quill_wrapper_static PRIVATE quill::quill)
