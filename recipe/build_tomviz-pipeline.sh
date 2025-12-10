#!/bin/bash
set -ex

# Navigate to the Python package directory within the source
cd "${SRC_DIR}/tomviz/tomviz/python"

# Install the Python package using pip
${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
