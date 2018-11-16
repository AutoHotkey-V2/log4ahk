# log4ahk [![AutoHotkey2](https://img.shields.io/badge/Language-AutoHotkey2-red.svg)](https://autohotkey.com/)

This library uses [AutoHotkey Version 2](https://autohotkey.com/v2/). (Tested with [AHK v2.0-a100-52515e2 x64 Unicode](https://autohotkey.com/boards/viewtopic.php?p=242306#p242306)) 

## Description

Simple logging with AutoHotkey - supporting some features as provided in [log4j](https://logging.apache.org/log4j/2.x/) or [log4Perl](https://metacpan.org/pod/Log::Log4perl)

## Usage 

Include `log4ahk.ahk` from the `lib` folder into your project using standard AutoHotkey-include methods.

```autohotkey
#include <log4ahk.ahk>

; Initialize the logger
logger := new log4ahk()
; Set the appenders to be logged to: STDOUT
logger.appenders.push(new logger.appenderstdout())
; Set the layout for the messages
logger.layout.required := "[%V] #%M# %m"
; Choose the desired loglevel
logger.loglevel.required := logger.loglevel.INFO
logger.trace("TraceTest") ; This Message should not be logged due to choosen loglevel
logger.info("InfoTest") ; This Message should be logged!
```

For usage examples have a look at the files *log4ahk_demoXX.ahk*.

For more detailed documentation have a look into the source file *log4ahk.ahk* or online [html-documentation](https://autohotkey-v2.github.io/log4ahk/)