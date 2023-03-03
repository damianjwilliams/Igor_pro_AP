#pragma rtGlobals=3		// Use modern global access method and strict wave access.


function DelUnwantedFolders()

Variable i,VariableMatches,v,StrMatches,DFMatches
String CurrVar,CurrTraceID,CurrStr,CurrDF,CurrentFolderName

String VariablestoKeep =   "gScaleVolt;gScaleCurr;gApplicationTime;gApplicationLength;gDIV"
String StringstoKeep = "gPlatedate;gCustomPath"


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

Variable DFMatch, DFNum
String DFCurrentName,DataFolderList
String DFtoKeep = "nmFolder0;Packages;WinGlobals"

DFREF dfr = GetDataFolderDFR()

DFNum = CountObjectsDFR(dfr,4)

DataFolderList = ""

//Generate folder list

 i=0
 
 for(i=0;i<DFNum;i+=1)
 
DFCurrentName = GetIndexedObjNameDFR(dfr, 4, i)

DataFolderList = AddListItem(DFCurrentName, DataFolderList)

endfor

//Delete folders

 i=0

for(i=0;i<DFNum;i+=1)

DFCurrentName =  StringFromList(i,DataFolderList)
Print DFCurrentName
DFMatch = (Stringmatch(DFtoKeep,"*"+DFCurrentName+"*"))

if (DFMatch==0)
KillDataFolder/Z $DFCurrentName
endif

Endfor


//Waves

KillWaves/A/Z

end

