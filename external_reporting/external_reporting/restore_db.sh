#!/bin/bash


aws s3 cp s3://fog-external-reporting-results.fogproject.us/db.tar.gz .
tar -xf db.tar.gz
mysql -D external_reporting < db.sql
