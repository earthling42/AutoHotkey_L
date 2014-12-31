
; #AHK autohotkey pointers
; --Referencing global variables from within function bodies
	; eg:
		; global groovyMode
; -Debug
	; Run DebugView(www.sysinternals.com) and use OutputDebug, function
; - Composing strings
		; OutputDebug, new-1-1-2-1 found at . %breakPos% . `n . %parseString%
; - newline
	; variations: `n `r `R
; - Strings are 1 based   
	; - ie. - valid
 		; oneLine := SubStr(parseString, 1, breakPos)     ;extract a single line
	; - ie - invalid [ strange behaviour]
 		; oneLine := SubStr(parseString, 0, breakPos)     ;extract a single line
; - Assignment-
	; - NB: Set locally referenced GLOBAL variables to 'global' at the beginning of function definitions
	; - for strings use    :x = %y%%z%
	;			- origin	: x = My string ends with %z%.
	; - for numerics use   :c := b - a
; -Compare string and variable
	; if (hotkeyname = NumpadIns ) return tt("2.You pressed NumpadIns")  ;hotkeyname is variable, NumpadIns is literal string
	; if (hotkeyname = %presetKey% ) return tt("2.You pressed the preset key")  ;hotkeyname and presetKey are variables

	; -Hotkey modifiers
	; # 	Win 
	; ! 	Alt 							
	; ^ 	Control 
	; + 	Shift 
	; ~ 	When the hotkey fires, its key's native function will not be blocked 
	; UP  	may follow the name of a hotkey to cause the hotkey to fire upon release of the key 


	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialization
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ModifierState := ""
IsSftDown := false
IsCtlDown := false
IsWinDown := false
IsAltDown := false

KeyFunctionHash := {} ;
WinStepper := 0 ;
WinMax := 6 ;

Initialize()

Initialize()
{
	global KeyFunctionHash
	
	OutputDebug, ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;" 
	TrayTip, PilotFish , Launched, 2
	BuildFunctionHash()
}
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; IMPLEMENTATION FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
HandleKeypad(hotkeyName)
{	
	global KeyFunctionHash
	global WinStepper
		
	bracketedHotkeyName := "(" . hotkeyName . ")"
	OutputDebug, "bracketedHotkeyName:" %bracketedHotkeyName%
		
	modState := GetModifierState()
	OutputDebug, "modState:" %modState%
	
	activeWindowTag := CalculateActiveWindowTag() 

	permutations := CalculatePermutations(bracketedHotkeyName, modState, activeWindowTag) ;
	permutations.Insert(hotkeyName) 
	
	for index, element in permutations 
	{
		OutputDebug, "permutations:" %index% " --- " %element%
		elementPresent := KeyFunctionHash.HasKey(element)
		if (true == elementPresent)
		{
			resolvedFunction := KeyFunctionHash[element]
			resolvedFunction.()
			rName := resolvedFunction.Name
			OutputDebug, %element%  " resolved to function " %rName%
			TrayTip, %element% , %rName% (%WinStepper%), 2
			break
		}
	}
}
    
CalculateActiveWindowTag()    
{
	winTitle= ""
	winTag = ""
	WinGetActiveTitle, winTitle 
	OutputDebug, WinGetActiveTitle %winTitle%	
	titleTagHash := {"Visual Studio":"VS20xx", "ADT":"Eclipse", "Crusader":"Crusader"}
	titleTagHash.Insert("MINGW32" , "Shell")
	titleTagHash.Insert("powershell.exe" , "Shell")
	titleTagHash.Insert("cmd.exe" , "Shell")
	
	
	for searchString, tag in titleTagHash
	{
		ifInString winTitle, %searchString%
		{
			winTag = %tag%
		}
	}

	OutputDebug, CalculateActiveWindowTagOutput = "%winTag%"
	return winTag
}

