cmake_minimum_required(VERSION 3.16)
project(NewtonFractal LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)

# Find ISPC executable (must be on PATH or give absolute path)
find_program(ISPC_EXECUTABLE ispc REQUIRED)

# Sources
set(SRC main.cpp)

# Generated outputs directory
set(GEN_DIR ${CMAKE_CURRENT_BINARY_DIR}/generated)
file(MAKE_DIRECTORY ${GEN_DIR})

set(ISPC_SRC ${CMAKE_CURRENT_SOURCE_DIR}/newton.ispc)
if(MSVC)
    set(ISPC_OBJ ${GEN_DIR}/newton_ispc.obj)
else()
    set(ISPC_OBJ ${GEN_DIR}/newton_ispc.o)
endif()
set(ISPC_HDR ${GEN_DIR}/newton_ispc.h)

# Produce object and header from ISPC
add_custom_command(
        OUTPUT ${ISPC_OBJ} ${ISPC_HDR}
        COMMAND ${ISPC_EXECUTABLE} ${ISPC_SRC} -o ${ISPC_OBJ} -h ${ISPC_HDR}
        DEPENDS ${ISPC_SRC}
        BYPRODUCTS ${ISPC_OBJ} ${ISPC_HDR}
        COMMENT "Compiling ISPC kernel"
        VERBATIM
)

# Convenience target to ensure the generated files exist before linking
add_custom_target(ispc_generated_files DEPENDS ${ISPC_OBJ} ${ISPC_HDR})

# Create a static library target that wraps the generated object file so the linker will consume it
# Note: we list the generated object as a source; the custom command above makes sure it exists.
add_library(newton_ispc_lib STATIC ${ISPC_OBJ})
set_target_properties(newton_ispc_lib PROPERTIES LINKER_LANGUAGE CXX)

# Main executable
add_executable(newton ${SRC})

# Make generated header visible to the main target and include source dir for stb header
target_include_directories(newton PRIVATE ${GEN_DIR} ${CMAKE_CURRENT_SOURCE_DIR})

# Ensure build order
add_dependencies(newton ispc_generated_files)

# Link the ISPC static library into the executable
target_link_libraries(newton PRIVATE newton_ispc_lib)
