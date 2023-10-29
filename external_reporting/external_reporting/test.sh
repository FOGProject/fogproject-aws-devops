#!/bin/bash

curl -X POST -H "Content-Type: application/json"  -d '{"fog_version":"testing","os_name":"testing","os_version":"testing"}' https://fog-external-reporting-entries.fogproject.us:/api/records



curl -X POST -H "Content-Type: application/json"  -d '{"fog_version":"1.5.9.139","os_name":"Debian","os_version":"11","kernel_versions_info":["bzImage32 5.15.19 (buildkite-agent@Tollana) #1 SMP Thu Feb 3 15:05:47 CST 2022","bzImage 5.15.19 (buildkite-agent@Tollana) #1 SMP Thu Feb 3 15:10:05 CST 2022","arm_Image_test little-endian","another_test_kernel 4.19.145 (sebastian@Tollana) #1 SMP Sun Sep 13 05:43:10 CDT 2020"]}' https://fog-external-reporting-entries.fogproject.us:/api/records



mysql -u root -D external_reporting -e "delete from versions_out_there where os_name = 'testing';"
