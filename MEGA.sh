#!/bin/bash

cd /home/user/.MEGA

megals -R /Root/Public > mega.ls.tmp

scp -q mega.ls.tmp user@www.t-user.com:./www/crk

