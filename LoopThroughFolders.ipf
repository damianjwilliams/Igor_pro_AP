//#pragma rtGlobals=2		// Use modern global access method and strict wave access.

Window Panelx() : Panel
PauseUpdate; Silent 1 // building window …
NewPanel /W=(150,50,353,212)
Variable/G root:gSelectedRadioButton = 1
CheckBox radioButton1,pos={52,25},size={78,15},title="Automatic"
CheckBox radioButton1,value=1,mode=1,proc=MyRadioButtonProc
CheckBox radioButton2,pos={52,45},size={78,15},title="Manual"
CheckBox radioButton2,value=0,mode=1,proc=MyRadioButtonProc

Button button1,pos={75,100},size={50,20},proc= KillButtonProc,title="Accept"

EndMacro


static Function HandleRadioButtonClick(controlName)
String controlName
NVAR gSelectedRadioButton = root:gSelectedRadioButton
strswitch(controlName)
case "radioButton1":
gSelectedRadioButton = 1
break
case "radioButton2":
gSelectedRadioButton = 2
break

endswitch
CheckBox radioButton1, value = gSelectedRadioButton==1
CheckBox radioButton2, value = gSelectedRadioButton==2

End
Function MyRadioButtonProc(cb) : CheckBoxControl
STRUCT WMCheckboxAction& cb
switch(cb.eventCode)
case 2: // Mouse up
HandleRadioButtonClick(cb.ctrlName)
break
endswitch
return 0
End

Function KillButtonProc(ctrlName) : ButtonControl
   String ctrlName   
    KillWindow Panelx
    AllFilesInfo()
End










Function AllFilesInfo()

setdatafolder root:




//Determine analysis type
String AnalysisType
String Cell_subtype,path_name

Variable DepolStep = NumVarOrDefault("root:gDepolStep ",20)
Variable HypStep = NumVarOrDefault("root:gHypStep ",-10)

Variable AutoScaleCurr = NumVarOrDefault("root:gAutoScaleCurr ",1)
Variable BaselineScaleCurr = NumVarOrDefault("root:gBaselineScaleCurr ",1)
String PlateDate = StrVarOrDefault("gPlateDate", "YYYY-MM-DD")
Prompt AutoScaleCurr "Change Current Scaling"
Prompt DepolStep "Depolarization Step amplitude (pA)"
Prompt HypStep "Hyperpolarization Step amplitude (pA)"
//Prompt BaselineScaleCurr "Change Baseline Current Scaling"
Prompt AnalysisType, "Automatic analysis",popup,"Automatic Analysis;Manual Analysis"
Prompt Cell_subtype, "Cell subtype",popup,"Cortical unknown;Cortical excitatory;Cortical Inhibitory;Hippocampal unknown;Hippocampal excitatory;Hippocampal Inhibitory"
Prompt PlateDate, "Plate Date"
DoPrompt  " Current Scale and Analysis Info" ,AnalysisType, AutoScaleCurr,DepolStep,HypStep,Cell_subtype,PlateDate//BaselineScaleCurr
Variable/G  gAutoScaleCurr =  AutoScaleCurr
//Variable/G  gBaselineScaleCurr = BaselineScaleCurr
String/G gAnalysisType = AnalysisType
Variable/G gAutoScaleVolt = 1
String/G gCell_subtype = Cell_subtype
String/G gPlateDate = PlateDate
Variable/g gDepolStep = DepolStep
Variable/g gHypStep = HypStep

ListFolders(AnalysisType)

End 


Function ListFolders(AnalysisType)

String AnalysisType

variable i

if(StringMatch("Automatic Analysis",AnalysisType))
NewPath/M="Parent Folder containing cell folders"/O DirectoryPath 


String ListOfFolders = IndexedDir(DirectoryPath  ,-1,1)
ListOfFolders = SortList(ListOfFolders)

print listofFolders

Variable NumFolders = ItemsInList (listOfFolders)


for (i=0;i<NumFolders;i+=1)

String WorkingFolder = StringFromList(i,listOfFolders)

WorkingFolder=WorkingFolder+":"

print WorkingFolder
String Manual = "fnah"

CellidentFromFolder(Manual, WorkingFolder)

PassPropsSta()
//GenStaCheck()
//InputCellInfo()
AbfFileList()
HCurrent(WorkingFolder,AnalysisType)
Rmem()
//CheckScaling()
check_PP_folder()
Load_steps_traces(WorkingFolder,AnalysisType)
RheobasePlot()


SaveEverything()

AutoDelUnwantedFolders()
//Panel3()
endfor

else

Manual = "Manual"

GetFileFolderInfo/D
print S_path

WorkingFolder = S_path

CellidentFromFolder(Manual,WorkingFolder)

endif



end







//SVAR  gAnalysisType

//HCurrent()
//Rmem()
//CheckScaling()
load_steps_traces()
//Panel3()

//end

function GetWorkingFolder(AutoScaleCurr)

Variable AutoScaleCurr

print("Current rescale: "+num2str(AutoScaleCurr))

setdatafolder root:

String/g glistOfFolders, gWorkingfolder, gCapFolderPath

SVAR glistOfFolders, gWorkingfolder, gCapFolderPath

//String WorkingFolder

Variable NumFolders,i

NewPath/M="Parent Folder containing cell folders"/O DirectoryPath 

glistOfFolders = IndexedDir(DirectoryPath  ,-1,1)

print glistofFolders

NumFolders = ItemsInList (glistOfFolders)



for (i=0;i<NumFolders;i+=1)

gWorkingFolder = StringFromList(i,glistOfFolders)

gWorkingFolder=gWorkingFolder+":"




 //Automatic
//CellidentFromFolder(gWorkingFolder)
//CreateCellFolder()
//Get_Cell_Info()
//GetFileNames()
//StaCheck()
//HCurrent(WorkingFolder,AnalysisType)
//Rmem()
//CheckScaling()
//load_steps_traces()
//Panel3()


endfor

end


