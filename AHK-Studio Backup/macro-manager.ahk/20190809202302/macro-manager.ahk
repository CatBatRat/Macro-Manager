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

;INI file
IniFile := A_WorkingDir "\macros.ini"
IniRead, Sections, % IniFile
IniRead, SectionEntries, % IniFile, % "Macros"
SectionList := StrSplit(Sections, "`n")

global ParsedIni := {}
SearchList := []

; Create all the HotStrings and make a key lookup for other tasks.
ParseMacros:
Loop, Parse, SectionEntries, `n
{
	SplitKey := StrSplit(A_LoopField, "=")
	SearchList.Push(SplitKey[1])
	fn := Func("PasteText")
	Uppered := Format("{1:U}{2:l}", SubStr(SplitKey[1], 1, 1), SubStr(SplitKey[1], 2))
	Hotstring(":CX:" SplitKey[1] " ", "PasteLower")
	Hotstring(":CX:" Uppered " ", "PasteText")	
	ParsedIni[SplitKey[1]] := SplitKey[2]
}

PasteText()
{
	CleanKey := Trim(RegExReplace(A_ThisHotkey, "^:\w*:"))
	Output := Format("{1:l}", ParsedIni[CleanKey] A_EndChar)
	MsgBox % "String to replace (" CleanKey ") Replacment string (" Output ")"
	; Send, ^v
	return
}

PasteUpper()
{
	CleanKey := Trim(RegExReplace(A_ThisHotkey, "^:\w*:"))
	Output := Format("{1:l}", ParsedIni[CleanKey] A_EndChar)
	Output := format("{1:U}{2}", SubStr(Output, 1, 1), SubStr(Output, 2))
	MsgBox % "String to replace (" CleanKey ") Replacment string (" Output ")"
	; Send, ^v
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
	
	
	
	CheckIdle:
	if (A_TimeIdle > 4000)
	{
		Suspend, On
		Suspend, Off
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