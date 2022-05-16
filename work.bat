@echo off

REM SET PAGENT="C:\Program Files\PuTTY\pageant.exe"
REM SET PAGENT_ID="C:\Users\bwhitlock\Documents\Security\ssh\bradl-laptop.ppk"

REM SET PUTTY="c:\Program Files\PuTTY\putty.exe"
REM SET PUTTY_SESSION="plap"
REM SET PUTTY_SESSION1="dkr_via_plap_2022"

REM START "" "C:\Program Files (x86)\Emacs\i686\bin\runemacs.exe" -f pstart

REM START /MIN "" %PUTTY% -load %PUTTY_SESSION%
REM START /MAX "" %PUTTY% -load %PUTTY_SESSION1%

START "Work Script" /MAX "C:\Strawberry\perl\bin\perl.exe" work.pl
