#pragma rtGlobals=3		// Use modern global access method and strict wave access.


Function GenStaCheck()// : Panel

SetDataFolder root:
SVAR gCellFolderName

SetDataFolder gCellFolderName
SVAR gCell_ID
NVAR gCapacitance
NVAR gHold
NVAR gRa
NVAR gRm


NewPanel/N=CheckStaPanel /W=(150,50,450,300)

Setdrawenv fsize=18,fstyle=1//,textrgb=(65535,65535,65535)
drawtext 4,32,"Cell ID:\t\t\t\t\t\t\t\t\t\t"+gCell_ID

Setdrawenv fsize=18,fstyle=1//,textrgb=(65535,65535,65535)
drawtext 4,92,"Capacitance:\t"+num2str(gCapacitance)+" pF"

Setdrawenv fsize=18,fstyle=1//,textrgb=(65535,65535,65535)
drawtext 4,122,"Raccess:\t\t\t\t\t\t\t\t\t\t"+num2str(gRa)+" MOhm"

Setdrawenv fsize=18,fstyle=1//,textrgb=(65535,65535,65535)
drawtext 4,152,"Rmembrane:\t"+num2str(gRm)+" MOhm"

Setdrawenv fsize=18,fstyle=1//,textrgb=(65535,65535,65535)
drawtext 4,182,"Leak Current:\t\t\t\t"+num2str(gHold)+" pA"


CheckStaWindowHook()

PauseForUser CheckStaPanel


End



Function MyWindowHookCheckSta(s)
STRUCT WMWinHookStruct &s
Variable hookResult = 0 // 0 if we do not handle event, 1 if we handle it.

switch(s.eventCode)

case 11: // Keyboard event
switch (s.keycode)

case 13:
Print "Continue"
KillWindow CheckStaPanel
//SaveEverything()
//AutoDelUnwantedFolders()
hookResult = 1
break
endswitch
break
endswitch
return hookResult // If non-zero, we handled event and Igor will ignore it.
End


Function CheckStaWindowHook()
SetWindow kwTopWin, hook(MyHook)=MyWindowHookCheckSta // Install window hook
End