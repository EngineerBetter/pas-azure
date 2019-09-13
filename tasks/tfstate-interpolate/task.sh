#!/usr/bin/env bash

# Based on Simon O'Brien's work at https://github.com/ob1-sc/pcf-aws-automation

if [ "$VERBOSE" ]; then
  set -o xtrace
fi

set -o errexit
set -o nounset
set -o pipefail

# setup texplate
texplate_bin=$(ls ./texplate/texplate*)
chmod +x $texplate_bin

# setup jq
jq_bin=$(ls ./jq/jq*)
chmod +x $jq_bin

# get all the files to interpolate
files=$(cd files && find $INTERPOLATION_PATHS -type f -name '*.yml' -follow)

cp -r files/* interpolated-files/

for file in $files; do
  echo "interpolating files/$file"
  $texplate_bin execute files/"$file" -f <($jq_bin -e --raw-output '.modules[0].outputs | map_values(.value)' ./tf_state/terraform.tfstate) -o yaml > interpolated-files/"$file"
done
