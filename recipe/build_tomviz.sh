#!/bin/sh

# https://gitlab.kitware.com/paraview/paraview/issues/19645
export LDFLAGS=`echo "${LDFLAGS}" | sed "s|-Wl,-dead_strip_dylibs||g"`

# https://conda-forge.org/docs/maintainer/knowledge_base/#newer-c-features-with-old-sdk
# This fixes an error we encountered compiling ParaView on macos
export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

# Update submodules
cd tomviz
git submodule update --init --recursive

# Build against a newer pybind11 than the submodule pins (v3.0.0, tagged
# 2025-07-10). v3.0.0 predates Python 3.14.0 final and carries no 3.14 code
# paths, and v3.0.2 fixed undefined behaviour when an embedded interpreter
# imports modules from a non-main thread, which is what tomviz does on its
# ThreadedExecutor worker. Drop this once the tomviz submodule is bumped.
PYBIND11_VERSION=v3.0.4
(
  cd thirdparty/pybind11
  # A full submodule clone already has the tags; fetch only if it doesn't.
  git checkout "${PYBIND11_VERSION}" 2>/dev/null || {
    git fetch --tags https://github.com/pybind/pybind11.git
    git checkout "${PYBIND11_VERSION}"
  }
  git --no-pager log -1 --format="pybind11 pinned to %H (%d)"
)
cd ..

# FIXME: setting the zlib paths manually shouldn't be necessary forever.
# Try removing it sometime.
ZLIB_ARGS=""
PLATFORM_ARGS=""
if [ "$(uname)" = "Linux" ]; then
  ZLIB_ARGS="-DZLIB_LIBRARY=${PREFIX}/lib/libz.so.1 -DZLIB_INCLUDE_DIR=${PREFIX}/include"
elif [ "$(uname)" = "Darwin" ]; then
  ZLIB_ARGS="-DZLIB_LIBRARY=${PREFIX}/lib/libz.dylib -DZLIB_INCLUDE_DIR=${PREFIX}/include"
  PLATFORM_ARGS="-DTOMVIZ_MACOSX_BUNDLE=OFF"
fi

# Build Tomviz
mkdir -p tomviz-build && cd tomviz-build
cmake -G"Ninja" -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo \
  -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} \
  -DCMAKE_PREFIX_PATH:PATH=${PREFIX} \
  -DCMAKE_INSTALL_LIBDIR:STRING=lib \
  -DCMAKE_INSTALL_RPATH:STRING=${PREFIX}/lib \
  -DTOMVIZ_USE_EXTERNAL_VTK:BOOL=ON \
  -DENABLE_TESTING:BOOL=OFF \
  -DTOMVIZ_GIT_DESCRIBE:STRING=${PKG_VERSION} \
  -DPython3_FIND_STRATEGY:STRING=LOCATION \
  -DPython3_ROOT_DIR:PATH=${PREFIX} \
  ${ZLIB_ARGS} \
  ${PLATFORM_ARGS} \
  ../tomviz
ninja install -j${CPU_COUNT}
