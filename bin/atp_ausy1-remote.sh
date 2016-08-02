#!/bin/sh

BOARD_1_ID=FTYLKXDM
LABPC=10.102.243.216

scp out/current/firmware/* lab@$LABPC:/home/lab/board/board1/out/current/firmware/
ssh lab@$LABPC 'cd /home/lab/board/board1/thunderdome/tools/openocd/scripts/ && ./devboard.sh -all $BOARD_1_ID'

