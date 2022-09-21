#!/bin/bash
go build ./src/client
go build ./src/server
go build ./src/proxy
mv proxy bin
mv client bin
mv server bin