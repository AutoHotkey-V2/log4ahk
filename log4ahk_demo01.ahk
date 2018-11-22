#Warn All
#Warn LocalSameAsGlobal, Off

#include %A_ScriptDir%\log4ahk.ahk

; #include %A_ScriptDir%\lib\SerDes.ahk

WinActivate "DebugView++"
OutputDebug "DBGVIEWCLEAR"


logger := new log4ahk()
; Set the loglevel to be filtered upon
logger.loglevel.required := logger.loglevel.TRACE
; Set the appenders to be logged to
logger.appenders.push(new logger.appenderoutputdebug())
logger.appenders.push(new logger.appenderstdout())
; Show loglevel, current function, computername and log message in log protocol
logger.layout.required := "{%H} [%-5.5V] {%15.15M} %i %m"
logger.info("Running log4ahk - Version " logger._version)
logger.trace("Test TRACE - Lvl TRACE") 
logger.debug("Test DEBUG - Lvl TRACE")
logger.info("Test INFO - Lvl TRACE")

f1()
f2()
return

;########################################################
f1() {
	logger := new log4ahk()
	; Change the loglevel to be filtered upon
	logger.loglevel.required := logger.loglevel.INFO
	logger.info("Entering function")
	logger.debug("Test DEBUG - Lvl INFO") ; won't be logged as the current loglevel has lesser priority than required loglevel
	logger.info("Test INFO - Lvl INFO")

	f11()
	logger.info("Leaving function")
}

f11() {
	logger := new log4ahk()
	; Change the loglevel to be filtered upon
	logger.info("INFO - Test INFO - Lvl INFO")
}

;########################################################
f2() {
	logger := new log4ahk()
	logger.layout.required := "%d - %r - %R [%P] [%-5.5V] {%s - %-15.15M}{%H} %m"
	logger.info("INFO - Test INFO - Lvl INFO - after change of layout")
}
/*
; Output: 
{NB00121} [INFO ] { [AUTO-EXECUTE]}  Running log4ahk - Version 0.4.1
{NB00121} [TRACE] { [AUTO-EXECUTE]}  Test TRACE - Lvl TRACE
{NB00121} [DEBUG] { [AUTO-EXECUTE]}  Test DEBUG - Lvl TRACE
{NB00121} [INFO ] { [AUTO-EXECUTE]}  Test INFO - Lvl TRACE
{NB00121} [INFO ] {             f1} __ Entering function
{NB00121} [INFO ] {             f1} __ Test INFO - Lvl INFO
{NB00121} [INFO ] {            f11} ____ INFO - Test INFO - Lvl INFO
{NB00121} [INFO ] {             f1} __ Leaving function
2018/11/22 08:16:37 - 52.11165835788305856 - 6.8523267293680572 [10424] [INFO ] {log4ahk_demo01.ahk - f2             }{NB00121} INFO - Test INFO - Lvl INFO - after change of layout
*/