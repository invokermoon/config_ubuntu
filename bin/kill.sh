#!/bin/bash
#
ps aux|grep emulator|awk '{print $2}'|xargs -i kill -9 {}
