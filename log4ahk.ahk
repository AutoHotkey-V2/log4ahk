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

	_version := "0.2.0"
	shouldLog := 1
	
	mode := 0 ; 0 = OutputDebug, 1 = StdOut, anythingElse = MsgBox
	static _indentLvl := 0
	shouldIndent := 1

	; ##########################################################################
	class layout {
		_tokens := []

		_expand(ph) {
			str := this.required
			Loop this.tokens.Length() {
				PlaceholderExpanded := ph[this._tokens[A_Index]["Placeholder"]]
				PatternExpanded := this._tokens[A_Index]["Quantifier"] PlaceholderExpanded this._tokens[A_Index]["Curly"]
				str := RegExReplace(str, this._tokens[A_Index]["Pattern"], PatternExpanded)
			}
			return str
		}

		__New() {
			; Singleton class (see https://autohotkey.com/boards/viewtopic.php?p=175344#p175344)
			static init
			if init
					return init
			init := This

			this._split()
		}

		_split() {
			FoundPos := 1
    		len := 0
			this._tokens := []

			haystack := this.required
			Pattern := "(%([.-]?[0-9]{0,3})([LM]{1})(\{[0-9]{1,2}\})?)"
    		While (FoundPos := RegExMatch(haystack, pattern, Match, FoundPos + len)) {
      			len := Match.len(0)
				token := []
				token["Pattern"] := Match[1] 
				token["Quantifier"] := Match[2] 
				token["Placeholder"] := Match[3]
				token["Curly"] := Match[4] 	 
				this._tokens.Push(token)
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
				this._required := value
				this._split()
				return value
			}
  		}
		tokens[] {
		/* ---------------------------------------------------------------------------------------
  		Property: tokens [get] - get the tokens of the current layout
  		*/
			get {
				this._split()
				return  this._tokens
			}
  		}
	}

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
			placeholders := this._fillLayoutPlaceholders() ; Expand the layout placeholders with current values
			layoutexpanded := this._layout._expand(placeholders) ; Generate the layout string

			out := layoutexpanded " " this._indent(str)
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
  
	_fillLayoutPlaceholders() {
		tokens := this._layout.tokens
		ph := []
		thiscalldepth := 3

		Loop tokens.Length() {
			a := tokens[A_Index]
			value := ""
			if (a["Placeholder"] == "L") {
				value := this._loglevel.tr(this._loglevel.current)
			}
			else if a["Placeholder"] == "M" {
				cs:= CallStack(deepness := thiscalldepth+1)
				value := cs[-thiscalldepth].function
			}
			ph[a["Placeholder"]]  := value
		}
		return ph
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
		this._layout := new this.layout()
	}

	; ##################### Start of Properties ##############################################
	; ##################### Start of Properties ##############################################
}
