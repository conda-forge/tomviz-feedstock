:: remove -GL from CXXFLAGS
set "CXXFLAGS=-MD"

:: Update submodules
cd tomviz
git submodule update --init --recursive
if errorlevel 1 exit 1

:: Build against a newer pybind11 than the submodule pins. See
:: build_tomviz.sh for the rationale. Drop once the submodule is bumped.
set "PYBIND11_VERSION=v3.0.4"
cd thirdparty\pybind11
git checkout %PYBIND11_VERSION%
if errorlevel 1 (
  git fetch --tags https://github.com/pybind/pybind11.git
  if errorlevel 1 exit 1
  git checkout %PYBIND11_VERSION%
  if errorlevel 1 exit 1
)
git --no-pager log -1 --format="pybind11 pinned to %%H"
cd ..\..

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
  -DTOMVIZ_GIT_DESCRIBE:STRING=%PKG_VERSION% ^
  -DPython3_FIND_STRATEGY:STRING=LOCATION ^
  -DPython3_ROOT_DIR:PATH="%PREFIX%" ^
  -DZLIB_LIBRARY:FILEPATH="%LIBRARY_PREFIX%\lib\zlib.lib" ^
  -DZLIB_INCLUDE_DIR:PATH="%LIBRARY_PREFIX%\include" ^
  ..\tomviz
if errorlevel 1 exit 1

cmake --build . --target install --config Release --parallel %CPU_COUNT%
if errorlevel 1 exit 1

:: Install PDB debug symbols alongside binaries for post-mortem debugging
for /R . %%f in (*.pdb) do copy /Y "%%f" "%LIBRARY_BIN%\" 2>nul
