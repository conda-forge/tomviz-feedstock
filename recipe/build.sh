
#!/bin/sh

# https://gitlab.kitware.com/paraview/paraview/issues/19645
export LDFLAGS=`echo "${LDFLAGS}" | sed "s|-Wl,-dead_strip_dylibs||g"`

# Update submodules
cd tomviz;git submodule update --init --recursive
cd ..
cd paraview;git submodule update --init --recursive
cd ..

# First build ParaView
mkdir -p paraview-build && cd paraview-build
cmake -G"Ninja" -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo \
  -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} \
  -DCMAKE_PREFIX_PATH:PATH=${PREFIX} \
  -DCMAKE_INSTALL_RPATH:STRING=${PREFIX}/lib \
  -DCMAKE_INSTALL_LIBDIR:STRING=lib \
  -DCMAKE_FIND_FRAMEWORK:STRING=LAST \
  -DBUILD_TESTING:BOOL=OFF \
  -DPython3_FIND_STRATEGY:STRING=LOCATION \
  -DPython3_ROOT_DIR:PATH=${PREFIX} \
  -DPARAVIEW_ENABLE_CATALYST:BOOL=OFF \
  -DPARAVIEW_USE_PYTHON:BOOL=ON \
  -DPARAVIEW_ENABLE_WEB:BOOL=OFF \
  -DPARAVIEW_ENABLE_EMBEDDED_DOCUMENTATION:BOOL=OFF\
  -DPARAVIEW_USE_QTHELP:BOOL=OFF \
  -DPARAVIEW_PLUGINS_DEFAULT:BOOL=OFF \
  -DPARAVIEW_USE_VISKORES:BOOL=OFF \
  -DVTK_SMP_IMPLEMENTATION_TYPE:STRING=TBB \
  -DVTK_PYTHON_VERSION:STRING=3 \
  -DVTK_PYTHON_FULL_THREADSAFE:BOOL=ON \
  -DVTK_NO_PYTHON_THREADS:BOOL=OFF \
  ../paraview
ninja install -j${CPU_COUNT}

# Now build Tomviz
cd .. && mkdir -p tomviz-build && cd tomviz-build
cmake -G"Ninja" -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo \
  -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} \
  -DCMAKE_PREFIX_PATH:PATH=${PREFIX} \
  -DCMAKE_INSTALL_LIBDIR:STRING=lib \
  -DCMAKE_INSTALL_RPATH:STRING=${PREFIX}/lib \
  -DParaView_DIR:PATH=${SRC_DIR}/paraview-build \
  -DBUILD_TESTING:BOOL=OFF \
  -DPython3_FIND_STRATEGY:STRING=LOCATION \
  -DPython3_ROOT_DIR:PATH=${PREFIX} \
  ../tomviz
ninja install -j${CPU_COUNT}