CalculatePermutations(bracketedHotkeyName,modState,activeWindowTag)
{
	permutations := Object()
	permutations.Insert(activeWindowTag . modState . bracketedHotkeyName) 
	permutations.Insert(modState . bracketedHotkeyName) 
	permutations.Insert(activeWindowTag . bracketedHotkeyName) 
	permutations.Insert(bracketedHotkeyName) 
	
	return permutations
}

BuildFunctionHash()
{
	global KeyFunctionHash

	KeyFunctionHash.Insert( "(NumpadDiv)", Func("rename"))
	KeyFunctionHash.Insert( "(NumpadMult)", Func("save"))
	KeyFunctionHash.Insert( "(NumpadSub)", Func("diskRoot"))
	KeyFunctionHash.Insert( "(NumpadAdd)", Func("selectAll"))
	KeyFunctionHash.Insert( "(NumpadHome)", Func("searchBack"))
	KeyFunctionHash.Insert( "(NumpadUp)", Func("find"))
	KeyFunctionHash.Insert( "(NumpadPgUp)", Func("searchForward"))
	KeyFunctionHash.Insert( "(NumpadLeft)" , Func("copy"))
	KeyFunctionHash.Insert( "(NumpadClear)", Func("paste"))
	KeyFunctionHash.Insert( "(NumpadRight)", Func("cut"))
	KeyFunctionHash.Insert( "(NumpadEnd)", Func("goBeginDoc"))
	KeyFunctionHash.Insert( "(NumpadDown)", Func("goEndDoc"))
	KeyFunctionHash.Insert( "(NumpadPgDn)", Func("undo"))
	KeyFunctionHash.Insert( "(NumpadEnter)", Func("enter"))
	KeyFunctionHash.Insert( "(NumpadDel)", Func("delete"))
	KeyFunctionHash.Insert( "{S---}(NumpadDiv)", Func("tabPrevious"))
	KeyFunctionHash.Insert( "{S---}(NumpadMult)", Func("tabNext"))
	KeyFunctionHash.Insert( "{S---}(NumpadSub)", Func("selToStart"))
	KeyFunctionHash.Insert( "{S---}(NumpadAdd)", Func("selToEnd"))
	KeyFunctionHash.Insert( "{S---}(NumpadHome)", Func("windowPrev"))
	KeyFunctionHash.Insert( "{S---}(NumpadUp)", Func("stepOutDebug"))
	KeyFunctionHash.Insert( "{S---}(NumpadPgUp)", Func("windowNext"))
	KeyFunctionHash.Insert( "{S---}(NumpadLeft)" , Func("stepOverDebug"))
	KeyFunctionHash.Insert( "{S---}(NumpadClear)", Func("stepIntoDebug"))
	KeyFunctionHash.Insert( "{S---}(NumpadRight)", Func("resumeExec"))
	KeyFunctionHash.Insert( "Eclipse{S---}(NumpadLeft)" , Func("stepOverDebugEclipse"))
	KeyFunctionHash.Insert( "Eclipse{S---}(NumpadClear)", Func("stepIntoDebugEclipse"))
	KeyFunctionHash.Insert( "Eclipse{S---}(NumpadRight)", Func("resumeExecEclipse"))
	KeyFunctionHash.Insert( "{S---}(NumpadEnd)", Func("findRefs"))
	KeyFunctionHash.Insert( "{S---}(NumpadDown)", Func("goToDefinition"))
	KeyFunctionHash.Insert( "{S---}(NumpadPgDn)", Func("backFromDefinition"))
	KeyFunctionHash.Insert( "Eclipse{S---}(NumpadEnd)", Func("findRefsEclipse"))
	KeyFunctionHash.Insert( "Eclipse{S---}(NumpadDown)", Func("goToDefinitionEclipse"))
	KeyFunctionHash.Insert( "Eclipse{S---}(NumpadPgDn)", Func("backFromDefinitionEclipse"))
	KeyFunctionHash.Insert( "{S---}(NumpadEnter)", Func("backSpace"))
	KeyFunctionHash.Insert( "{S---}(NumpadDel)", Func("space"))

	; Shell BINDINGS
	KeyFunctionHash.Insert("Shell(NumpadLeft)", Func("shellCopy"))
	KeyFunctionHash.Insert("Shell(NumpadClear)", Func("shellPaste"))
	KeyFunctionHash.Insert("Shell(NumpadRight)", Func("shellCut"))

	; CRUSADER BINDINGS
	KeyFunctionHash.Insert("Crusader(NumpadLeft)", Func("crusaderGranary"))
	KeyFunctionHash.Insert("Crusader(NumpadClear)",  Func("crusaderPause"))
	KeyFunctionHash.Insert("Crusader(NumpadRight)", Func("crusaderMarket"))

	KeyFunctionHash.Insert("Crusader(NumpadEnd)", Func("crusaderBarracks"))
	KeyFunctionHash.Insert("Crusader(NumpadDown)", Func("crusaderMercenaryPost"))
	KeyFunctionHash.Insert("Crusader(NumpadPgDn)", Func("crusaderEngineeringSchool"))

	KeyFunctionHash.Insert("Crusader(NumpadEnter)", Func("crusaderShowFloorplan"))
	KeyFunctionHash.Insert("Crusader(NumpadAdd)", Func("crusaderHalt"))

	KeyFunctionHash.Insert("Crusader(NumpadHome)", Func("crusaderSelectBattleGroup7"))
	KeyFunctionHash.Insert("Crusader(NumpadUp)", Func("crusaderSelectBattleGroup8"))
	KeyFunctionHash.Insert("Crusader(NumpadPgUp)", Func("crusaderSelectBattleGroup9"))

	KeyFunctionHash.Insert("Crusader(NumpadDiv)", Func("CrusaderCreateBattleGroup7"))
	KeyFunctionHash.Insert("Crusader(NumpadMult)", Func("CrusaderCreateBattleGroup8"))
	KeyFunctionHash.Insert("Crusader(NumpadSub)", Func("CrusaderCreateBattleGroup9"))
	KeyFunctionHash.Insert("Crusader{S---}(NumpadHome)", Func("CrusaderCreateBattleGroup7"))
	KeyFunctionHash.Insert("Crusader{S---}(NumpadUp)", Func("CrusaderCreateBattleGroup8"))
	KeyFunctionHash.Insert("Crusader{S---}(NumpadPgUp)", Func("CrusaderCreateBattleGroup9"))
 }	

