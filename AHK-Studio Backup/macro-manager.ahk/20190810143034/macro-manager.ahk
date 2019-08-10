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
IniFile := A_WorkingDir "\macros.ini"
IniRead, Sections, % IniFile
IniRead, SectionEntries, % IniFile, % "Macros"
SectionList := StrSplit(Sections, "`n")

ParsedIni := {} ; Mark as global because functions can't see any variables from outside otherwise.
SearchList := []
ReplaceList := []

; Create all the HotStrings and make a key lookup for other tasks.
ParseMacros:
Loop, Parse, SectionEntries, `n
{
	SplitKey := StrSplit(A_LoopField, "=")
	ParsedIni[SplitKey[1]] := RegExReplace(SplitKey[2], "\\EOL", "`n")
	Ckeys := CasedKeys(SplitKey[1])
	MakeHotstrings(Ckeys)
}

CasedKeys(Skey)
{
	C := {}
	C["lower"] := Format("{1:l}",      Skey)
	C["upper"] := Format("{1:U}{2:l}", SubStr(Skey, 1, 1), SubStr(Skey, 2))
	c["title"] := Format("{1:U}",      Skey)
	return C
}

MakeHotstrings(Ckeys)
{
	Hotstring(":CX:" Ckeys["lower"] " ", "PasteText")
	Hotstring(":CX:" Ckeys["upper"] " ", "PasteUpper")	
	Hotstring(":CX:" Ckeys["title"] " ", "PasteTitled")
	return
}

PasteText(cased = "lower")
{
	global
	CleanKey := Trim(RegExReplace(A_ThisHotkey, "^:\w*:"))
	CleanKey := format("{1:l}", CleanKey)
	IniValue := ParsedIni[CleanKey]
	if (cased == "upper")
		Output := Format("{1:U}{2}", SubStr(Output, 1, 1), SubStr(Output, 2))
	else if (cased == "title")
		Output := Format("{1:t}", Output)	
	else ; (cased == "lower")
		Output := Format("{1:l}", IniValue)
	Clipboard := Output
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
		for k, v in ParsedIni
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
	Run, notepad.exe %IniFile%
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