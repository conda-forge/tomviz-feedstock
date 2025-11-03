:: remove -GL from CXXFLAGS
set "CXXFLAGS=-MD"

:: Update submodules
cd paraview
git submodule update --init --recursive
cd ..

cd tomviz
git submodule update --init --recursive
cd ..

:: Build ParaView first
mkdir paraview-build && cd paraview-build
cmake -LAH -G"Ninja" ^
    -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo ^
    -DCMAKE_INSTALL_PREFIX:PATH="%PREFIX%" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_LIBDIR:PATH="Library/lib" ^
    -DCMAKE_INSTALL_BINDIR:PATH="Library/bin" ^
    -DCMAKE_INSTALL_INCLUDEDIR:PATH="Library/include" ^
    -DCMAKE_INSTALL_DATAROOTDIR:PATH="Library/share" ^
    -DPython3_FIND_STRATEGY:STRING=LOCATION ^
    -DPython3_ROOT_DIR:PATH="%PREFIX%" ^
    -DPARAVIEW_PYTHON_SITE_PACKAGES_SUFFIX:PATH="Lib/site-packages" ^
    -DPARAVIEW_ENABLE_CATALYST:BOOL=OFF  ^
    -DPARAVIEW_USE_PYTHON:BOOL=ON  ^
    -DPARAVIEW_BUILD_WITH_EXTERNAL:BOOL=ON ^
    -DPARAVIEW_USE_EXTERNAL_VTK:BOOL=ON ^
    -DPARAVIEW_ENABLE_WEB:BOOL=OFF  ^
    -DPARAVIEW_ENABLE_EMBEDDED_DOCUMENTATION:BOOL=OFF  ^
    -DPARAVIEW_USE_QTHELP:BOOL=OFF  ^
    -DPARAVIEW_PLUGINS_DEFAULT:BOOL=OFF  ^
    -DPARAVIEW_USE_VISKORES:BOOL=OFF  ^
    ..\paraview
if errorlevel 1 exit 1

cmake --build . --target install --config RelWithDebInfo --parallel %CPU_COUNT%
if errorlevel 1 exit 1

:: Now Tomviz
cd .. && mkdir tomviz-build && cd tomviz-build
cmake -G"Ninja" -DCMAKE_BUILD_TYPE=RelWithDebInfo ^
  -DCMAKE_INSTALL_PREFIX:PATH="%PREFIX%" ^
  -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
  -DCMAKE_INSTALL_LIBDIR:PATH="Library/lib" ^
  -DCMAKE_INSTALL_BINDIR:PATH="Library/bin" ^
  -DCMAKE_INSTALL_INCLUDEDIR:PATH="Library/include" ^
  -DCMAKE_INSTALL_DATAROOTDIR:PATH="Library/share" ^
  -DParaView_DIR:PATH="%SRC_DIR%/paraview-build" ^
  -DTOMVIZ_USE_EXTERNAL_VTK:BOOL=ON ^
  -DENABLE_TESTING:BOOL=OFF ^
  -DPython3_FIND_STRATEGY:STRING=LOCATION ^
  -DPython3_ROOT_DIR:PATH="%PREFIX%" ^
  ..\tomviz
if errorlevel 1 exit 1

cmake --build . --target install --config Release --parallel %CPU_COUNT%
if errorlevel 1 exit 1
