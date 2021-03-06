#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, force
CoordMode, Mouse, Client

/*
ECU Type & Number Associated

	(1) 400 867 [135]
	(2) 400 867 [136]
	(3) 400 867 [137]
	(4) 400 867 [138]
	
	(5) 400 864 [831]
	(6) 400 864 [832]
	(7) 400 864 [833]
	(8) 400 864 [834]
	
*/

global ECU_Send :=

Main_Menu(){
	InputBox, Main_Menu_Input, Main_Menu,
	(LTrim
		Welcome to AutoUDT by Richard.
		Please input the number to the corresponding menu selection
		(1) 400 867 [135]
		(2) 400 867 [136]
		(3) 400 867 [137]
		(4) 400 867 [138]
		(5) 400 864 [831]
		(6) 400 864 [832]
		(7) 400 864 [833]
		(8) 400 864 [834]
	)
	If ErrorLevel
		Exit
	Else
	{
		UserInput := Main_Menu_Input
		if (UserInput = 1){
			ECU_Send := "400 867 135 0_4S4M ESC ATC.par"
		}
		else if (UserInput = 2){
			ECU_Send := "400 867 136 0_4S4M ESC HSA ATC.par"
		}
		else if (UserInput = 3){
			ECU_Send := "400 867 137 0_6S6M ESC ATC.par"
		}
		else if (UserInput = 4){
			ECU_Send := "400 867 138 0_6S6M ESC HSA ATC.par"
		}
		else if (UserInput = 5){
			ECU_Send := "400 864 831 0_4S4M ATC.par"
		}
		else if (UserInput = 6){
			ECU_Send := "400 864 832 0_4S4M HSA ATC.par"
		}
		else if (UserInput = 7){
			ECU_Send := "400 864 833 0_6S6M ATC.par"
		}
		else if (UserInput = 8){
			ECU_Send := "400 864 834 0_6S6M HSA ATC.par"
		}
		else{
			MsgBox, "Please enter a valid input."
			Main_Menu()
		}
	}
}

ErrorMsg(){ ; Stops program if error and restarts
	MsgBox, "Error! Please restart script."
	exit
}

Initialisation_Failed(){ 
	ifwinexist, ahk_class TfrmInitDIErrorHandler
	{
		Send, {ENTER}	
		Send, {ENTER}	
		Close_UDT()
		MsgBox, "Error! Restarting"
		Return, False
	}
}

Close_UDT(){ ; Closes Program
	Loop{
		ifwinexist, ahk_class TUDSForm
			WinClose ahk_class TUDSForm		
			ifwinexist, ahk_class #32770
				return, false
		ifwinnotexist, ahk_class TUDSForm
			break
	}
}

Starting_UDT_and_Disgnostic(){ ; Opens UDT & Puts it in Diagnostic Mode (Steps 4-5)
	run, C:\Program Files (x86)\WABCO Diagnostic Software\UDT\V6.50 (en)\UDT.exe
	WinWaitActive ahk_class #32770
	send, {enter} 
	Sleep, 100
	WinMove, ahk_class TUDSForm,, 0, 0, 1000, 750
	WinActivate, ahk_class TUDSForm
	MouseClick, left,  23, -14
	Sleep, 100
	MouseClick, left,  32, 6 ; Opens file explorer 
	Sleep, 100
	ifwinnotexist, ahk_class TUDSForm ; Makes sure window is open
		ErrorMsg()
	WinMenuSelectItem, ahk_class #32770, ,mBSP_UDS - ECU Reflash.UDT
	WinMove, ahk_class #32770,, 0, 0, 1000, 750
	WinWaitActive, ahk_class #32770
	Sleep, 100
	ifwinnotexist, ahk_class #32770 ; Makes sure window is open
		ErrorMsg()	
	MouseClick, left, 232, 109 ; Selects mBSP_UDS - ECU Reflash.UDT
	Send, {ENTER}	
}

