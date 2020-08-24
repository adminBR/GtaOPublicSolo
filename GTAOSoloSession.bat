@echo off
SETLOCAL EnableDelayedExpansion
set RULE_NAME="GTAPublicBlock"
set newIp=
set id=0
set whitelistk= 

:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"


if EXIST "Whitelist.txt" (
	set /p id=<Whitelist.txt
	goto WLFILTER
)
:menu
if EXIST "Whitelist.txt" (
	set /p id=<Whitelist.txt
)
cls
echo           [7mGTA Online Public Session Locker[0m 
echo.
echo [7m                [0m FIREWALL RULE INFO [7m                [0m
echo.
echo * Rule Name:           %RULE_NAME%
echo * Blocked Ports:       6672,61455,61457,61456,61458
if not "!whitelistk!"==" " (
	echo * Whitelist active:   [92mYES[0m
) else (
	echo * Whitelist active:    [91mNO[0m
)
echo * WhiteList IPs:       %id%

netsh advfirewall firewall show rule name=%RULE_NAME% >nul
if ERRORLEVEL 1 (
	echo * Connection Status:   [91mNORMAL[0m
) else (
	echo * Connection Status:   [92mBLOCKED[0m
)
echo.
echo.
echo Options:
echo =--------------------------------------------------=
echo  1) Enable connection block
echo  2) Disable connection block
echo  3) Enable whitelist
echo  4) Disable whitelist
echo  5) Edit whitelist
echo.
echo =--------------------------------------------------=
set choice=
set /p choice="Please enter a number: (1-5) "
if "!choice!"=="1" goto LABEL-1
if "!choice!"=="2" goto LABEL-2
if "!choice!"=="3" goto LABEL-3
if "!choice!"=="4" goto LABEL-4
if "!choice!"=="5" goto LABEL-5

goto menu

choice /n /c:12345 /M "Type option: (1-5) "
GOTO LABEL-%ERRORLEVEL%

:LABEL-1 
	netsh advfirewall firewall show rule name=%RULE_NAME% >nul
	if not ERRORLEVEL 1 (
		goto menu
	) else (
		if not "!whitelistk!"==" " (
		echo !whitelistk!
			netsh advfirewall firewall add rule name=%RULE_NAME% dir=out action=block enable=yes remoteip=!whitelistk! protocol=UDP remoteport=6672,61455,61457,61456,61458
		) else (
			netsh advfirewall firewall add rule name=%RULE_NAME% dir=out action=block enable=yes protocol=UDP remoteport=6672,61455,61457,61456,61458 >nul
		)
		netsh advfirewall firewall show rule name=%RULE_NAME% >nul
		if ERRORLEVEL 1 (
			echo The firewall rule could not be created!
			pause
		)
		cls
		goto menu
	)
:LABEL-2 
	netsh advfirewall firewall delete rule name=%RULE_NAME% >nul
	netsh advfirewall firewall show rule name=%RULE_NAME% >nul
	if not ERRORLEVEL 1 (
		echo The firewall rule could not be removed!
		pause
	)
	cls
	goto menu
	
:LABEL-3 
	if "%id%"=="0" (
		set /p choice="Whitelist empty, create a new one? [y,n] "
		if "!choice!"=="y" (
			set id=0
			goto WLCreate1
		)
		if "!choice!"=="n" (
			goto menu
		)
	) else (
		set whitelistk=!newIp!
		netsh advfirewall firewall show rule name=%RULE_NAME% >nul
		if not ERRORLEVEL 1 (
			netsh advfirewall firewall set rule name=%RULE_NAME% new remoteip=!whitelistk!
		) else (
			goto menu
		)
		
	)
	goto menu
	
:LABEL-4 
	set whitelistk= 
	netsh advfirewall firewall show rule name=%RULE_NAME% >nul
	if not ERRORLEVEL 1 (
		netsh advfirewall firewall set rule name=%RULE_NAME% new remoteip=!whitelistk!
	) else (
		goto menu
	)
	goto menu
	
:LABEL-5 
	if "%id%"=="0" (
		set /p choice="Whitelist Not found! want to create? [y,n] "
		if "!choice!"=="y" (
			set id=0
			goto WLCreate1
		)
		if "!choice!"=="n" (
			goto menu
		)
	) else (
		goto WLCreate
	)
	
:WLCreate 
	cls
	echo [7m                    Whitelist Creator                    [0m 
	echo.
	echo    you can create a new list here,
	echo    or edit the Whitelist.txt file in the root folder.
	echo =------------------------------------------------------=
	echo.
	echo ips: %id%
	echo.
	set /p choice="Create new Whitelist? [y,n] "
		if "!choice!"=="y" (
			cls
			set id=0
			goto WLCreate1
		)
		if "!choice!"=="n" (
			goto menu
		)
	goto menu
	
:WLCreate1 
	cls
	echo [7m                    Whitelist Creator                    [0m 
	echo.
	echo    you can create a new list here,
	echo    or edit the Whitelist.txt file in the root folder.
	echo =------------------------------------------------------=
	echo.
	echo ips: !id!
	echo.
	if "%id%"=="0" (
		set /p id="Enter new IP: "
	) else (
		set /p ip="Enter new IP: "
		set temp=!id!
		set id=!id! !ip!
	)
	set /p choice="Want to add another ip? [y,n] "
	if "!choice!"=="y" (
		cls
		goto WLCreate1
	)
	if "!choice!"=="n" (
		break>Whitelist.txt
		echo !id! >> Whitelist.txt
		echo Whitelist created!
		goto WLFILTER
		
	)
	goto menu
	
:WLFILTER 

set newIp=0
set s=!id!
set t=%s%
:loopGetFS
set ips=
set ip1=
for /f "tokens=1*" %%a in ("%t%") do (
	set ips=%%a
	)

:loopSetIp12
for /f "tokens=1*" %%a in ("%t%") do (
	set ip1=%%a
	set t=%%b
	)
set ipsP=
set ip1P=
set ip12=!ip1!
set ips2=!ips!

:loopgetipP
for /f "tokens=1* delims=." %%a in ("%ip12%") do (
	set ip1P=%%a
	set ip12=%%b
	)
for /f "tokens=1* delims=." %%a in ("%ips2%") do (
	set ipsP=%%a
	set ips2=%%b
	)
if !ipsP! gtr !ip1P! (
	set ips=!ip1!
)
if !ip1P! equ !ipsP! (
	if defined ip12 goto loopgetipP
)
if defined t goto loopSetIp12

if "!newIp!"=="0" (
	set pip1=
	set pip2=
	set pip3=
	set pip4=
	set tempips=!ips! 
	for /f "tokens=1* delims=." %%a in ("!tempips!") do (
	set pip1=%%a
	set tempips=%%b
	)
	for /f "tokens=1* delims=." %%a in ("!tempips!") do (
	set pip2=%%a
	set tempips=%%b
	)
	for /f "tokens=1* delims=." %%a in ("!tempips!") do (
	set pip3=%%a
	set pip4=%%b
	)
	set /a "pip41=!pip4!-1"
	if 0 gtr !pip41! (
		set pip4=0
		set /a "pip31=!pip3!-1"
		if 0 gtr !pip31! (
			set pip3=0
			set /a "pip21=!pip2!-1"
			if 0 gtr !pip21! (
				set pip2=0
				set /a "pip11=!pip1!-1"
				if 0 gtr !pip11! (
					set pip1=0
				) else (
					set pip1=!pip11!
				)
			) else (
				set pip2=!pip21!
			)
		) else (
			set pip3=!pip31!
		)
	) else (
		set pip4=!pip41!
	)
	set ipm=!pip1!.!pip2!.!pip3!.!pip4!
	set tempips=!ips! 
	for /f "tokens=1* delims=." %%a in ("!tempips!") do (
	set pip1=%%a
	set tempips=%%b
	)
	for /f "tokens=1* delims=." %%a in ("!tempips!") do (
	set pip2=%%a
	set tempips=%%b
	)
	for /f "tokens=1* delims=." %%a in ("!tempips!") do (
	set pip3=%%a
	set pip4=%%b
	)
	set /a "pip41=!pip4!+1"
	if !pip41! gtr 255 (
		set pip4=0
		set /a "pip31=!pip3!+1"
		if !pip31! gtr 255 (
			set pip3=0
			set /a "pip21=!pip2!+1"
			if !pip21! gtr 255 (
				set pip2=0
				set /a "pip11=!pip1!+1"
				if !pip11! gtr 255 (
					set pip1=0
				) else (
					set pip1=!pip11!
				)
			) else (
				set pip2=!pip21!
			)
		) else (
			set pip3=!pip31!
		)
	) else (
		set pip4=!pip41!
	)
	set newIp=0.0.0.0-!ipm!,!pip1!.!pip2!.!pip3!.!pip4!
) else (
	set pip1=
	set pip2=
	set pip3=
	set pip4=
	set tempips=!ips! 
	for /f "tokens=1* delims=." %%a in ("!tempips!") do (
	set pip1=%%a
	set tempips=%%b
	)
	for /f "tokens=1* delims=." %%a in ("!tempips!") do (
	set pip2=%%a
	set tempips=%%b
	)
	for /f "tokens=1* delims=." %%a in ("!tempips!") do (
	set pip3=%%a
	set pip4=%%b
	)
	set /a "pip41=!pip4!-1"
	if 0 gtr !pip41! (
		set pip4=0
		set /a "pip31=!pip3!-1"
		if 0 gtr !pip31! (
			set pip3=0
			set /a "pip21=!pip2!-1"
			if 0 gtr !pip21! (
				set pip2=0
				set /a "pip11=!pip1!-1"
				if 0 gtr !pip11! (
					set pip1=0
				) else (
					set pip1=!pip11!
				)
			) else (
				set pip2=!pip21!
			)
		) else (
			set pip3=!pip31!
		)
	) else (
		set pip4=!pip41!
	)
	set ipm=!pip1!.!pip2!.!pip3!.!pip4!
	set tempips=!ips! 
	for /f "tokens=1* delims=." %%a in ("!tempips!") do (
	set pip1=%%a
	set tempips=%%b
	)
	for /f "tokens=1* delims=." %%a in ("!tempips!") do (
	set pip2=%%a
	set tempips=%%b
	)
	for /f "tokens=1* delims=." %%a in ("!tempips!") do (
	set pip3=%%a
	set pip4=%%b
	)
	set /a "pip41=!pip4!+1"
	if !pip41! gtr 255 (
		set pip4=0
		set /a "pip31=!pip3!+1"
		if !pip31! gtr 255 (
			set pip3=0
			set /a "pip21=!pip2!+1"
			if !pip21! gtr 255 (
				set pip2=0
				set /a "pip11=!pip1!+1"
				if !pip11! gtr 255 (
					set pip1=0
				) else (
					set pip1=!pip11!
				)
			) else (
				set pip2=!pip21!
			)
		) else (
			set pip3=!pip31!
		)
	) else (
		set pip4=!pip41!
	)
	set temp=!newIp!
	set newIp=!temp!-!ipm!,!pip1!.!pip2!.!pip3!.!pip4!
)

set temp=!newIp!
set newIp=!temp!-255.255.255.255

goto menu
