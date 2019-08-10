#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
#Persistent
#SingleInstance, Force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; SetTimer, CheckIdle, 5000

; Menu, Tray, Add,% "Parse Clipboard Contents", ParseClipboard
; Menu, Tray, Add,% "Open INI File for Editing", OpenIni
Menu, Tray, Add,% "Reload This Program", ManReload
; Menu, Tray, Add,% "Create a New Macro", NewMacro

;INI file
iniFile := A_WorkingDir "\macros.ini"
IniRead, sections, % iniFile
IniRead, sectionEntries, % iniFile, % "Macros"
sectionList := StrSplit(sections, "`n")

parsedIni := {} ; Mark as global because functions can't see any variables from outside otherwise.
searchList := []
replaceList := []

; Create all the HotStrings and make a key lookup for other tasks.
ParseMacros:
Loop, Parse, sectionEntries, `n
{
	splitKey := StrSplit(A_LoopField, "=")
	parsedIni[splitKey[1]] := RegExReplace(splitKey[2], "\\EOL", "`n")
	cKeys := CasedKeys(splitKey[1])
	MakeHotstrings(cKeys)
}

CasedKeys(sKey)
{
	c := {}
	c["lower"] := Format("{1:l}",      sKey)
	c["upper"] := Format("{1:U}{2:l}", SubStr(sKey, 1, 1), SubStr(sKey, 2))
	c["title"] := Format("{1:U}",      sKey)
	return c
}

MakeHotstrings(cKeys)
{
	Hotstring(":CX:" cKeys["lower"] " ", "PasteText")
	Hotstring(":CX:" cKeys["upper"] " ", "PasteUpper")	
	Hotstring(":CX:" cKeys["title"] " ", "PasteTitled")
	return
}

PasteText(cased = "lower")
{
	global
	cleanKey := Trim(RegExReplace(A_ThisHotkey, "^:\w*:"))
	cleanKey := format("{1:l}", cleanKey)
	iniValue := parsedIni[cleanKey]
	if (cased == "upper")
		output := Format("{1:U}{2}", SubStr(output, 1, 1), SubStr(output, 2))
	else if (cased == "title")
		output := Format("{1:t}", output)	
	else ; (cased == "lower")
		output := Format("{1:l}", iniValue)
	Clipboard := output
	Send, ^v
	return
}

PasteUpper()
{
	PasteText("upper")
	return
}

PasteTitled()
{
	PasteText("title")
	return
}

/*
	ParseClipboard:
	MsgBox, 4097, , % "First select the text you want to modify then click Ok"
	IfMsgBox, Ok
	{
		Clipboard :=
		Send, ^c
		Sleep, 250
		Modify := Clipboard
		Sleep, 250
		for k, v in parsedIni
		{
			Modify := RegExReplace(Modify, "\b" k "\b", v)
		}
		Clipboard := Modify
		SendInput, ^v
	}
	return
*/

OpenIni()
{
	Run, notepad.exe %iniFile%
	WinWait, % "macros.ini"
	Loop
	{
		if WinExist("macros.ini")
			sleep, 1000
		else
		{
			Reload
			break
		}
	}
}
return

ManReload()
{
	Reload
	return
}