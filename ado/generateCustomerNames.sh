#!/bin/bash
set -e

while getopts "c:" flag; do
  case "${flag}" in
    c) customerEnvironmentDirectory=${OPTARG};;
  esac
done

for customerName in "$customerEnvironmentDirectory"/*.yml; do
done

echo "##vso[task.setvariable variable=customerNames;isOutput=true]$customerNames"