#! /usr/bin/env python3

from invoke import task


CC = "gcc"

@task
def clean(c):
    c.run("rm bfilter.so")

@task
def fnv(c):
    c.run("cd libfnv && ./configure && make")

@task
def build(c):
    fnv(c)
    c.run("%s -g -DLIB -c -fpic -Wall -Wextra -pedantic -Wpointer-arith -std=c99 -I ./libfnv/libfnv/include -lfnv -lm -L. -O3 ./bfilter.c -Wl,-rpath./;" % CC)
    c.run("%s -shared -o bfilter.so bfilter.o;" % CC)
