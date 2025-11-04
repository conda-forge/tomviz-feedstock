:: remove -GL from CXXFLAGS
set "CXXFLAGS=-MD"

:: Update submodules
cd tomviz
git submodule update --init --recursive
cd ..

:: Build Tomviz
mkdir tomviz-build && cd tomviz-build
cmake -G"Ninja" -DCMAKE_BUILD_TYPE=RelWithDebInfo ^
  -DCMAKE_INSTALL_PREFIX:PATH="%PREFIX%" ^
  -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
  -DCMAKE_INSTALL_LIBDIR:PATH="Library/lib" ^
  -DCMAKE_INSTALL_BINDIR:PATH="Library/bin" ^
  -DCMAKE_INSTALL_INCLUDEDIR:PATH="Library/include" ^
  -DCMAKE_INSTALL_DATAROOTDIR:PATH="Library/share" ^
  -DTOMVIZ_USE_EXTERNAL_VTK:BOOL=ON ^
  -DENABLE_TESTING:BOOL=OFF ^
  -DPython3_FIND_STRATEGY:STRING=LOCATION ^
  -DPython3_ROOT_DIR:PATH="%PREFIX%" ^
  ..\tomviz
if errorlevel 1 exit 1

cmake --build . --target install --config Release --parallel %CPU_COUNT%
if errorlevel 1 exit 1