Check_for_Connection_Error(){
	ifwinexist, ahk_class TWInitEcuEH
	{
		Send, {ENTER}	
		Send, {ENTER}	
		Close_UDT()
		MsgBox, "ECU not connected"
		Return, False
	}
}

mBSP_ECU_Reflash_Configuation(){ ; Step 7; Step 27
	; checks for UDT error and skips step 8 if error occurs
	Sleep, 2000
	ifwinexist, ahk_class TMessageForm
	{
		WinActivate, ahk_class TMessageForm
		Send, {ENTER}
	}else{
		Extended_Sess_Config()
	}
}

Extended_Sess_Config(){
	WinActivate, ahk_class TUDSForm
	MouseClick, left, 292, 30
	Sleep, 100
	MouseClick, left, 343, 118
	Sleep, 100
}

Step_8(){
	WinActivate, ahk_class TUDSForm
	MouseClick, left, 292, 30
	Sleep, 100
	MouseClick, left, 347, 97
	Sleep, 100
}

Step_9(){
	WinActivate, ahk_class TUDSForm
	MouseClick, left, 801, 31
	Sleep, 100
	MouseClick, left, 831, 73
	Sleep, 100
}

Enter_Pin(){
	Sleep, 500
	IfWinExist, ahk_class TWPin
		WinWaitActive, ahk_class TWPin
		Send, 9758{ENTER} ; insert pin	
	Sleep, 100
}

Step_10_File_Selection(){
	WinWait, ahk_class #32770
	WinMove, ahk_class #32770,, 0, 0, 1000, 750
	WinActivate, ahk_class #32770
	; Locate correct file location
	MouseClick, left, 688, 16
	Sleep, 100
	Send, {BACKSPACE}
	Send, C:\Users\grtwh\Documents\AICP_1_191_1_20_1_5_DAG_GABS_CEEA_1.3_Trunk-INC3.3-1903_IF2\Application\NorthAmerica_12V\Output
	Send, {ENTER}
	Sleep, 100
	; Verifies that "All files" is selected
	WinActivate, ahk_class #32770
	MouseClick, left, 925, 650
	Sleep, 100
	Send, {a}{ENTER}
	Sleep, 100
	; Finds "Global.hex"
	WinActivate, ahk_class #32770
	Send, ^f
	Sleep, 3000
	Send, MBSP_ABS_Global.hex
	Sleep, 100
	Send, {ENTER}
	Sleep, 3000
	Send, {TAB}{TAB}{UP}
	Sleep, 100
	Send, {ENTER}
}

Download_Timer(){ ; Step 12
	Sleep, 100
	WinWaitActive, ahk_class TDownloadMainForm	
	WinMove, ahk_class TDownloadMainForm,, 0, 0, 1000, 750
	WinActivate, ahk_class TDownloadMainForm	
	Sleep, 5000
	Loop{
		ifwinnotexist, ahk_class TDownloadMainForm
			break
	}
	Sleep, 1000
}

Exit_ECU_Diagnostic(){ ; Step 13 & 22
	WinActivate, ahk_class TUDSForm
	Sleep, 1000
	MouseClick, left, 231, 32
	Sleep, 3000
}

Step_14(){
	WinActivate, ahk_class TUDSForm
	MouseClick, left, 108, 32
	Sleep, 3000
}

Step_15(){
	WinActivate, ahk_class TUDSForm
	MouseClick, left, 300, 30
	Sleep, 100
	MouseClick, left, 340, 164
	Sleep, 1000
}

Open_Hex(){ ; Step 16 & 33
	WinActivate, ahk_class TUDSForm
	MouseClick, left, 427, 26
	Sleep, 300
	IfWinExist, ahk_class TWPin
		Enter_Pin()
	Sleep, 100
}

Hex_Commands(){ ; Steps 17-21
	WinActivate, ahk_class TUDSForm
	Send, {TAB}{TAB}{TAB}
	Sleep, 1000
	loop, 4
	{
		Send, {ENTER}
		Sleep, 1000
		Send, {DOWN}
		Sleep, 1000		
	}
	Send, {ENTER}
	Sleep, 1000
}

