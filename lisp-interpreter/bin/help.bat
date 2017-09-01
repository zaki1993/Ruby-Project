@echo off &setlocal enabledelayedexpansion
for /f "command_list=" %%i in (commands) do set "target=!target! %%i"
start cmd /C "title Lisp functions & type commands & pause"