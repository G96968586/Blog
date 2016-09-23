#!/bin/bash
# desc: git add and commit to local storage

# commit message
comment=$*

if [ ! -n "$comment" ]; then
   git add . && git commit -m "update"
else
   git add . && git commit -m "$comment"
fi
