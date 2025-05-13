#!/bin/bash
count=1; 
for dir in */; do
    mv $dir "$count - $dir";
    (( count++  ))
done