Select_ECU_Parameter_Button(){ ; Step 28, 35
	WinActivate, ahk_class TUDSForm
	MouseClick, left, 675, 30
	Sleep, 100
	MouseClick, left, 704, 104
	Sleep, 500
	Enter_Pin()
	Sleep, 1000
	WinActivate, ahk_class TParametriertool
	WinMove, ahk_class TParametriertool,, 0, 0, 1000, 750
}

Read_ECU(){
	WinActivate, ahk_class TParametriertool
	MouseClick, left, 20, 625
	Sleep, 100
	loop{
		IfWinNotExist, ahk_class THinweisDlg
		{
			Step_30()
			break
		}
	}
}

Step_30(){
	WinActivate, ahk_class TParametriertool
	MouseClick, left, 126, 625
	Sleep, 100
	WinMove, ahk_class #32770,, 0, 0, 1000, 750
	WinActivate, ahk_class #32770
	MouseClick, left, 688, 16
	Sleep, 100	
	Send, {BACKSPACE}
	Send, C:\Users\grtwh\Documents\mBSPProductionParameters
	Send, {ENTER}	
}

Select_File(){
	WinActivate, ahk_class #32770
	Send, ^f
	Sleep, 3000
	Send, %ECU_Send%
	Sleep, 100
	Send, {ENTER}
	Sleep, 3000
	Send, {TAB}{TAB}{UP}
	Sleep, 100
	Send, {ENTER}
}

Step_31(){
	Sleep, 500
	WinActivate, ahk_class TFrageParaLadenDlg
	Send, {TAB}{ENTER}
	Sleep, 1000
}

Step_32(){
	WinActivate, ahk_class TParametriertool
	Sleep, 100
	MouseClick, left, 70, 630
	Sleep, 500
	WinActivate, ahk_class TWriteEcuParaDlg
	Send, {ENTER}
	Sleep, 20000
	WinActivate, ahk_class TParametriertool
	MouseClick, left, 920, 650
	Sleep, 100
}

Step_34(){
	loop, 3
		Send, {TAB}
	Sleep, 100
	loop, 2
		Send, {DOWN}
	Sleep, 100
	Send, {ENTER}
}

Step_36(){
	Sleep, 1000
	WinActivate, ahk_class TParametriertool
	Sleep, 100
	MouseClick, left, 24, 630
	Sleep, 10000
}

Step_37(){
	Sleep, 1000
	Mouseclick, left, 830, 200
	Sleep, 1000
}

While True{
	Main_Menu()
	Close_UDT()
	Starting_UDT_and_Disgnostic() ; Steps 4-5
	Check_for_Connection_Error()
	mBSP_ECU_Reflash_Configuation()
	; Step 7 is skipped because of conditional UDT error
	Step_8()
	Step_9()
	Enter_Pin()
	Step_10_File_Selection()
	Download_Timer() ; Step 12
	Exit_ECU_Diagnostic() ; Step 13
	Step_14()
	Step_15()
	Open_Hex()
	Hex_Commands()
	Exit_ECU_Diagnostic() ; Step 22
	Close_UDT() ; Step 23
	Starting_UDT_and_Disgnostic() ; Step 24-26
	mBSP_ECU_Reflash_Configuation() ; Step 27
	Select_ECU_Parameter_Button()
	Read_ECU()
	Step_30()
	Select_File()	
	Step_31()
	Step_32()
	Open_Hex() ; Step 33
	Step_34()
	Select_ECU_Parameter_Button() ; Step 35
	Step_36()
	Step_37()
	Step_30()
	Select_File()
	Sleep, 500
	WinActivate, ahk_class TFrageParaLadenDlg
	Sleep, 100
	Send, {ENTER}
	break
}

Esc::ExitApp  ; Exit script with Escape key