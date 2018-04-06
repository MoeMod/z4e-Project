@echo off
set WADROOT=D:\games\counter-strike 1.6\cstrike
set mapname=ze_canning.map

hlcsg.exe -nowadtextures -texdata 5000 -estimate "%mapname%"
hlbsp.exe -texdata 5000 -estimate -subdivide 240 "%mapname%"
hlvis.exe -texdata 5000 -estimate -full "%mapname%"
hlrad.exe -texdata 5000 -estimate -extra -dscale 1 -bounce 8 -smooth 40 -chop 64 -texchop 32 -notexscale "%mapname%" 