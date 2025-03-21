#!/bin/bash

copyq eval -- "tab('&clipboard'); for(i=size(); i>0; --i) print(str(read(i-1)) + '\n');" | tac | awk NF | wofi -d
