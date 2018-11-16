#include %A_ScriptDir%\log4ahk.ahk

; #include %A_ScriptDir%\lib\SerDes.ahk

;WinActivate "DebugView++"
;OutputDebug "DBGVIEWCLEAR"


logger := new log4ahk()
; Set the loglevel to be filtered upon
logger.loglevel.required := logger.loglevel.TRACE
; Set the appenders to be logged to
logger.appenders.push(new logger.appenderoutputdebug())
logger.appenders.push(new logger.appenderstdout())
; Show loglevel, current function, computername and log message in log protocol
logger.layout.required := "[%-5.5V] {%-15.15M}{%H} %m"
logger.info("Running log4ahk - Version " logger._version)
logger.trace("Test TRACE - Lvl TRACE") 
logger.debug("Test DEBUG - Lvl TRACE")
logger.info("Test INFO - Lvl TRACE")

f1()
return

;########################################################
f1() {
	logger := new log4ahk()
	; Change the loglevel to be filtered upon
	logger.loglevel.required := logger.loglevel.INFO
	logger.debug("Test DEBUG - Lvl INFO") ; won't be logged as the current loglevel has lesser priority than required loglevel
	logger.info("Test INFO - Lvl INFO")
	logger.layout.required := "%d - %r - %R [%P] [%-5.5V] {%s - %-15.15M}{%H} %m"
	logger.info("INFO - Test INFO - Lvl INFO - after change of layout")
}

; Output: 
[INFO ] {[AUTO-EXECUTE] }{NB00121} Running log4ahk - Version 0.4.0
[TRACE] {[AUTO-EXECUTE] }{NB00121} Test TRACE - Lvl TRACE
[DEBUG] {[AUTO-EXECUTE] }{NB00121} Test DEBUG - Lvl TRACE
[INFO ] {[AUTO-EXECUTE] }{NB00121} Test INFO - Lvl TRACE
[INFO ] {f1             }{NB00121} Test INFO - Lvl INFO
2018/11/19 07:27:55 - 8.60363052823162633 - 1.63673621445787609 [4332] [INFO ] {log4ahk_demo01.ahk - f1             }{COMPI} INFO - Test INFO - Lvl INFO - after change of layout