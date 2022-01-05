
#!/bin/sh

# https://gitlab.kitware.com/paraview/paraview/issues/19645
export LDFLAGS=`echo "${LDFLAGS}" | sed "s|-Wl,-dead_strip_dylibs||g"`

# First build ParaView
mkdir -p paraview-build && cd paraview-build
cmake -G"Ninja" -DCMAKE_BUILD_TYPE:STRING=Release \
  -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} \
  -DCMAKE_PREFIX_PATH:PATH=${PREFIX} \
  -DCMAKE_INSTALL_RPATH:STRING=${PREFIX}/lib \
  -DCMAKE_INSTALL_LIBDIR:STRING=lib \
  -DCMAKE_FIND_FRAMEWORK:STRING=LAST \
  -DBUILD_TESTING:BOOL=OFF \
  -DPython3_FIND_STRATEGY:STRING=LOCATION \
  -DPython3_ROOT_DIR:PATH=${PREFIX} \
  -DPARAVIEW_ENABLE_CATALYST:BOOL=OFF \
  -DPARAVIEW_ENABLE_PYTHON:BOOL=ON \
  -DPARAVIEW_ENABLE_WEB:BOOL=OFF \
  -DPARAVIEW_ENABLE_EMBEDDED_DOCUMENTATION:BOOL=OFF\
  -DPARAVIEW_USE_QTHELP:BOOL=OFF \
  -DPARAVIEW_PLUGINS_DEFAULT:BOOL=OFF \
  -DPARAVIEW_CUSTOM_LIBRARY_SUFFIX:STRING=tpv5.7 \
  -DPARAVIEW_USE_VTKM:BOOL=OFF \
  -DVTK_SMP_IMPLEMENTATION_TYPE:STRING=TBB \
  -DVTK_PYTHON_VERSION:STRING=3 \
  -DVTK_PYTHON_FULL_THREADSAFE:BOOL=ON \
  -DVTK_NO_PYTHON_THREADS:BOOL=OFF \
  -DVTK_MODULE_USE_EXTERNAL_VTK_hdf5:BOOL=ON \
  ../paraview
ninja install -j${CPU_COUNT}

# Now build Tomviz
cd .. && mkdir -p tomviz-build && cd tomviz-build
cmake -G"Ninja" -DCMAKE_BUILD_TYPE:STRING=Release \
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


# Install itk-elastix. We'll include it in our package since it is not
# available on conda-forge.
# The latest ITK on conda-forge is 5.1.2, so install the latest
# itk-elastix that uses ITK 5.1.2, which is 0.9.0.
if [ `uname` == Darwin ]; then
  ITK_ELASTIX_WHL_URL=https://files.pythonhosted.org/packages/46/a1/24311db277ce6432ac2c799fe77a01c5151a5b4376f15d088b7c265cc36f/itk_elastix-0.9.0-cp37-cp37m-macosx_10_9_x86_64.whl
elif [ `uname` == Linux ]; then
  ITK_ELASTIX_WHL_URL=https://files.pythonhosted.org/packages/48/a2/c93146a9f7c60026323b668dd0b12546afdff77f1dc14ecd75e0bbd95bb8/itk_elastix-0.9.0-cp37-cp37m-manylinux1_x86_64.whl
fi

pip install --no-deps $ITK_ELASTIX_WHL_URL
