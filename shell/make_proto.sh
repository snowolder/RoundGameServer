#!/bin/bash
python ./shell/format_proto.py
protoc -I=./proto/ -o./proto/proto.pb `find ./ -name '*.proto'`
