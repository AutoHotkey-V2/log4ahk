#include %A_ScriptDir%\log4ahk.ahk

; #include %A_ScriptDir%\lib\SerDes.ahk

WinActivate "DebugView++"
OutputDebug "DBGVIEWCLEAR"


logger := new log4ahk()
logger.loglevel.required := logger.loglevel.TRACE
logger.layout.required := "[%V] #%M# %m"
logger.trace("TRACE - Test TRACE")
logger.debug("TRACE - Test DEBUG")
logger.info("TRACE - Test INFO")

f1()
return

;########################################################
f1() {
	logger := new log4ahk()
	logger.loglevel.required := logger.loglevel.INFO
	logger.trace("INFO - Test TRACE")
	logger.debug("INFO - Test DEBUG")
	logger.info("INFO - Test INFO")
}