GetModifierState()
{
	global IsSftDown
	global IsCtlDown
	global IsWinDown
	global IsAltDown

	state := "{"
	state := state . (IsSftDown ? "S":"-")
	state := state . (IsCtlDown ? "C":"-")
	state := state . (IsWinDown ? "W":"-")
	state := state . (IsAltDown ? "A":"-")
	state := state . "}"
		
	return state 
}


 NumpadDiv::
 NumpadMult::
 NumpadSub::
 NumpadAdd::
 NumpadHome::
 NumpadUp::
 NumpadPgUp:: 
 NumpadLeft::
 NumpadClear::
 NumpadRight::
 NumpadEnd::
 NumpadDown::
 NumpadPgDn::
 NumpadEnter::
 NumpadDel::	HandleKeypad(A_ThisHotkey)
	return     

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Modifier key handlers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NotifyModState()
{
	modState := GetModifierState()
	OutputDebug, "ModState " %modState%
	;TrayTip, "ModState", %modState%, , 2
}

SetShiftOn()
{
	global IsSftDown
	IsSftDown := true
	NotifyModState()
}

SetShiftOff()
{
	global IsSftDown
	IsSftDown := false
	NotifyModState()
}

SetAltOn()
{
	global IsAltDown
	IsAltDown := true
	NotifyModState()
}

SetAltOff()
{
	global IsAltDown
	IsAltDown := false
	NotifyModState()
}

SetCtlOn()
{
	global IsCtlDown
	IsCtlDown := true
	NotifyModState()
}

SetCtlOff()
{
	global IsCtlDown
	IsCtlDown := false
	NotifyModState()
}

SetWinOn()
{
	global IsWinDown
	IsWinDown := true
	NotifyModState()
}

