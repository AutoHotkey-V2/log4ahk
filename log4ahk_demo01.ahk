#include %A_ScriptDir%\log4ahk.ahk

; #include %A_ScriptDir%\lib\SerDes.ahk

WinActivate "DebugView++"
OutputDebug "DBGVIEWCLEAR"


logger := new log4ahk()
; Set the loglevel to be filtered upon
logger.loglevel.required := logger.loglevel.TRACE
; Show loglevel, current function, computername and log message in log protocol
logger.layout.required := "[%P] [%-5.5V] {%-15.15M}{%H} %m"
logger.trace("TRACE - Test TRACE") 
logger.debug("TRACE - Test DEBUG")
logger.info("TRACE - Test INFO")

f1()
return

;########################################################
f1() {
	logger := new log4ahk()
	; Change the loglevel to be filtered upon
	logger.loglevel.required := logger.loglevel.INFO
	logger.trace("INFO - Test TRACE") ; shouldn't be logged due to required loglevel
	logger.debug("INFO - Test DEBUG") ; shouldn't be logged due to required loglevel
	logger.info("INFO - Test INFO")
}

; Output: 
;[TRACE] {[AUTO-EXECUTE] }{XYZ-COMP} TRACE - Test TRACE
;[DEBUG] {[AUTO-EXECUTE] }{XYZ-COMP} TRACE - Test DEBUG
;[INFO ] {[AUTO-EXECUTE] }{XYZ-COMP} TRACE - Test INFO
;[INFO ] {f1             }{XYZ-COMP} INFO - Test INFO