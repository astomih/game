cmake_minimum_required(VERSION 3.7)
project(sinen_app)
file(GLOB SOURCE_FILES src/*/*.cpp src/*.cpp)
file(GLOB INCLUDE_DIRS external/sinen/include external/sinen/include/sinen)
if(ANDROID)
  set(CMAKE_CXX_FLAGS "-std=c++20")
  add_library(main STATIC ${SOURCE_FILES})
  find_library(nen nen)
  target_link_libraries(main nen)
  target_include_directories(main PUBLIC ${INCLUDE_DIRS})
elseif(EMSCRIPTEN)
  add_subdirectory(./external/sinen)
  set(CMAKE_C_COMPILER "emcc")
  add_executable(index ${SOURCE_FILES})
  target_link_directories(index PUBLIC .)
  target_link_libraries(index nen)
  target_include_directories(index PUBLIC ${INCLUDE_DIRS})
  set(CMAKE_CXX_FLAGS
      "${CMAKE_CXX_FLAGS} \
    -O2 \
		-Wno-unused-command-line-argument \
		-s USE_SDL=2 \
		-s USE_SDL_IMAGE=2 \
		-s USE_WEBGL2=1 \
		-s FULL_ES3=1 \
		-s MIN_WEBGL_VERSION=2 \
		-s MAX_WEBGL_VERSION=2 \
		-s SDL2_IMAGE_FORMATS='[\"png\"]' \
		-s USE_SDL_TTF=2 \
		-s USE_SDL_MIXER=2 \
		-s USE_SDL_NET=2 \
		--preload-file=data \
		-s ALLOW_MEMORY_GROWTH \
		--shell-file shell_minimum.html \
		-std=c++20")
  set(CMAKE_EXECUTABLE_SUFFIX ".html")
else()
  set(CMAKE_CXX_FLAGS "-O2 -march=native")
  set(CMAKE_EXPORT_COMPILE_COMMANDS true)

  find_package(Vulkan REQUIRED)
  find_package(OpenGL REQUIRED)
  find_package(GLEW REQUIRED)
  find_package(SDL2 REQUIRED)
  find_package(OpenAL REQUIRED)
  if(WIN32)
    set(LIBRARIES
        nen
        ${Vulkan_LIBRARIES}
        SDL2
        SDL2main
        SDL2_image
        SDL2_mixer
        SDL2_ttf
        SDL2_net
        openal
        glew32
        opengl32)
  else()
    set(LIBRARIES
        nen
        ${Vulkan_LIBRARIES}
        SDL2
        SDL2main
        SDL2_image
        SDL2_mixer
        SDL2_ttf
        SDL2_net
        openal
        GLEW
        GL
        ${CMAKE_DL_LIBS})
  endif(WIN32)
  add_subdirectory(./external/sinen)

  add_executable(sinen_app ${SOURCE_FILES})
  target_compile_features(sinen_app PUBLIC cxx_std_20)
  target_include_directories(sinen_app PUBLIC ${INCLUDE_DIRS})
  target_link_libraries(sinen_app ${LIBRARIES})
endif()
