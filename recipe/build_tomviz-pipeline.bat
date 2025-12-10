@echo off
REM Build script for tomviz-pipeline package (Windows)

REM Navigate to the Python package directory
cd "%SRC_DIR%\tomviz\tomviz\python"
if errorlevel 1 exit 1

REM Install the Python package using pip
"%PYTHON%" -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1
