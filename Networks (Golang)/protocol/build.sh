#!/bin/bash
go build ./src/client/client.go
go build ./src/server/server.go
mv client bin
mv server bin
