/*
Name: log4ahk - Logs given String to given device
Version 0.1.0
Author: hoppfrosch
Description:
  Logs the string to a given Device.
  
  Supported prefixes are currently:
  * ">" - This should be used when a funtion is entered. On each usage of this Prefix the indentation level is increased
    Example:  dbgOut(">[" A_ThisFunc "()]")
  * "<" - This should be used when a funtion is exited. On each usage of this Prefix the indentation level is decreased
*/

; ===================================================================================
; AHK Version ...: Tested with AHK v2.0-a100-52515e2 x64 Unicode
; Win Version ...: Tested with Windows 10 Enterprise x64
; Authors ........:  * Original - deo (original)
; ...............   * Modifications - hoppfrosch 
; License .......: WTFPL (http://www.wtfpl.net/about/)
; Source ........: Original: https://autohotkey.com/board/topic/76062-ahk-l-how-to-get-callstack-solution/
; ................ V2 : https://github.com/AutoHotkey-V2/CallStack
; ===================================================================================
#include CallStack\CallStack.ahk

class log4ahk {

	_version := "0.1.0"
	shouldLog := 1
	
	mode := 0 ; 0 = OutputDebug, 1 = StdOut, anythingElse = MsgBox
	static _indentLvl := 0
	shouldIndent := 1

	_layout := "[#L#] #C#"

	; ##########################################################################
	class loglevel {
		STATIC TRACE := 1
		STATIC DEBUG := 2
		STATIC INFO := 3
		STATIC WARN := 4
		STATIC ERROR := 5
		STATIC FATAL := 6


		tr(lvl){
			; Translate the numeric loglevel into a string
			translation := ["TRACE","DEBUG","INFO","WARN","ERROR","FATAL"]
			if ((lvl >= this.TRACE) & (lvl <= this.FATAL)) {
				return translation[lvl]
			}
			return "LOG"
		}

		__New() {
			; Singleton class (see https://autohotkey.com/boards/viewtopic.php?p=175344#p175344)
			static init
			if init
					return init
			init := This

			_required := 2
			_current := 2
		}

		_limit(lvl) {
			if (lvl < this.TRACE) {
				return this.TRACE
			}
			if (lvl > this.FATAL) {
				return this.FATAL
			}
			return lvl
		}

		current[] {
  		/* ---------------------------------------------------------------------------------------
  		Property: current [get/set] - get/set the current loglevel
  		*/
			get {
				return  this._current
			}
			set {
				this._current := this._limit(value)
				return this._current
			}
		}

		required[] {
  		/* ---------------------------------------------------------------------------------------
  		Property: required [get/set] - get/set the required loglevel
  		*/
			get {
				return  this._required
			}
			set {
				this._required := this._limit(value)
				return this._required
			}
  		}
	}
	; ##########################################################################
	trace(str) {
		this._log(str, this._loglevel.TRACE)
	}

	debug(str) {
		this._log(str, this._loglevel.DEBUG)
	}

	info(str) {
		this._log(str, this._loglevel.INFO)
	}

	warn(str) {
		this._log(str, this._loglevel.WARN)
	}

	error(str) {
		this._log(str, this._loglevel.ERROR)
	}

	fatal(str) {
		this._log(str, this._loglevel.FATAl)
	}

	_log(str, loglvl := 2)  {
		if (!this.shouldLog)
			return

		this._logLevel.current := loglvl

		if (this._loglevel.required <= this._logLevel.current  ) {
			prefix := this._prefix()
			out := prefix " " this._indent(str)
			if (this.mode = 0) {
				OutputDebug(out)
			}
			else if (this.mode = 1) {
				FileAppend out "`n", "*"
			}
			else {
				MsgBox(out)
			}
		}
		return
	}
  
	_prefix() {
		out := this.layout
		out := RegExReplace(out, "#L#", this._loglevel.tr(this._loglevel.current))

		if (RegExMatch(this.layout, "#C#")) {
			cs:= CallStack(deepness := 4)
			out := RegExReplace(out, "#C#", cs[-3].function)
		}
		return out
	}

	_indent(str) {
		out := str
		if (this.shouldIndent) {
			x1 := SubStr(str, 1, 1)
			if (x1 = "<") {
				this._indentLvl := this._indentLvl - 1
			} 

			i := 0
			indentStr := ""
			while (i < this._indentLvl) {
				indentStr := indentStr "__"
				i := i + 1
			}
			out := indentStr str

			if (x1 = ">") {
				this._indentLvl := this._indentLvl + 1
			}
		}
		return out
	}
	
	__New() {
		; Singleton class (see https://autohotkey.com/boards/viewtopic.php?p=175344#p175344)
		static init ;This is where the instance will be stored
		
		if init ;This will return true if the class has already been created
			return init ;And it will return this instance rather than creating a new one
		
		init := This ; this will overwrite the init var with this instance

		this._loglevel := new this.loglevel()
	}

	; ##################### Start of Properties ##############################################
  	layout[] {
  	/* ---------------------------------------------------------------------------------------
  		Property: layout [get/set] - get/set the current layout
  	*/
    	get {
      		return  this._layout
    	}
		set {
			this._layout := value
			return this._layout
		}
  	}
}
