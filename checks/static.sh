#!/bin/bash

# This script generates production-ready files for the scripts and styles
# If files are changed then fails

# Exit on error
set -e

# Run npm run build
npm run ci:check:styles
npm run ci:check:scripts
