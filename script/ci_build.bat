chcp 65001
@echo off
xsct .\script\ci_build.tcl %*
#xsct ci_build.tcl %* > a.log 2>&1