/*
Title: log4ahk - Logging for AutoHotkey 

Logs given String to given device. For more details see <log4ahk>
  
Authors:
<hoppfrosch at hoppfrosch@gmx.de>: Original

License: 
WTFPL License

=== Code
    DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
        Version 2, December 2004 

Copyright (C) 2018 Johannes Kilian <hoppfrosch@gmx.de> 

Everyone is permitted to copy and distribute verbatim or modified 
copies of this license document, and changing it is allowed as long 
as the name is changed. 

DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE 
TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION 

0 - You just DO WHAT THE FUCK YOU WANT TO.
===   
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
/*
Class: log4ahk
A class that provides simple logging facilities for AutoHotkey

This log-Class supports 

  - <Loglevels>
  - Layout of the prepended string

Loglevels: 

Each message has to be logged on a certain loglevel. Consider the loglevel as the severity of the message 
you want to log: some logmessages are used for simple debug purposes, whereas other logmessages may 
indicate an Error.

  - Different hiearchical loglevels are Supported
  - The hierachy is *trace* (1) <- *debug* (2) <- *info* (3) <- *warn* (4) <- *error* (5) <- *fatal* (6)

*/
	_version := "0.2.0"
	shouldLog := 1
	
	mode := 0 ; 0 = OutputDebug, 1 = StdOut, anythingElse = MsgBox
	static _indentLvl := 0
	shouldIndent := 1

	
	; ##########################################################################
	; --------------------------------------------------------------------------------------
	; Group: Public Methods		
	trace(str) {
	/*
	Method: trace()
	Logs the given string at TRACE level
	
	Parameters:
	
		str - String to be logged
	*/
		this._log(str, this._loglevel.TRACE)
	}

	debug(str) {
	/*
	Method: debug()
	Logs the given string at DEBUG level
	
	Parameters:
	
		str - String to be logged
	*/
		this._log(str, this._loglevel.DEBUG)
	}

	info(str) {
	/*
	Method: info()
	Logs the given string at INFO level
	
	Parameters:
	
		str - String to be logged
	*/
		this._log(str, this._loglevel.INFO)
	}

	warn(str) {
	/*
	Method: warn()
	Logs the given string at WARN level
	
	Parameters:
	
		str - String to be logged
	*/
		this._log(str, this._loglevel.WARN)
	}

	error(str) {
	/*
	Method: error()
	Logs the given string at ERROR level
	
	Parameters:
	
		str - String to be logged
	*/
		this._log(str, this._loglevel.ERROR)
	}

	fatal(str) {
	/*
	Method: fatal()
	Logs the given string at TRACE level
	
	Parameters:
	
		str - String to be logged
	*/
		this._log(str, this._loglevel.FATAl)
	}

	; --------------------------------------------------------------------------------------
	; Group: Private Methods		
	_log(str, loglvl := 2)  {
	/*
	Method: _log()
	Logs the given string at the given level
	
	Parameters:
	
		str - String to be logged
		loglvl - level on which the given message is to be logged
		
	About: Internals
	The given loglevel is compared against the global required fixlevel (see <required>) 
	Is the given loglevel equal or greater the required loglevel the logmessage is printed 
	- otherwise the logmessage is suppressed.
	*/
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

	; ##########################################################################
	class layout {
	/* 
	Class: log4ahk.layout
	Helper class for <log4ahk> (Implementing layout)
	*/
	
		_tokens := []

		; --------------------------------------------------------------------------------------
		; Group: Private Methods
		
		_expand(ph) {
		/*
		Method: _expand(ph)
		Expands the placeholders with the values from the given array
		
		Parameters:
			ph - associative Array containing mapping placeholder to its replacement
		*/
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
		/*
		Method: _split()
		Splits the layout into its tokens
		*/
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

		; --------------------------------------------------------------------------------------
		; Group: Properties
		
		required[] {
		/*
  		Property: required [get/set] 
		Get/set the required layout
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
		/*
  		Property: tokens [get] 
		Get the tokens of the current layout
		
		Internals:
		The layout string is separated into its separate layout elements (tokens). For example "%8L %M" 
		consists of two tokens: "%8L" and "%M". Each token starts with "%" and ends at the next space. 
		The tokens are split up into its separate parts.
  		*/
			get {
				this._split()
				return  this._tokens
			}
  		}
	}

	; ##########################################################################
	/* 
	Class: log4ahk.loglevel
	Helper class for <log4ahk> (Implementing loglevels)
	*/
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
}
