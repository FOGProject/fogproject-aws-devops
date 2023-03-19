#!/bin/bash

count=$(aws s3 ls provisioning-us-east-1-158698670377 | wc -l)

echo "expecting 13, got ${count}"
