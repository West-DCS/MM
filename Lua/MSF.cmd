@echo off
set msf_path=%~dp0..\
set msf_program=%msf_path%MSF.lua
set lua_c_path=%~dp0
set lua_interpreter=%~dp0lua5.1.exe


"%lua_interpreter%" -e "package.cpath=package.cpath..';%lua_c_path%\\?.dll';" "%msf_program%" %*
@echo on