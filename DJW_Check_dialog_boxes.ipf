#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Function StaCheck()// : Panel

//variable/g root:gRadioVal= 1
//variable/g root:gRadioVal= 2

//SetDataFolder root:

//SVAR gCellFolderName
//SetDataFolder $(gCellFolderName)



//SVAR gCell_ID
//NVAR gRMP
//NVAR gVCCap
//NVAR gLeakCurrent
//NVAR gScaleCurr

//NewPanel/N=StaPanel /W=(150,50,450,190)

//Setdrawenv fsize=18,fstyle=1//,textrgb=(65535,65535,65535)
//drawtext 4,32,"Cell ID:\t\t\t\t\t\t\t\t\t\t"+gCell_ID
//Setdrawenv fsize=18,fstyle=1//,textrgb=(65535,65535,65535)
//drawtext 4,62,"RMP:\t\t\t\t\t\t\t\t\t\t\t\t"+num2str(gRMP)+" mV"
//Setdrawenv fsize=18,fstyle=1//,textrgb=(65535,65535,65535)
//drawtext 4,92,"VC Capacitance:\t"+num2str(gVCCap)+" pF"
//Setdrawenv fsize=18,fstyle=1//,textrgb=(65535,65535,65535)
//drawtext 4,122,"Leak Current:\t\t\t\t"+num2str(gLeakCurrent)+" pA"

//StaWindowHook()

//PauseForUser StaPanel


//End



//Function MyWindowHookSta(s)
//STRUCT WMWinHookStruct &s
//Variable hookResult = 0 // 0 if we do not handle event, 1 if we handle it.

//switch(s.eventCode)

//case 11: // Keyboard event
//switch (s.keycode)

//case 13:
//Print "Continue"
//KillWindow StaPanel
//SaveEverything()
//AutoDelUnwantedFolders()
//hookResult = 1
//break
//endswitch
//break
//endswitch
//return hookResult // If non-zero, we handled event and Igor will ignore it.
//End


//Function StaWindowHook()
//SetWindow kwTopWin, hook(MyHook)=MyWindowHookSta // Install window hook

//End


////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////


//Function CheckScaling()// : Panel

//SVAR gCellFolderName = root:gCellFolderName
//DFREF CellFolderDFR = $gCellFolderName
//setdatafolder CellFolderDFR

//SVAR gCell_ID


//SVAR gHyperpolFold
//setdatafolder $gHyperpolFold

//Original gain I_sec
//NVAR Im_sec_gain


//setdatafolder root:

//Manual adjustment 
//NVAR gAutoScaleCurr
//NVAR gBaselineScaleCurr


//setdatafolder CellFolderDFR

//Original Rmem
//NVAR gInputResistance

//NVAR gRm
//NVAR gRmOrig
//NVAR gInputResistance
//NVAR gRmAuto

///Original Cap
//NVAR gCapacitance
//NVAR gAvRiseTau
//NVAR gAvFallTau


//NVAR gCapTauOrig
//NVAR gCapTauManual
//NVAR gCapTauAuto



//Variable/g gCapTauOrig = ((gRmOrig*1e6)/gAvRiseTau/1e3))*1e12
//Variable/g gCapTauManual = ((gRmManual*1e6/gAvRiseTau/1e3))*1e12
//Variable/g gCapTauAuto = ((gRmAuto*1e6)*(gAvRiseTau/1e3))*1e12
//


//NewPanel/N=CheckScales /W=(150,50,630,400)

//Setdrawenv fsize=18,fstyle=1//,textrgb=(65535,65535,65535)
//drawtext 4,32,"Unadjusted Rm:\t\t\t\t\t\t\t"+ num2str(gRmOrig)+" MOhm"
//Setdrawenv fsize=18,fstyle=1//,textrgb=(65535,65535,65535)
//drawtext 4,62,"Manual adjusted Rm:\t\t"+num2str(gInputResistance)+" MOhm"
//Setdrawenv fsize=18,fstyle=1//,textrgb=(65535,65535,65535)
//drawtext 4,92,"File adjusted Rm:\t\t\t\t\t"+num2str(gRmAuto)+" MOhm"
//Setdrawenv fsize=18,fstyle=1//,textrgb=(65535,65535,65535)
//drawtext 4,122,"VC Rm:\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t"+ num2str(gRm)+" MOhm"


//Setdrawenv fsize=18,fstyle=1//,textrgb=(65535,65535,65535)
//drawtext 4,152,"Unadjusted Cap:\t\t\t\t\t\t\t"+ num2str(abs(gCapTauOrig))+" pF"
//Setdrawenv fsize=18,fstyle=1//,textrgb=(65535,65535,65535)
//drawtext 4,182,"Manual adjusted Cap:\t\t"+num2str(abs(gCapTauManual))+" pF"
//Setdrawenv fsize=18,fstyle=1//,textrgb=(65535,65535,65535)
//drawtext 4,212,"File adjusted Cap:\t\t\t\t\t"+num2str( abs(gCapTauAuto))+" pF"
//Setdrawenv fsize=18,fstyle=1//,textrgb=(65535,65535,65535)
//drawtext 4,242,"VC Cap:\t\t\t\t\t\t\t\t\t\t\t\t\t\t"+num2str(gCapacitance)+" pF"

