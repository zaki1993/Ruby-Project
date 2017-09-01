@echo off

call rake spec > log 2> NUL
if %ERRORLEVEL% == 0 goto :run
echo Could not start the application.
echo Please check the log file.
goto :end

:run
start cmd /C "title lisp-interpreter & ruby ../lib/lisp/interpreter/run.rb' 2> log & echo Error occured. & timeout 2 > NUL & echo Logging into file 'log'. & timeout 2 > NUL & pause"
goto: end

:end
