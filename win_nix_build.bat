@ECHO off
SET MATLAB_BINARY=D:\Programs\MATLAB_R2016b\bin
REM Latest Boost dependencies at https://projects.g-node.org/nix/
SET NIX_DEP=D:\Git\nix-dep
REM clone nix source from https://github.com/G-Node/nix
SET NIX_ROOT=D:\Git\nix
SET NIX_MX_ROOT=D:\Git\nix-mx
REM This build script requires HDF5 version 1.10.1
REM Latest HDF5 dependencies for VS 2013 at https://www.hdfgroup.org/downloads/hdf5/
REM provide them at %NIX-DEP%\x86 or %NIX-DEP%\x64
SET HDF5_VERSION_DIR=hdf5-1.10.1
REM Static build requires cmake version 3.9.1
SET CMAKEVER=3.12
REM Leave NIX_MX_ONLY "" for full nix and nix-mx build
SET NIX_MX_ONLY=""

ECHO --------------------------------------------------------------------------
ECHO Checking dependencies ...
ECHO --------------------------------------------------------------------------

IF NOT EXIST cmake (
	ECHO Require a valid installation of cmake.\nExit...
	EXIT /b
)

FOR /F "tokens=*" %%a in ('cmake /V ^| find "%CMAKEVER%" /c') DO SET HASCMAKEVER=%%a
IF NOT [%HASCMAKEVER%]==[1] (
	ECHO Require cmake version %CMAKEVER%.
	EXIT /b
	)

IF NOT EXIST %NIX_DEP% (
	ECHO Please provide the nix dependency directory.
	EXIT /b
)

IF NOT EXIST %NIX_ROOT% (
	ECHO Please provide valid nix root directory.
	EXIT /b
)

IF NOT EXIST %NIX_MX_ROOT% (
	ECHO Please provide valid nix-mx root directory.
	EXIT /b
)

ECHO Use only build types "Release" or "Debug"
IF "%1" == "Debug" (SET BUILD_TYPE=Debug)
IF "%BUILD_TYPE%" == "" (SET BUILD_TYPE=Release)

IF NOT %BUILD_TYPE% == Release (IF NOT %BUILD_TYPE% == Debug (ECHO Only Release or Debug are supported build types))
IF NOT %BUILD_TYPE% == Release (IF NOT %BUILD_TYPE% == Debug (EXIT /b))

ECHO --------------------------------------------------------------------------
ECHO Setting up environment ...
ECHO --------------------------------------------------------------------------

IF "%PLATFORM%" == "" (IF %PROCESSOR_ARCHITECTURE% == x86 (SET PLATFORM=x86) ELSE (SET PLATFORM=x64))
ECHO Platform: %PLATFORM% (%BUILD_TYPE%)

SET BASE=%NIX_DEP%\%PLATFORM%\%BUILD_TYPE%

SET CPPUNIT_INCLUDE_DIR=%BASE%\cppunit-1.13.2\include
SET PATH=%PATH%;%CPPUNIT_INCLUDE_DIR%

SET HDF5_BASE=%NIX_DEP%\%PLATFORM%\%HDF5_VERSION_DIR%
SET HDF5_DIR=%HDF5_BASE%\cmake
SET PATH=%PATH%;%HDF5_BASE%\bin

SET BOOST_ROOT=%BASE%\boost-1.69.0
SET BOOST_INCLUDEDIR=%BOOST_ROOT%\include\boost-1_69_0

ECHO CPPUNIT_INCLUDE_DIR=%CPPUNIT_INCLUDE_DIR%, checking directory...
IF EXIST %CPPUNIT_INCLUDE_DIR% (ECHO cppunit OK) ElSE (EXIT /b)
ECHO HDF5_DIR=%HDF5_DIR%, checking directory...
IF EXIST %HDF5_DIR% (ECHO hdf5 OK) ELSE (EXIT /b)
ECHO BOOST_INCLUDEDIR=%BOOST_INCLUDEDIR%, checking directory...
IF EXIST %BOOST_ROOT% (ECHO boost OK) ELSE (EXIT /b)

IF %NIX_MX_ONLY% == "" (
ECHO --------------------------------------------------------------------------
ECHO Setting up nix build ...
ECHO --------------------------------------------------------------------------
SET NIX_BUILD_DIR=%NIX_ROOT%\build\%BUILD_TYPE%

IF NOT EXIST %NIX_ROOT%\build (MKDIR %NIX_ROOT%\build)
CD %NIX_ROOT%\build
REM Clean up build folder to ensure clean build.
DEL * /S /Q
RD /S /Q "CMakeFiles" "Testing" "Debug" "Release" "nix-tool.dir" "x64" "TestRunner.dir" "nix.dir"

IF %PROCESSOR_ARCHITECTURE% == x86 ( cmake .. -DBUILD_STATIC=ON -G "Visual Studio 15 2017") ELSE (cmake .. -DBUILD_STATIC=ON -G "Visual Studio 15 2017 Win64")

ECHO --------------------------------------------------------------------------
ECHO Building nix via %NIX_ROOT%\build\nix.sln ...
ECHO --------------------------------------------------------------------------
cmake --build . --config %BUILD_TYPE% --target nixio

IF %ERRORLEVEL% == 1 (EXIT /b)

ECHO --------------------------------------------------------------------------
ECHO Building nix testrunner ...
ECHO --------------------------------------------------------------------------
cmake --build . --config %BUILD_TYPE% --target testrunner

IF %ERRORLEVEL% == 1 (EXIT /b)

ECHO --------------------------------------------------------------------------
ECHO Building nix-tool ...
ECHO --------------------------------------------------------------------------
cmake --build . --config %BUILD_TYPE% --target nixio-tool

IF %ERRORLEVEL% == 1 (EXIT /b)

ECHO --------------------------------------------------------------------------
ECHO Testing nix ...
ECHO --------------------------------------------------------------------------
%NIX_BUILD_DIR%\TestRunner.exe

IF %ERRORLEVEL% == 1 (EXIT /b)

REM nix-mx requires nixversion file in ../nix/include/nix
IF EXIST %NIX_ROOT%\build\include\nix\nixversion.hpp (
	COPY %NIX_ROOT%\build\include\nix\nixversion.hpp %NIX_ROOT%\include\nix\
)
)

