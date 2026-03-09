#!/bin/sh

# https://gitlab.kitware.com/paraview/paraview/issues/19645
export LDFLAGS=`echo "${LDFLAGS}" | sed "s|-Wl,-dead_strip_dylibs||g"`

# https://conda-forge.org/docs/maintainer/knowledge_base/#newer-c-features-with-old-sdk
# This fixes an error we encountered compiling ParaView on macos
export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

# Update submodules
cd tomviz
git submodule update --init --recursive
cd ..

# FIXME: setting the zlib paths manually shouldn't be necessary forever.
# Try removing it sometime.
ZLIB_ARGS=""
if [ "$(uname)" = "Linux" ]; then
  ZLIB_ARGS="-DZLIB_LIBRARY=${PREFIX}/lib/libz.so.1 -DZLIB_INCLUDE_DIR=${PREFIX}/include"
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
  -DPython3_FIND_STRATEGY:STRING=LOCATION \
  -DPython3_ROOT_DIR:PATH=${PREFIX} \
  ${ZLIB_ARGS} \
  ../tomviz
ninja install -j${CPU_COUNT}
