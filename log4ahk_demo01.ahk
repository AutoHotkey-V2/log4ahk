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
	logger.debug("Test DEBUG - Lvl INFO") ; isn't be logged due the current loglevel has lesser prioriity than required loglevel
	logger.info("Test INFO - Lvl INFO")
	logger.layout.required := "%d - %r - %R [%P] [%-5.5V] {%s - %-15.15M}{%H} %m"
	logger.info("INFO - Test INFO - Lvl INFO - after change of layout")
}

; Output: 
;[TRACE] {[AUTO-EXECUTE] }{XYZ-COMP} TRACE - Test TRACE
;[DEBUG] {[AUTO-EXECUTE] }{XYZ-COMP} TRACE - Test DEBUG
;[INFO ] {[AUTO-EXECUTE] }{XYZ-COMP} TRACE - Test INFO
;[INFO ] {f1             }{XYZ-COMP} INFO - Test INFO