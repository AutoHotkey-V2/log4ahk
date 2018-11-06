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

  - <Loglevel> allows to define to a hierarchy of log messages and controls which messages are logged
  - <Layout> of the logged message

Loglevels: 

Each message has to be logged on a certain <loglevel>. Consider the loglevel as the severity of the message 
you want to log: some logmessages are used for simple debug purposes, whereas other logmessages may 
indicate an Error. In some situations you want to have a very detailled logging - in other situations you just 
want to be notified about errors ... Both can be managed via <loglevel>. 

Layout:

Layouts allow to determine the format of the messages to be logged (see <layout>)
*/
	_version := "0.3.1"
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
			placeholders := this._fillLayoutPlaceholders(str) ; Expand the layout placeholders with current values
			layoutexpanded := this._layout._expand(placeholders) ; Generate the layout string
			if (this.mode = 0) {
				OutputDebug(layoutexpanded)
			}
			else if (this.mode = 1) {
				FileAppend layoutexpanded "`n", "*"
			}
			else {
				MsgBox(layoutexpanded)
			}
		}
		return
	}
  
	_fillLayoutPlaceholders(str := "") {
		currStringCaseSense := A_StringCaseSense 
		StringCaseSense "On"
		tokens := this._layout.tokens
		ph := []
		thiscalldepth := 3

		Loop tokens.Length() {
			a := tokens[A_Index]
			value := ""
			if (a["Placeholder"] == "H") {
				value := A_ComputerName
			}
			else if (a["Placeholder"] == "m") {
				value := str
			}
			else if (a["Placeholder"] =="M") {
				cs:= CallStack(deepness := thiscalldepth+1)
				value := cs[-thiscalldepth].function
			}
			else if (a["Placeholder"] == "V") {
				value := this._loglevel.tr(this._loglevel.current)
			}
			
			ph[a["Placeholder_decorated"]]  := value
		}

		StringCaseSense currStringCaseSense
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

	Creates a pattern layout according to <log4j-layout: http://jakarta.apache.org/log4j/docs/api/org/apache/log4j/PatternLayout.html> and a couple of log4ahk-specific extensions.

	Placeholders: 

	The following placeholders can be used within the layout string:

	%H - Hostname
	%m - The message to be logged
	%M - Method or function where the logging request was issued
	%V - Log level

	Quantify Placeholders:

	All placeholders can be extended with formatting instructions, just similar to <format: https://lexikos.github.io/v2/docs/commands/Format.htm>:

	%20M - Reserve 20 chars for the method, right-justify and fill with blanks if it is shorter
	%-20M - Same as %20c, but left-justify and fill the right side with blanks
    %09r - Zero-pad the number of milliseconds to 9 digits
    %.8M - Specify the maximum field with and have the formatter cut off the rest of the value
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
				PlaceholderExpanded := ph[this._tokens[A_Index]["Placeholder_decorated"]]
				if (this._tokens[A_Index]["Quantifier"]) {
					FormatQuantify := "{1:" this._tokens[A_Index]["Quantifier"] "s}"
					PlaceholderExpanded := Format(FormatQuantify, PlaceholderExpanded)
				}
				PatternExpanded := PlaceholderExpanded this._tokens[A_Index]["Curly"]
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

		Internals:
		The layout string is separated into its separate layout elements (tokens). For example "%8V %M" 
		consists of two tokens: "%8V" and "%M". Each token starts with "%" and ends at the next space. 

		The tokens are split up into its separate parts: each token consists of three parts:
		Placeholder Quantifier - All placeholders can be extended with formatting instructions, just similar to <format: https://lexikos.github.io/v2/docs/commands/Format.htm>
		Placeholder - Placeholders are replaced with the corresponding information
		Curlies - Curlies allow further manipulation of the placeholders

		As a result of the function, the private array <_tokens> is filled with objects, which contain the complete token as well as its single parts.

		For more information, which values are allowede for quantifiers, placeholders and curlies have a look at documentation
		of class <layout>
		*/
			FoundPos := 1
    		len := 0
			this._tokens := []

			haystack := this.required
			Pattern := "(%([-+ 0#]?[0-9]{0,3}[.]?[0-9]{0,3})([HmMV]{1})(\{[0-9]{1,2}\})?)"
    		While (FoundPos := RegExMatch(haystack, pattern, Match, FoundPos + len)) {
      			len := Match.len(0)
				token := []
				token["Pattern"] := Match[1] 
				token["Quantifier"] := Match[2] 
				placeholder := Match[3]
				token["Placeholder"] := placeholder
				; Lowercase Placeholders are decorated with a leading underscore
				; This is neccessary due to case-insensitivity of keys in associative arrays in AutoHotkey
				placeholder := RegExReplace(placeholder, "([a-z]{1})" , "_" "$1")
				token["Placeholder_decorated"] := placeholder
				token["Curly"] := Match[4] 	 
				this._tokens.Push(token)
			}
		}

		; --------------------------------------------------------------------------------------
		; Group: Properties
		
		required[] {
		/*
  		Property: required [get/set] 
		Get/set the required layout. This layout will be used to format the logged message.
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
		
		For more information see <_split>
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

	Loglevels support the following needs

		- hierarchize your log messages due to importance of the log message (from TRACE to FATAL)
		- control which level of log messages are currently to be logged

	Internals:
		- Different hierarchical loglevels are supported
  		- The hierachy levels are *trace* (1) <- *debug* (2) <- *info* (3) <- *warn* (4) <- *error* (5) <- *fatal* (6)
		- to log on a certain loglevel, separate methods are available (<trace>, <debug>, <info>, <warn>, <error>, <fatal>)
		- To filter message to due current used loglevel use following syntax, set the property logger.loglevel.required to the requested level

	Example:
	=== Autohotkey -----------
	logger := new log4ahk()
	; Choose the desired loglevel
	logger.loglevel.required := logger.loglevel.INFO
	logger.trace("TraceTest") ; This Message should not be logged due to choosen loglevel
	logger.info("InfoTest") ; This Message should be logged!
	===
	*/
	class loglevel {
		STATIC TRACE := 1
		STATIC DEBUG := 2
		STATIC INFO := 3
		STATIC WARN := 4
		STATIC ERROR := 5
		STATIC FATAL := 6

		; --------------------------------------------------------------------------------------
		; Group: Private Methods		
		tr(lvl){
		/*
		Method: tr()
		Translate the numeric loglevel into a string
	
		Parameters:
	
		lvl - Numerical loglevel
		
		Returns:
		String describing the choosen loglevel (to be used within <layout>)
		*/
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
		/*
		Method: _limit()
		Validate the loglevel
	
		Parameters:
	
		lvl - loglevel to be checked
		
		Returns:
		corrected loglevel
		*/
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
  		Property: current [get/set] 
		get/set the current loglevel
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
  		Property: required [get/set] 
		get/set the required loglevel
		
		If a message is reuested to be logged, the <current> loglevel is compared against required loglevel.
		If the current loglevel is greater/equal the required loglevel the message is logged - otherwise it is suppressed
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
