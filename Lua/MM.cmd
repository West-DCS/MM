@echo off
set mm_path=%~dp0..\
set mm_program=%mm_path%MM.lua
set lua_c_path=%~dp0
set lua_interpreter=%~dp0lua5.1.exe


"%lua_interpreter%" -e "package.cpath=package.cpath..';%lua_c_path%\\?.dll';" "%mm_program%" %*
@echo on