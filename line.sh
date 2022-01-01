#!/bin/sh

ACCESS_TOKEN=22a5rDpEZa1qp3Ckrr1CZErRkGHgUM2ZXX7NNgcQYnr
MSG=$1

curl -s -X POST -H "Authorization: Bearer $ACCESS_TOKEN" -F "message=$MSG" https://notify-api.line.me/api/notify >/dev/null