SetWinOff()
{
	global IsWinDown
	IsWinDown := false
	NotifyModState()
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Short Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



backSpace()
{
	Send, {Backspace}
}

bookmarkPage()
{
	Send ^d
	ToolTip, "Bookmarking"
	Sleep, 500
}

clickLeft()
{
	Click, Left
}

clickMiddle()
{
	Click, Middle
}

clickRight()
{
	Click, Right
}

closeTab()
{
	Send ^w
}

computerSaysNo() 
{	
	; gBox, Computer Says: 'No.'	
	TrayTip, Computer Says: 'No.'
}

commenceExecution()
{
	ef5()
}

copy()
{		
	Send, ^c
}

cut()
{
	Send, ^x
}

delete()
{
	Send, {Del}
}

diskRoot()
{
	Send, #e
}

donothing()
{
	return true
}

ef5()
{
	Send, {F5}
}

enter()
{
	Send, {Enter}
}

find()
{
	Send, ^f
}


 
goBeginDoc()
{
  Send, ^{Home}
} 

goEndDoc()
{
  Send, ^{End}
}

findRefs()
{
	Send, +{F12}
} 


findRefsEclipse()
{
	Send, ^+g
} 
 
goToDefinition()
{
	Send {F12}
}

 
goToDefinitionEclipse()
{
	Send {F3}
}

backFromDefinition()
{
	Send, ^-
}


backFromDefinitionEclipse()
{
	Send, !{Left}
}

notImplemented(message)
{
	global groovyMode
	TrayTip, "Not Implemented: " %message% , %groovyMode%, 2
}

; -----
openSaveDialog()
{
	Click Right
	Sleep, 100
	Send v
	Sleep, 100
	Send {Home}
}

paste()
{
	Send, ^v
}

prefixFileName()
{
	Send {Home}
	Sleep, 100
	Send ^v
}

renameAction()
{
	global groovyMode
	if groovyMode=1
		xxx:= ""
	else if groovyMode=3
		xxx:= ""
	Send, {F2}	
}

rename()
{
	Send, {F2}

}


resumeExec()
{
	Send, {F5}
}

resumeExecEclipse()
{
	Send, {F8}
}
saveThenCloseDialog()
{
	Send !s
}
  
save()
{
	Send, ^s
	SetTitleMatchMode 2
	IfWinActive, .ahk
	{
		Sleep, 1000
		ToolTip, Reloading...
		Sleep, 500
		Reload
	}
	return
}

searchBack()
{
	Send, +{F3}
}

searchForward()
{
	Send, {F3}
}

selectAll()
{
	Send, ^a
}

selToStart()
{
	Send, +{Home}
}

selToEnd()
{
	Send, +{End}	
}

space()
{
	Send, {Space}	
}

startDebug()
{
	global groovyMode
	if (groovyMode=1)
		xxx:= ""
	if (groovyMode=3)
		Send, {F11}
}

stepOutDebug()
{
	Send, +{F11}
}

stepOverDebug()
{
	Send, {F10}
}

stepIntoDebug()
{
	Send, {F11}
}


;EclipseEclipseEclipseEclipse
stepOutDebugEclipse()
{
	Send, {F6}
}

stepOverDebugEclipse()
{
	Send, {F6}
}

stepIntoDebugEclipse()
{
	Send, {F5}
}

stopDebug()
{
	global groovyMode
	if (groovyMode=1)
		xxx:= ""
	if (groovyMode=3)
		Send, ^{F2}
}

tabNext()
{
	Send, ^{Tab}
}

tabPrevious()
{
	Send, ^+{Tab}
}

toggleBreakpoint() 
{
	global groovyMode
	if groovyMode=1
		Send, {F9}
	else if groovyMode=3
		notImplemented("No toggleBreakpoint() defined for Eclipse")
	else if groovyMode=5
		Send, {F9}
}

tt(flash)
{
	TrayTip, %flash% , "", 2
}
 
undo()
{
	Send, ^z
}
 
windowNext()
{
	global WinStepper ;
	WinStepper := applyWinStepLimits(WinStepper + 1)
	windowFocus()
}

windowPrev()
{
	global WinStepper ;
	WinStepper := applyWinStepLimits(WinStepper - 1)
	windowFocus()
}

applyWinStepLimits(winStepper)
{
	if(winStepper > 4)
	{
		return 1
	}
	else if (winStepper < 1)
	{
		return 4
	}
	else
	{
		return winStepper
	}
}

windowFocus()
{
	global WinStepper ;
	global WinMax ;
	target := Mod(WinStepper , WinMax)
	targetString := "#" . target
	OutputDebug, targetString:%targetString%
	Send, %targetString%
	WinStepper = %target%
}

WindowMoverTest()
{
	; WinGetActiveStats, Title, Width, Height, X, Y 
	mtTitle := ""
	mtWidth := 0
	mtHeight := 0
	mtX := 0
	mtY := 0
	WinGetActiveStats, mtTitle, mtWidth, mtHeight, mtX, mtY
	;WinMaximize , %mtTitle%
	;WinGetActiveStats, mtTitle, mtWidth, mtHeight, mtX, mtY
	OutputDebug, maxPos:%mtWidth% - %mtHeight% - %mtX% - %mtY%
	;WinRestore , %mtTitle%
	halfWidth := floor(mtWidth / 2)
	halfHeight := floor(mtHeight / 2)
	halfX := mtX +  halfWidth
	halfY :=  mtY + halfHeight
	OutputDebug, halfPos:%halfWidth% - %halfHeight% - %halfX% - %halfY%
	WinMove,  %mtTitle% , , %halfWidth% , %halfHeight% , %halfX% ,%halfY%
	;WinMove,  %mtTitle% , , 100 , 100 , 400 , 400
	;WinMove, 400 , 400
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; SHELL FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
shellCopy() 
{
	Click, Right
}

shellPaste() 
{
	Click, Right
}

shellCut() 
{
	Send, {Backspace}
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; CRUSADER FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
crusaderMarket() 
{
	Send, {Control Down}
	Send, m
	Send, {Control Up}
}
		
crusaderPause()	
{
	Send, p
}
		
crusaderBarracks() 
{
	Send, {Control Down}
	Send, b
	Send, {Control Up}
}

crusaderMercenaryPost() 
{
	Send, {Control Down}
	Send, n
	Send, {Control Up}
}

crusaderEngineeringSchool()
{
	Send, {Control Down}
	Send, i
	Send, {Control Up}
}

crusaderGranary() 
{
	Send, {Control Down}
	Send, g
	Send, {Control Up}
}

crusaderShowFloorplan() 
{
	Send, {Space}

}

crusaderHalt() 
{
	Send, s
}

crusaderCreateBattleGroup7() 
{
	SoundBeep , 261, 125
	Send, {Control Down}
	Send, 7
	Send, {Control Up}	
	SoundBeep , 130, 125
}

crusaderCreateBattleGroup8() 
{
	SoundBeep , 261, 125
	Send, {Control Down}
	Send, 8
	Send, {Control Up}	
	SoundBeep , 130, 125
}

crusaderCreateBattleGroup9() 
{
	SoundBeep , 261, 125
	Send, {Control Down}
	Send, 9
	Send, {Control Up}	
	SoundBeep , 130, 125
}

crusaderSelectBattleGroup7() 
{
	SoundBeep , 522, 125
	Send, 7
	SoundBeep , 1044, 125	
}

crusaderSelectBattleGroup8() 
{
	SoundBeep , 522, 125
	Send, 8
	SoundBeep , 1044, 125
}

crusaderSelectBattleGroup9() 
{
	SoundBeep , 522, 125
	Send, 9
	SoundBeep , 1044, 125	
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  ABBREVIATIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

:*:pdat;f::  ; pretty date
formattime, currentdatetime,, ddd, d MMM yyyy	  ; it will look like: "Fri, 1 Oct 2010"
sendinput %currentdatetime%
return

:*:mdat;f::  ; sortable parseable date with time
formattime, currentdatetime,, yyyyMMdd	  ; it will look like: "20100904" 
sendinput %currentdatetime%
return

:*:pdt;f::  ; pretty date with time
formattime, currentdatetime,, ddd, d MMM yyyy, HH:mm	  ; it will look like: "Fri, 1 Oct 2010, 23:12"
sendinput %currentdatetime%
return

:*:mdt;f::  ; sortable parseable date with time
formattime, currentdatetime,, yyyyMMdd_HHmm	  ; it will look like: "20100904_2109" 
sendinput %currentdatetime%
return

:*:sea;f:: ; setup - execute - assert comments
sendinput //SETUP {Return}{Home}{Return}{Return}
sendinput //EXECUTE {Return}{Home}{Return}
sendinput //ASSERT {Return}{Home}{Return}
sendinput  {Up}{Up}{Up}{Up}{Up}{Up}{Tab}
return


:*:c.a.;f:: ;
sendinput com.anderspel.
return

:*:ase;f:: ;
sendinput assertEquals( , );{Left}{Left}{Left}{Left}{Left}
return


:*:gs;f:: 
sendinput git status
return

:*:ga;f:: 
sendinput git add -A .
return

:*:gc;f:: 
sendinput git commit -m ""{Left}
return


;:*:gpom;f:: 
;sendinput git push origin master
;return


:*:g--;f:: 
sendinput git checkout -- .
return

:*:srt;f:: 
sendinput stephen richard tennant{Enter}
return
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  COMPATIBILITY SHORTCUTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#a::
	run , "C:\Program Files (x86)\Notepad++\notepad++.exe" "\\fedfps\UserData\albertg\My Documents\Advice\advice.txt"	
	return

#c::
	Run, C:\Windows\system32\cmd.exe "/T:9F",  d:/home/albert/Personal/Batchfiles
	return	
	
#f:: ;Firefox
	Run, "C:\Program Files\Mozilla Firefox\firefox.exe"
	return
 
#g:: ;g(GO!:: Startup)
	Run, "D:\Google Drive 2\Google Drive"
	return

#k:: ;!control panel
	Run, control
	return	
 
#y:: ;
	Run, powercfg.cpl
	return

#z:: ; !manage computer
	Run, compmgmt.msc
	return
 
#,:: ; !shortcuts
	Run, "C:\Shortcuts"
	return

#=::
	Run, "C:\Program Files\TrueCrypt\TrueCrypt.exe" "D:\home\albert\Personal\Advice\vluff.tc"
	return	
 
#x:: ; !manage computer
	WindowMoverTest()
	return 
 
 
~^s::
	SetTitleMatchMode 2
	IfWinActive, .ahk
	{
		Sleep, 1000
		ToolTip, Reloading...
		Sleep, 500
		Reload
	}
	return

 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  MODIFIER KEY SHORTCUTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

~LShift::
~RShift::
NumpadIns::
	SetShiftOn()
	return
	
~LShift UP::	
~RShift UP::	
NumpadIns UP::
 SetShiftOff()
return

~LAlt::
~RAlt::	
	SetAltOn()
return
	
~LAlt UP::	
~RAlt UP::
 SetAltOff()
return
	
~LControl::
~RControl::	
	SetCtlOn()
return
	
~LControl UP::	
~RControl UP::
 SetCtlOff()
return		

~RButton::	
~LWin::
~RWin::
 SetWinOn()
 return
  	
~RButton UP::
~LWin UP::	
~RWin UP::
 SetWinOff()
 return
 
~NumLock::
 KeyIsDown := GetKeyState("NumLock" , "T")
 if (KeyIsDown = 0)
	{
		ShortcutState = Numpad 
	}
	else
	{
		ShortcutState = Shortcuts
	}
 TrayTip, NumLock Toggle, %ShortcutState% 
 return

 	; #!^+
	
#!^+F10::
	TrayTip, A
	return

#!^+F11::
	TrayTip, B
	return
		
 
#!^+F12::
	TrayTip, C
	return
		
 
