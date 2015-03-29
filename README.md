# Docker Exec Common Scripts [![Build Status](https://travis-ci.org/docker-exec/image-common.svg?branch=master)](https://travis-ci.org/docker-exec/image-common)

This repository contains the scripts used by Docker Exec containers to build and execute, or just execute the sources passed to them.

## Scripts

The ```dexec-c-family.sh```, ```dexec-mono-family.sh```, ```dexec-runtime.sh``` and ```dexec-script.sh``` files are used as entrypoints by the majority of Docker Exec containers. In turn they source common functionality from the file ```docker-common.sh```.

## Tests

A set of [bats](https://github.com/sstephenson/bats) tests is used to verify the ```docker-common.sh``` functionality.