////Setdrawenv fsize=18,fstyle=1//,textrgb=(65535,65535,65535)
//drawtext 4,292,"Manual Gain:\t\t\t\t\t\t\t\t\t\t\t"+num2str(gAutoScaleCurr)
//Setdrawenv fsize=18,fstyle=1//,textrgb=(65535,65535,65535)
//drawtext 4,322,"File Gain:\t\t\t\t\t\t\t\t\t\t\t\t\t\t"+num2str(Im_sec_gain)
//Setdrawenv fsize=18,fstyle=1//,textrgb=(65535,65535,65535)
//drawtext 4,352,"Baseline Gain:\t\t\t\t\t\t\t\t\t\t\t\t\t\t"+num2str(gBaselineScaleCurr)


//StaWindowHookCheck()

//PauseForUser CheckScales 


//End


//Function WindowHookSta(s)
//STRUCT WMWinHookStruct &s
//Variable hookResult = 0 // 0 if we do not handle event, 1 if we handle it.

//switch(s.eventCode)

//case 11: // Keyboard event
//switch (s.keycode)

//case 13:
//Print "Continue"
//KillWindow CheckScales

//hookResult = 1
//break
//endswitch
//break
//endswitch
//return hookResult // If non-zero, we handled event and Igor will ignore it.
//End


//Function StaWindowHookCheck()
//SetWindow kwTopWin, hook(MyHook)=WindowHookSta // Install window hook

//End







//Function Panel3()// : Panel


//NewPanel/N=KeepPanel /W=(150,50,450,120)

//Setdrawenv fsize=18,fstyle=1//,textrgb=(65535,65535,65535)
//drawtext 80,30,"Press 'k' to keep"
//Setdrawenv fsize=18,fstyle=1//,textrgb=(65535,65535,65535)
//drawtext 80,55,"Press 'd' to disgard"



//DemoWindowHook()
//
//PauseForUser KeepPanel


//End



//Function ButtonProcrt(ctrlName,) : ButtonControl
//string ctrlName 
//NVAR gRadioVal

//switch(gRadioVal) 
//case 1:

//break
//case 2:
//print "a is 2"
//AutoDelUnwantedFolders()
//KillWindow KeepPanel
//break
//endswitch


//End



//Function MyCheckProc2(name1,value)

//String name1
//Variable value
//Variable RadioVal

//strswitch (name1)
//case "check0":
//RadioVal= 1
//print "yeah"
//break
//case "check1":
//RadioVal= 2 
//print "nah"
//break

//endswitch
//CheckBox check0,value= RadioVal ==1 
//CheckBox check1,value= RadioVal ==2 

//Variable/g root:gRadioVal = RadioVal

//End





//Function MyWindowHook(s)
//STRUCT WMWinHookStruct &s
//Variable hookResult = 0 // 0 if we do not handle event, 1 if we handle it.

//switch(s.eventCode)

//case 11: // Keyboard event
//switch (s.keycode)

//case 107:
//Print "Continue"
//KillWindow KeepPanel
//SaveEverything()
//AutoDelUnwantedFolders()
//hookResult = 1
//break


//case 100:
//Print "Discard"
//KillWindow KeepPanel
AutoDelUnwantedFolders()

//hookResult = 1
//break
//endswitch
//break
//endswitch
//return hookResult // If non-zero, we handled event and Igor will ignore it.
//End


//Function DemoWindowHook()
//SetWindow kwTopWin, hook(MyHook)=MyWindowHook // Install window hook

//End


function AutoDelUnwantedFolders()

Variable i,VariableMatches,v,StrMatches,DFMatches
String CurrVar,CurrTraceID,CurrStr,CurrDF,CurrentFolderName

String VariablestoKeep =   "gAutoScaleVolt;gAutoScaleCurr;gBaselineScaleCurr,gDepolStep,gHypStep,gSelectedRadioButton"
String StringstoKeep = "gAnalysisType;gCustomPath;glistofFolders;gCapFolderPath,gPlateDate,gCell_subtype"


Setdatafolder root:


//Close remaining windows

string windowsopen = winlist("*",";","WIN:23")
variable numberofwindows = Itemsinlist(windowsopen,";")
variable n

for(n=0;n<numberofwindows;n+=1)
		string killthiswindow = StringFromList(n,windowsopen,";")
		print killthiswindow
		dowindow/K $killthiswindow
endfor


//Variables

String AllRemainingVariables = VariableList("*", ";",4)
Variable NumRemainingVariable = Itemsinlist(AllRemainingVariables)

i=0

for(i=0;i<NumRemainingVariable;i+=1)
CurrVar  = StringFromList(i, AllRemainingVariables)
VariableMatches = (Stringmatch(VariablestoKeep,"*"+CurrVar+"*"))
if (VariableMatches==0)
KillVariables/Z $CurrVar
endif
Endfor

//Strings

String AllRemainingStrings = StringList("*", ";")
Variable NumRemainingStrings = Itemsinlist(AllRemainingStrings)

i= 0

for(i=0;i<NumRemainingStrings;i+=1)
CurrStr  = StringFromList(i,AllRemainingStrings)
StrMatches = (Stringmatch(StringstoKeep,"*"+CurrStr+"*"))
if (StrMatches==0)
Killstrings/Z $CurrStr
endif
Endfor

//Folder


end


Window Panel2() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(17,54,317,254)
	CheckBox pp_check,pos={1.00,1.00},size={120.00,16.00},proc=CheckProc
	CheckBox pp_check,title="Analyse Paired Pulse",value=0
	
EndMacro




Function CheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			checkery()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End



Function checkery()
ControlInfo/W=Panel2 pp_check
print (v_value)
End


