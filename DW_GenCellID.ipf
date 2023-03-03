#pragma rtGlobals=3		// Use modern global access method and strict wave access.



//Identify Cell ID from folder name

Function CellidentFromFolder(Manual, WorkingFolder)

String WorkingFolder,Manual

Variable NumFolders, LastFolder,CellFolderNum,DateFolderNum
String StringRMP, expr, CellFolder, TheDate, Dish, Genotype, Cell, ExpDate, CellFolderName,Reporter


setdatafolder root:
SVAR gAnalysisType
SVAR gPlateDate



if( StringMatch(Manual, "Manual"))

NewPath/O pathName, WorkingFolder
CellFolder = ParseFilePath(0,  WorkingFolder, ":", 1, 0)


else

NewPath/O pathName, WorkingFolder
CellFolder = ParseFilePath(0,  WorkingFolder, ":", 1, 0)

NewPath/O pathname_for_pp, WorkingFolder

endif






expr = "([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)"
SplitString /E=expr CellFolder,TheDate, Dish, Cell,Genotype, Reporter,StringRMP



CellFolderName = "Cell_"+TheDate+"_"+Dish+"_"+Cell

NewDataFolder/O/S $CellFolderName

String/g root:gCellFolderName = GetDataFolder(1)

String/g gDish = Dish
String/g gCell = Cell
String/g gGenotype = Genotype
String/g gReporter = Reporter
String/g gDate = TheDate
Variable/g gRMP = str2num(StringRMP)

//GetFileFolder()
String/g CellFolderFilePath = WorkingFolder
String/g gCell_ID = TheDate+"_"+Dish+"_"+Cell

NewPath/O pathName, WorkingFolder
String/g gListofFiles = IndexedFile( pathName, -1, "????")

String/g gFolderPath = WorkingFolder

print gListofFiles


setdatafolder root:

DIV_calculate(gPlateDate)


End




//Determine passive properties from the sta file
Function PassPropsSta()

Variable NumFiles
String StaFileNm, StaFileNmLst

setdatafolder root:
SVAR gCellFolderName 

setdatafolder gCellFolderName 
SVAR gListofFiles,gFolderPath
Variable /g gRa,gRm,gCapacitance,gHold



//Get Sta file name
StaFileNmLst =  GrepList(gListofFiles,"sta")
String/g gStaFileNm = StringFromList(0,StaFileNmLst )

//If sta file exist ,get passive properties
if( strlen(gStaFileNm)>0)


LoadWave/W/A/J/D/K=1/L={11,11, 0,1, 0}/O gFolderPath+gStaFileNm

Wave Memb_Test_0_Memb_Test_Ra__MOhm_
Wavestats Memb_Test_0_Memb_Test_Ra__MOhm_
 gRa = V_avg


Wave Memb_Test_0_Memb_Test_Rm__MOhm_
Wavestats Memb_Test_0_Memb_Test_Rm__MOhm_
gRm = V_avg

Wave Memb_Test_0_Memb_Test_Cm__pF_
Wavestats Memb_Test_0_Memb_Test_Cm__pF_
gCapacitance = V_avg

Wave Memb_Test_0_Memb_Test_Holding__pA_
Wavestats Memb_Test_0_Memb_Test_Holding__pA_
gHold = V_avg

//Else add NaNs
else

gRa = NaN
gRm = NaN
gCapacitance = NaN
gHold = NaN

endif 

End


Function AbfFileList()

variable StaIndex
String List_of_files,Current_file,Current_file_path,PP_files,Decomp_file,Mem_test_files,Other_files
variable i,Num_files,refNum

setdatafolder root:
SVAR gCellFolderName 


setdatafolder gCellFolderName 

string/g  gAbfFiles
SVAR gListofFiles
SVAR gStaFileNm

print "list of files "+ gListofFiles
print "Sta file name "+ gStaFileNm

//Find index of sta file in file list
StaIndex =  WhichListItem(gStaFileNm, gListofFiles) 

