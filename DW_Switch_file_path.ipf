

Window Panel0() : Panel

PauseUpdate; Silent 1 // building window …
NewPanel /W=(150,50,450,212)
variable/g root:gRadioVal= 1
CheckBox check0,pos={52,25},size={78,15},title="Home/Imaging PC File Path (default)"
CheckBox check0,value=0,mode=1,proc=MyCheckProc
CheckBox check1,pos={52,45},size={78,15},title="Office PC File Path"
CheckBox check1,value=0,mode=1,proc=MyCheckProc
CheckBox check2,pos={52,65},size={78,15},title="Mac File Path"
CheckBox check2,value= 0,mode=1,proc=MyCheckProc
CheckBox check3,pos={52,85},size={78,15},title="Laptop File Path"
CheckBox check3,value= 0,mode=1,proc=MyCheckProc
CheckBox check4,pos={52,105},size={78,15},title="Work Laptop File Path"
CheckBox check4,value= 0,mode=1,proc=MyCheckProc
Button button1,pos={75,120},size={161,35},proc= ButtonProc,title="Accept"

EndMacro


//Function ButtonProc(ctrlName) : ButtonControl
///    String ctrlName   
//    KillWindow Panel0
//End

Function ButtonProc(ctrlName) : ButtonControl
   String ctrlName   
    KillWindow Panel0
End





Function MyCheckProc(name,value)

String name
Variable value
String/g root:gCustomPath

NVAR gRadioVal= root:gRadioVal
SVAR gCustomPath = root:gCustomPath
strswitch (name)
case "check0":
gRadioVal= 1
//gCustomPath=  "C:\\Users\\Damian\\Desktop\\"
gCustomPath=  "C:\\Users\\Damian\\Dropbox\\TEMP\\Ephys Igor output\\"
break
case "check1":
gRadioVal= 2 
gCustomPath= "C:\\Users\\dw2471\\Dropbox\\TEMP\\Ephys Igor output\\"
break
case "check2":
gRadioVal= 3 
gCustomPath = "Untitled:Users:damianwilliams:Dropbox:TEMP:Ephys Igor output:"
break
case "check3":
gRadioVal=4 
gCustomPath= "C:\\Users\\Damian\\Dropbox\\TEMP\\Ephys Igor output\\"
break
case "check4":
gRadioVal=5 
gCustomPath= "C:\\Users\\dw2471\\Dropbox\\TEMP\\Ephys Igor output\\"
break
endswitch
CheckBox check0,value= gRadioVal ==1 
CheckBox check1,value= gRadioVal ==2 
CheckBox check2,value= gRadioVal ==3 
CheckBox check3,value= gRadioVal ==4 
CheckBox check4,value= gRadioVal ==5
End


/////////////////////Switch Ca imaging folders


Window Panel1() : Panel

PauseUpdate; Silent 1 // building window …
NewPanel /W=(150,50,450,212)
variable/g root:gRadioValCa= 1
CheckBox check0,pos={52,25},size={78,15},title="Home/Imaging PC File Path Ca(default)"
CheckBox check0,value=0,mode=1,proc=MyCheckProcCa
CheckBox check1,pos={52,45},size={78,15},title="Office PC File Path Ca"
CheckBox check1,value=0,mode=1,proc=MyCheckProcCa
CheckBox check2,pos={52,65},size={78,15},title="Mac File Path Ca"
CheckBox check2,value= 0,mode=1,proc=MyCheckProcCa

Button button1,pos={75,100},size={161,35},proc=buttonprocCa,title="Accept"

EndMacro


Function ButtonProcCa(ctrlName) : ButtonControl
    String ctrlName
   
    KillWindow Panel1
End



Function MyCheckProcCa(name,value)

String name
Variable value
String/g root:gCustomPathCa

NVAR gRadioValCa = root:gRadioValCa
SVAR gCustomPathCa = root:gCustomPathCa
strswitch (name)
case "check0":
gRadioValCa= 1
gCustomPathCa=  "C:\\Users\\Damian\\Dropbox\\TEMP\\Calcium Igor output\\"
break
case "check1":
gRadioValCa= 2 
gCustomPathCa= "C:\\Users\\dw2471\\Dropbox\\TEMP\\Calcium Igor output\\"
break
case "check2":
gRadioValCa= 3 
gCustomPathCa = "Macintosh HD:Users:damianwilliams:Dropbox:TEMP:Calcium Igor output:"
break
endswitch
CheckBox check0,value= gRadioValCa ==1 
CheckBox check1,value= gRadioValCa ==2 
CheckBox check2,value= gRadioValCa ==3 
End
