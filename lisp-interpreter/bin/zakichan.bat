@echo off
start cmd /C "title lisp-interpreter & ruby ../lib/lisp/interpreter/run.rb' 2> log & echo Error occured. & timeout 2 > NUL & echo Logging into file 'log'. & timeout 2 > NUL & pause"