print "Sta location "+ num2str(StaIndex)

//Remove sta file from list
gAbfFiles = RemoveListItem(StaIndex, gListofFiles) 

print "new file list " + gAbfFiles

PathInfo pathName

//Separate different abf files

List_of_files = IndexedFile(pathName,-1,".abf")
Num_files = ItemsInList (List_of_files)

PP_files = ""
Other_files = ""
Mem_test_files = ""


i = 0
do

	Current_file = StringFromList(i,List_of_files)
	Current_file_path = S_path+Current_file
	//print(Current_file_path)
	Open/P=pathName/R refNum as Current_file
	FStatus refNum
	variable File_size = (round(V_logEOF/10000))*10000
	print(File_size)
	
	if((round(V_logEOF/10000)*10000)==1.1e6)
	
		print("40Hz")
		PP_files = AddListItem(Current_file, PP_files)
		
	elseif((round(V_logEOF/10000)*10000)==1.46e6)
		print("20Hz")
		PP_files = AddListItem(Current_file, PP_files)
	
	elseif((round(V_logEOF/10000)*10000)==2.66e+06)
		print("Decomposition")
		//Decomp_analysis(Current_file,S_path)
		
	elseif(round(V_logEOF/10000)*10000==1.81e+06)
		print("Membrane Test")
		Mem_test_files = AddListItem(Current_file, Mem_test_files)
		
	elseif(round(V_logEOF/10000)*10000==1.9e+05)
		print("Membrane Test")
		Mem_test_files = AddListItem(Current_file, Mem_test_files)
		
	
		
	else	
	
	Other_files = AddListItem(Current_file, Other_files)
	
	
	endif
		
	i++

while(i < Num_files)

print(strlen(PP_files))
print(Other_files)

gAbfFiles = sortList(Other_files)


 End







Function InputCellInfo()

String/g gGenotype,gAstro, gCellSubtype
String Cellident, PlateDate,Genotype,Astro,CellSubtype
Variable/g gRMP
Variable DIV, RMP, Capacitance,Rm, Ra,Hold

setdatafolder root:
SVAR gCellident, gPlateDate
NVAR gDIV

setdatafolder gCellident
NVAR gRa,gRm,gCapacitance,gHold

Cellident = StrVarOrDefault("root:gCellident", "YYMMDD_dX_cY")
DIV = NumVarOrDefault("root:gDIV", NaN)
Capacitance = NumVarOrDefault("gCapacitance",NaN)
Rm = NumVarOrDefault("gRm",NaN)
Ra = NumVarOrDefault("gRa",NaN)
Hold = NumVarOrDefault("gHold",NaN)
PlateDate = StrVarOrDefault("gPlateDate", "YYYY-MM-DD")
//RMP = NumVarOrDefault("gRMP",NaN)

Prompt Cellident, "Cell ID"
Prompt RMP, "Resting Membrane Potential (mV)"
Prompt Genotype,"Genotype",popup,"Undefined;Gnb1 wt; Gnb1 K78R;"
Prompt Astro, "Cocultured?",popup,"Neurons only; Cortical Astrocytes"
Prompt PlateDate, "Date of plating"
Prompt DIV, "DIV"
Prompt Capacitance, "VC Capacitance (pF)"
Prompt Rm, "VC Input Resistance (pF)"
Prompt CellSubtype, "Cell subtype",popup,"Unknown Cortex;Excitatory Cortex;Inhibitory Cortex;Unknown Hippocampal;Excitatory Hippocampal;Inhibitory Hippocampal"



DoPrompt "Cell Information",Cellident,Genotype, Astro,PlateDate, RMP,DIV,Capacitance,CellSubtype



gCellident = Cellident
string/g root:gPlateDate = PlateDate
gGenotype = Genotype
gAstro = Astro
gRMP = RMP
variable/g root:gDIV = DIV
gCapacitance = Capacitance
gRm = Rm
gCellSubtype = CellSubtype


End



