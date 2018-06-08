#!/usr/bin/env bash
date=$(date +'%Y%m%d_%H%M%S'); sqlite3 /Users/william/workspace/lsb/lsb_find/lsb_check.db ".backup '/Users/william/workspace/lsb/lsb_find/backup/lsb_check_$date.db'"
