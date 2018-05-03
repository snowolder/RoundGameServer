#!/bin/bash
ps ux |grep skynet |grep config |awk '{print $2}' |xargs kill -9
