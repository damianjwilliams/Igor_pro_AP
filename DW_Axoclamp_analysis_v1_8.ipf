//#pragma rtGlobals=1		// Use modern global access method.


// Menu conflicts with NeuroMatic. Shortcuts removed from Neuromatic NM_aMenu.ipf from 'Submenu "Main Hot Keys"'
//Also need to remove "PauseForUser ImportPanel" from NM_Import.ipf

//Changes in version 1_1 (from 130305)
//*In current Clamp analysis opens Passive Mebrane properties directly after Cell Information Input
//*Short Cut Keys changed to include After Polarization Analysis (Passive properties removed)
//*Full Set Analysis includes After Polarization Analysis

//Changes in version 1_2 (Changed 2013-06-19)
//Add Rheobase shortcut and rheobase traces

//Changes in version 1_3 (Changed 2013-06-25)
//Fix RunAllAnalysis() and split analysis into separate procedure files 

//Changes in version 1_4 (Changed 2014-01-30)
//Wave references changed to work with clampex 10.4 data. 
//Changed Capacitance measurement
//Change Input resistance measurement cal to work with pA rather than nA

//Changes in version 1_41 (Changed 2014-06-24)
//Add RMP input field
//Change Cell types
//Correct capicitance
//Remove I_ramp_varialbe to separate protocol

//Changes in version 1_42 (Changed 2014-09-04)
//Change Cell types in drop-down
//Correct capicitance
//Skips first sweep for calculating Rmem and Cap

//Changes in version 1_44 (Changed 2017-03-13)
//Plots h current from Rmem recordings (last sweep)
//Calculates region to analyse APs based on last sweep
//Add td pos and td neg


//Changes in version 1_45 (Changed 2017-08-31)
//Automatically adds one to the AP characterisation trace number
//Anaylses AP characteristics and rheobase together

//Changes in version 1_7
//Add step size calculations



Menu "DJW Macros", dynamic
//"Get Cell info/1",/Q, Get_Cell_Info()
//"AP train properties/2",/Q, load_steps_traces()
//"Export Data/3",/Q, Datatable()
"Abort/F7",/Q, DelUnwantedFolders()
"Run Automatically/F8",/Q,Panelx()
"Switch Paths/F9",/Q, Panel0()

End

Constant K_run_synaptic_decomp = 0
Constant K_run_double_dif = 0
Constant K_run_pp = 1


Function Get_Cell_Info()
//CreateCellFolder()
//CapFileName()
//MeasureCapacitance()


SetDataFolder root:

SVAR gAnalysisType
SVAR gCellFolderName

SetDataFolder $(gCellFolderName)



Variable RMP 
Variable LeakCurrent
Variable VCCap
Variable DIV
String CellType 
String LabelID 
String Cell_ID 
Variable ScaleCurr
Variable ScaleVolt
String PlateDate
Variable DepolStep, HypStep

if( StringMatch(gAnalysisType, "Manual Analysis"))


PlateDate = StrVarOrDefault("gPlateDate", "YYYY-MM-DD")
DIV = NumVarOrDefault("gDIV", NaN)
RMP = NumVarOrDefault("gRMP", NaN)
LeakCurrent = NumVarOrDefault("gLeakCurrent", NaN)
VCCap = NumVarOrDefault("gVCCap", NaN)
CellType = StrVarOrDefault("gCelltype", "-")
LabelID = StrVarOrDefault("gLabelID", "-")
Cell_ID = StrVarOrDefault("gCell_ID", "YYMMDD_dX_cY")
ScaleCurr = NumVarOrDefault("root:gAutoScaleCurr ",1)
ScaleVolt = NumVarOrDefault("root:gScaleVolt ", 1)
HypStep = NumVarOrDefault("root:gHypStep ",1)
DepolStep = NumVarOrDefault("root:gDepolStep ", 1)




Prompt Cell_ID, "Cell ID"
Prompt CellType, "Cell type"
Prompt LabelID, "Label type"
Prompt PlateDate, "Date of plating"
Prompt DIV, "DIV"
Prompt RMP, "Resting Membrane Potential"
Prompt VCCap, "VC Capacitance (pF)"
Prompt LeakCurrent "Leak Current (pA)"
Prompt ScaleCurr "Change Current Scaling"
Prompt ScaleVolt "Change Voltage Scaling"
Prompt HypStep "Hyperpolarizing Step Amplitude"
Prompt DepolStep "Depolarizing Step Amplitude"


DoPrompt "Cell Information",Cell_ID,CellType,PlateDate,DIV, RMP,VCCap,LeakCurrent,ScaleCurr, HypStep, DepolStep


String/G gPlateDate = PlateDate
String/G gCellType = CellType
String/G gLabelID = LabelID
Variable/G gRMP = RMP
Variable/G gScaleCurr = ScaleCurr
Variable/G gScaleVolt = ScaleVolt
Variable/G gDIV = DIV
Variable/G gLeakCurrent = LeakCurrent
Variable/G gHypStep = HypStep
Variable/G gDepolStep = DepolStep


else

//dialog()

endif


End








































///////////////////////////////////////////////////Capaciticance////////////////////////////////////////////////////////////

Function CalculateRmemCap()

// Calculate resting membrane properties from file

NVAR ScaleVolt = root:gScaleVolt
NVAR ScaleCurr = root:gScaleCurr
SVAR gCellident = root:gCellident
SVAR CellIDfolderpath =  root:gCellident

Newdatafolder $CellIDfolderpath




Variable refNum
String message = "Select passive membrane properties file"
String outputPath
String fileFilters = "Axon stats files (*.abf):.abf;"
fileFilters += "All Files:.*;"

Open /D /R /F=fileFilters /M=message refNum


//Newdatafolder Mem_resistance

String/g gRmemCellID = S_fileName[strsearch(S_fileName,":", Inf,1)+1,(strlen(S_fileName)-5)]

String/g root:$(CellIDfolderpath):gRmemTraceID = ParseFilePath(3, S_fileName, ":", 0, 0)


//Set names for automatic file opening

Variable/g root:gCurrentTraceNumber =  str2num(S_fileName[strsearch(S_fileName,":", Inf,1)+12,(strlen(S_fileName)-5)])

String/g root:gTraceFileNoEnd = S_fileName[0,(strlen(S_fileName)-9)]

Variable/g root:gFileTraceNumber = str2num(S_fileName[strsearch(S_fileName,":", Inf,1)+12,(strlen(S_fileName)-5)])


Setdatafolder root:


NMImportFile( "new" ,S_fileName)
DoWindow /K ImportPanel

string tempRmemfolder = GetDataFolder(1)


string newRmemfolderpath = "root:"+CellIDfolderpath+":Mem_resistance_cap"

Newdatafolder/O $newRmemfolderpath

movedatafolder $tempRmemfolder, $newRmemfolderpath


String/g root:gRmICFolder = GetDataFolder(1)
SVAR gRmICFolder = root:gRmICFolder

NVAR ICRmNoTraces = NumWaves


//H currrent plot

string hTrcPotNm = "RecordA" +num2str(ICRmNoTraces-1)
Wave IClampTraceVolt = $hTrcPotNm
Display/N=H_Current_trace $hTrcPotNm
Label left "Membrane potential (mV)"
Label bottom "Time (ms)"
TextBox/W=H_Current_trace/C/N=text1/F=0/A=MT "H Current"


Variable m


Newdatafolder Capacitance
Make/N=(ICRmNoTraces)/O IClampCommand_current
Make/N=(ICRmNoTraces)/O IClampVoltage


variable tracenumber

Make/N=0 Tau
Make/N=0 CurrentAmplitude

Display/N=Hyperpolarizations

for(m=0;m<ICRmNoTraces;m+=1)


string IClampTrcVoltNm = "RecordA"+num2str(m)
Wave IClampTraceVolt = $IClampTrcVoltNm
string IClampTrcCurrNm = "RecordB" +num2str(m)
Wave IClampTraceCurr = $IClampTrcCurrNm

Appendtograph/W=Hyperpolarizations, $IClampTrcVoltNm


string FileScaleFactors = "FileScaleFactors"
Wave Scaling = $FileScaleFactors


IClampTraceCurr = IClampTraceCurr*ScaleCurr
IClampTraceVolt = IClampTraceVolt*ScaleVolt


WaveStats/Q/R=(20,40) IClampTraceCurr
variable IClamphold_curr_start = V_avg
WaveStats/Q/R=(500,1500) IClampTraceCurr
variable IClamphold_curr_end = V_avg

IClampCommand_current[m] = (IClamphold_curr_end - IClamphold_curr_start)




//Remove offset

WaveStats/Q/R=[20,40] IClampTraceCurr
variable IClamphold_curr_offset = V_avg

IClampTraceCurr = IClampTraceCurr -  (IClamphold_curr_offset)


WaveStats/Q/R=[100,300] IClampTraceVolt
variable IClampvoltage_start = V_avg
WaveStats/Q/R=[6000,10000] IClampTraceVolt
variable IClampvoltage_end = V_avg

IClampVoltage[m] = IClampvoltage_end - IClampvoltage_start


 
if(((IClampvoltage_start - IClampvoltage_end)>3)&((IClampvoltage_start - IClampvoltage_end)<10))
	
		
	
//Find point where the current is turn off (for calculating capacitance)

	tracenumber += 1
	
	WaveStats/Q/R=[100,300]IClampTraceCurr
	variable com_step_current_start = V_avg
	WaveStats/Q/R=[6000,10000] IClampTraceCurr
	variable com_step_current_end = V_avg
	variable midpoint = (com_step_current_start + com_step_current_end)/2

	FindLevel/EDGE=1/P IClampTraceCurr, midpoint
	variable OffCurrentPoint = V_LevelX
	
// Calculate size of current step and save in Cap folder

Variable sizeofcurrentstep = (com_step_current_start-com_step_current_end)

	InsertPoints Inf,1,  CurrentAmplitude
	CurrentAmplitude[Inf] = sizeofcurrentstep



// Calculate 80% and 20% of the voltage (for capacitance calculation)

	variable StartCapValue = IClampTraceVolt[OffCurrentPoint]
	variable end_aver = (mean(IClampTraceVolt,v_npnts-500,v_npnts))

	variable ten_val = (((end_aver-StartCapValue)*0.2)+StartCapValue)
	variable ninety_val =  (((end_aver-StartCapValue)*0.8) + StartCapValue)

	print (ten_val)
	print (ninety_val)
	FindLevel/P/R=[OffCurrentPoint],IClampTraceVolt, ninety_val
	variable point_ninety_val = round(V_LevelX)
	print point_ninety_val
	FindLevel/P/R=[OffCurrentPoint], IClampTraceVolt, ten_val
	variable point_ten_val = round(V_LevelX)
	print point_ten_val

	CurveFit/NTHR=0 exp_XOffset  IClampTraceVolt[point_ten_val,point_ninety_val]/D
	Wave W_coef	
	InsertPoints Inf,1,  Tau
	Tau[Inf] = round((W_coef[2])*10)/10
	
	string CapWaveName = "Trace_"+num2str(tracenumber)
	Duplicate/R=[point_ten_val-250,point_ninety_val+250] IClampTraceVolt, $CapWaveName
	MoveWave $CapWaveName :Capacitance:
	
	string CapFit = "Fit_"+num2str(tracenumber)
	string FitName = "Fit_"+IClampTrcVoltNm
	Duplicate $FitName, $CapFit
	MoveWave $CapFit :Capacitance:
	
	endif

endfor

Display/N=IV_plot IClampVoltage vs IClampCommand_current
ModifyGraph mode=3
Label left "Voltage change (mV)"
Label bottom "Current injection (pA)"

Label/W=Hyperpolarizations Left "Membrane Potential (mV)"
Label/W=Hyperpolarizations bottom "Time (ms)"
TextBox/W=Hyperpolarizations/C/N=text1/F=0/A=MT "Hyperpolarizing steps"

// Calculation of Rm using slope of I/V plot

CurveFit/NTHR=1 line  IClampVoltage /X=IClampCommand_current /D 
Wave W_coef

//Multiply by 1000 to account for  pA conversion

variable InputResistance = (W_coef[1]*1e3)

//////////////// Make New Cap Measuremetns

Make/N=(numpnts(Tau)) cap

cap = round((Tau/InputResistance)*1000)


Edit Cap,Tau as "Detailed Cap Measurement"
DoWindow/C CapCalcs
ModifyTable alignment=1,autosize={0,3,-1,0,0},size=8

variable AvCap = round(mean(cap))

print (InputResistance)
Textbox/C/B=1/F=0/N=text0/A=LT "Rmem = "+num2str(round(InputResistance))+" MOhm"
TextBox/C/B=1/F=0/N=text1/A=RB "Cap = "+num2str(AvCap)+" pF"

SVAR CellIDfolderpath = root:gCellident

setdatafolder root:$(CellIDfolderpath)
variable/g gRmem = InputResistance
variable/g gCap = AvCap



DrawCapTraces()

End


	
	
function DrawCapTraces()

variable i

SVAR gRMICFolder = root:gRMICFolder
SVAR CellIDfolder  = root:gCellident
String Capdatafolder = gRMICFolder+"Capacitance:"


setdatafolder root:$(CellIDfolder)
NVAR gRmem = gRmem


//Move cap table to Cap folder
Setdatafolder $gRMICFolder
MoveWave Cap $Capdatafolder



setdatafolder $Capdatafolder

Wave cap
//variable TotalNumberPlots = (CountObjectsDFR($Capdatafolder,2))/2

String CapWaveNames = WaveList("Trace_*", ";", "")
String FitWaveNames = WaveList("Fit_*", ";", "")

Variable NoCapPlots = ItemsInList(CapWaveNames)


make/O/N=0/D Timecourses


for(i=0;i<NoCapPlots;i+=1)

string CurrentCapPlot = StringFromList(i,CapWaveNames)

string CurrentFitPlot = StringFromList(i, FitWaveNames)

String CurrentGraphName = "Cap_plot_fit_"+num2str(i)

String CapMeasurement = num2str(cap[i])+" pF"

Display/N=$CurrentGraphName

AppendToGraph/W=$CurrentGraphName $CurrentCapPlot
AppendToGraph/W=$CurrentGraphName $CurrentFitPlot
ModifyGraph/W=$CurrentGraphName/Z rgb($CurrentFitPlot)=(16384,16384,65280)
TextBox/W=$CurrentGraphName/C/N=text0/F=0/A=RB CapMeasurement


endfor

End




for(l=0;l<total_number;l+=1)

variable current_sheet_number =ceil((l+1)/6)
string  graphname = "Graph"+num2str((current_sheet_number)-1)
variable current_position =(l+1)-((ceil((l+1)/6)-1)*6)


string tracename = "Trace_"+num2str(l+1)
string fitname = "Fit_"+num2str(l+1)
string tauvarname = Capdatafolder+"tau_"+num2str(l+1)
string currstepname = Capdatafolder+"currentstep_"+num2str(l+1)


NVAR CurrentStep = $currstepname
NVAR TauValue = $tauvarname

Variable fivepercent
variable minval
variable maxval 
variable minyval
variable maxyval
variable currcap

if(current_position==1)

//Display $tracename

Newfreeaxis/O/W=$graphname l1
Newfreeaxis/B/O/W=$graphname b01
AppendToGraph/W=$graphname/B=b01/L=l1 $tracename 
AppendToGraph/W=$graphname/B=b01/L=l1 $fitname
ModifyGraph/W=$graphname/Z rgb($fitname)=(16384,16384,65280)
ModifyGraph/W=$graphname/Z  axisEnab (l1)={0.60,0.95}
ModifyGraph/W=$graphname/Z axisEnab (b01)={0.10,0.45}

ModifyGraph/W=$graphname lblPos(l1)=42,lblPos(b01)=38
ModifyGraph/W=$graphname lblLatPos(b01)=1


Label/W=$graphname/Z b01 "Time (ms)"
Label/W=$graphname/Z l1 "MP (mV)"
Wavestats/Q $tracename
fivepercent = ((sqrt(V_max-V_min))^2)*0.05
minval =  V_min-fivepercent
maxval = V_max+fivepercent
minyval = leftx($tracename)
maxyval =rightx($tracename)
SetAxis/W=$graphname l1, minval,maxval
SetAxis/W=$graphname b01, minyval,maxyval
ModifyGraph/W=$graphname/Z freePos(b01)={minval,l1}
ModifyGraph/W=$graphname/Z freePos(l1)={minyval,b01}

currcap =  ((TauValue*1e-3)/(gRmem*1e6))*1e12

Tag/W=$graphname/F=0/L=0/X=-10/Y=-21 $tracename, V_npnts, num2str(round(CurrentStep))+" pA\rTau = "+num2str(round(TauValue))+" ms\rCap = "+num2str(round(currcap))+" pF"
Insertpoints 0,1, Timecourses
Timecourses[0] = TauValue

endif

if(current_position==2)

Newfreeaxis/O/W=$graphname l2
Newfreeaxis/B/O/W=$graphname b02
AppendToGraph/W=$graphname/B=b02/L=l2 $tracename 
AppendToGraph/W=$graphname/B=b02/L=l2 $fitname
ModifyGraph/W=$graphname/Z rgb($fitname)=(16384,16384,65280)
ModifyGraph/W=$graphname/Z  axisEnab (l2)={0.10,0.45}
ModifyGraph/W=$graphname/Z axisEnab (b02)={0.10,0.45}

ModifyGraph/W=$graphname lblPos(l2)=42,lblPos(b02)=38
ModifyGraph/W=$graphname lblLatPos(b02)=1


Label/W=$graphname/Z b02 "Time (ms)"
Label/W=$graphname/Z l2 "MP (mV)"
Wavestats/Q $tracename
fivepercent = ((sqrt(V_max-V_min))^2)*0.05
minval =  V_min-fivepercent
maxval = V_max+fivepercent
minyval = leftx($tracename)
maxyval =rightx($tracename)
SetAxis/W=$graphname l2, minval,maxval
SetAxis/W=$graphname b02, minyval,maxyval
ModifyGraph/W=$graphname/Z freePos(b02)={minval,l2}
ModifyGraph/W=$graphname/Z freePos(l2)={minyval,b02}

currcap =  ((TauValue*1e-3)/(gRmem*1e6))*1e12

Tag/W=$graphname/F=0/L=0/X=-10/Y=-21 $tracename, V_npnts, num2str(round(CurrentStep))+" pA\rTau = "+num2str(round(TauValue))+" ms\rCap = "+num2str(round(currcap))+" pF"
Insertpoints 0,1, Timecourses
Timecourses[0] = TauValue

endif

if(current_position==3)

Newfreeaxis/O/W=$graphname l3
Newfreeaxis/B/O/W=$graphname b03
AppendToGraph/W=$graphname/B=b03/L=l3 $tracename 
AppendToGraph/W=$graphname/B=b03/L=l3 $fitname
ModifyGraph/W=$graphname/Z rgb($fitname)=(16384,16384,65280)
ModifyGraph/W=$graphname/Z  axisEnab (l3)={0.60,0.95}
ModifyGraph/W=$graphname/Z axisEnab (b03)={0.60,0.95}

ModifyGraph/W=$graphname lblPos(l3)=42,lblPos(b03)=38
ModifyGraph/W=$graphname lblLatPos(b03)=1


Label/W=$graphname/Z b03 "Time (ms)"
Label/W=$graphname/Z l3 "MP (mV)"
Wavestats/Q $tracename
fivepercent = ((sqrt(V_max-V_min))^2)*0.05
minval =  V_min-fivepercent
maxval = V_max+fivepercent
minyval = leftx($tracename)
maxyval =rightx($tracename)
SetAxis/W=$graphname l3, minval,maxval
SetAxis/W=$graphname b03, minyval,maxyval
ModifyGraph/W=$graphname/Z freePos(b03)={minval,l3}
ModifyGraph/W=$graphname/Z freePos(l3)={minyval,b03}

currcap =  ((TauValue*1e-3)/(gRmem*1e6))*1e12

Tag/W=$graphname/F=0/L=0/X=-10/Y=-21 $tracename, V_npnts, num2str(round(CurrentStep))+" pA\rTau = "+num2str(round(TauValue))+" ms\rCap = "+num2str(round(currcap))+" pF"
Insertpoints 0,1, Timecourses
Timecourses[0] = TauValue

endif

if(current_position==4)

Newfreeaxis/O/W=$graphname l4
Newfreeaxis/B/O/W=$graphname b04
AppendToGraph/W=$graphname/B=b04/L=l4 $tracename 
AppendToGraph/W=$graphname/B=b04/L=l4 $fitname
ModifyGraph/W=$graphname/Z rgb($fitname)=(16384,16384,65280)
ModifyGraph/W=$graphname/Z  axisEnab (l4)={0.1,0.45}
ModifyGraph/W=$graphname/Z axisEnab (b04)={0.60,0.95}

ModifyGraph/W=$graphname lblPos(l4)=42,lblPos(b04)=38
ModifyGraph/W=$graphname lblLatPos(b04)=1


Label/W=$graphname/Z b04 "Time (ms)"
Label/W=$graphname/Z l4 "MP (mV)"
Wavestats/Q $tracename
fivepercent = ((sqrt(V_max-V_min))^2)*0.05
minval =  V_min-fivepercent
maxval = V_max+fivepercent
minyval = leftx($tracename)
maxyval =rightx($tracename)
SetAxis/W=$graphname l4, minval,maxval
SetAxis/W=$graphname b04, minyval,maxyval
ModifyGraph/W=$graphname/Z freePos(b04)={minval,l4}
ModifyGraph/W=$graphname/Z freePos(l4)={minyval,b04}

currcap =  ((TauValue*1e-3)/(gRmem*1e6))*1e12

Tag/W=$graphname/F=0/L=0/X=-10/Y=-21 $tracename, V_npnts, num2str(round(CurrentStep))+" pA\rTau = "+num2str(round(TauValue))+" ms\rCap = "+num2str(round(currcap))+" pF"
Insertpoints 0,1, Timecourses
Timecourses[0] = TauValue

//Make a single capacitance  graph

Display/N=SingleCapGraph

AppendToGraph/W=SingleCapGraph $tracename 
AppendToGraph/W=SingleCapGraph $fitname
ModifyGraph/W=SingleCapGraph/Z rgb($fitname)=(16384,16384,65280)
Label/W=SingleCapGraph/Z bottom "Time (ms)"
Label/W=SingleCapGraph/Z left "MP (mV)"

Wavestats/Q $tracename
fivepercent = ((sqrt(V_max-V_min))^2)*0.05
minval =  V_min-fivepercent
maxval = V_max+fivepercent
minyval = leftx($tracename)
maxyval =rightx($tracename)
SetAxis/W=SingleCapGraph left, minval,maxval
SetAxis/W=SingleCapGraph bottom, minyval,maxyval

Tag/W=SingleCapGraph/F=0/L=0/X=-20/Y=-40 $tracename, V_npnts, "-"+num2str(round(CurrentStep))+" pA Step\rTau = "+num2str(round(TauValue))+" ms"


endif

print "number sheets required = "+num2str(number_sheets)
print "current sheets number = "+num2str(current_sheet_number)
print "current sheets position = "+num2str(current_position)

endfor

Renamewindow Graph0, CapGraph



Wavestats/Q Timecourses

SVAR CellIDfolderpath = root:gCellIDfolderpath
string Rmempath = CellIDfolderpath+":gRmem"
NVAR InputResistance = $Rmempath

Variable AvTau = V_Avg
Print (AvTau)
print num2str(InputResistance)+" Mohm"




NewLayout/P=Landscape/W=(3.75,41.75,834.75,692)
ModifyLayout mag=1
AppendLayoutObject/F=0/R=(78.75,87.75,392.25,336.75) graph IV_plot
AppendLayoutObject/F=0/R=(384.75,72,718.5,538.5) graph CapGraph
AppendLayoutObject/F=0/R=(92.25,341.25,358.5,509.25) Table CapCalcs

//TextBox/W=layout0/N=text0/A=LB/X=68.68/Y=50.64 "Mean Capacitance = "+num2str(AvCap)+" pF"

DFREF saveDFR = GetDataFolderDFR()

SVAR CellIDfolderpath = root:gCellIDfolderpath

setdatafolder $CellIDfolderpath


setdatafolder saveDFR



SetWindow Layout0, hook(MyHook3)=MyWindowHookAAA // Install window hook

End


Function MyWindowHookAAA(s)
STRUCT WMWinHookStruct &s
Variable hookResult = 0 // 0 if we do not handle event, 1 if we handle it.
switch(s.eventCode)
case 11: // Keyboard event
switch (s.keycode)
case 13:

IClampKill_foldersSS()

hookResult = 1
break
endswitch
break
endswitch
return hookResult // If non-zero, we handled event and Igor will ignore it.
End

Function IClampKill_foldersSS()

DoWindow/K Layout0
DoWindow/K Table0
DeletePoints 1,1, root:Packages:NeuroMatic:FolderList


End

	
		
Function ButtonProc4(ba) : ButtonControl

//Controls action of Analyse button
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
		
			print "hgrejfjn"		
							

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function StringSetVarProcA(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
 	
 	
 	 	
 	SVAR gRmem_path  = root:gRmem_path
 	Setdatafolder  $gRmem_path
 	 NVAR gFirstTrace = gFirstTrace
 		
 
	switch( sva.eventCode )
			case 2: // Enter key
			
			gFirstTrace = sva.dval
			print gFirstTrace
				
			break
 
		
	endswitch
 
	return 0
End

Function StringSetVarProcA2(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
 
	SVAR gRmem_path  = root:gRmem_path
 	Setdatafolder  $gRmem_path
 	NVAR gLastTrace = gLastTrace
 
	switch( sva.eventCode )
			case 2: // Enter key
			
			gLastTrace = sva.dval
			print gLastTrace
						
			break
 
		
	endswitch
 
	return 0
End




Function Kill_unwanted_folders()

SVAR gRmemFold = root:gRmemFold
DoWindow/K Graph0
DoWindow/K input_trace_subset
DeletePoints 1,1, root:Packages:NeuroMatic:FolderList
//killdatafolder $gRmemFold

End



Function MyWindowHook3A(s)
STRUCT WMWinHookStruct &s
Variable hookResult = 0 // 0 if we do not handle event, 1 if we handle it.
switch(s.eventCode)
case 11: // Keyboard event
switch (s.keycode)
case 13:
Kill_unwanted_folders()
hookResult = 1
break
endswitch
break
endswitch
return hookResult // If non-zero, we handled event and Igor will ignore it.

End




Function kill_unwanted_things()

//Kill unwanted Strings and variables

Variable i,j,VariableMatches,v,StrMatches
String CurrVar,CurrTraceID,CurrStr

String VariablestoKeep =   "gPassage;gDIV"
String StringstoKeep = "gCellFolderName;gCellident;gPlateDate;gCellline;gAstro"


Setdatafolder root:


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


//Close Open Windows


String CurrWin
String OpenWindows = WinList("*", ";","WIN:23")
Variable NumOpenWindows = Itemsinlist(OpenWindows)

i=0

for(i=0;i<NumOpenWindows;i+=1)
CurrWin  = StringFromList(i, OpenWindows)
print (CurrWin)
DoWindow/K $CurrWin

Endfor

//Remove Cell folder and reference 

SVAR CellIdent = root:gCellfolderName
KillDataFolder/Z $CellIdent
Killstrings/Z gCellfolderName


Wavestats  root:Packages:NeuroMatic:FolderList
Variable NumFolders = V_npnts
DeletePoints 1,inf, root:Packages:NeuroMatic:FolderList


End





Function MakeNewLayout()

Setdatafolder root:

SVAR  gCellFolderName
SVAR gCustomPath

Setdatafolder $(gCellFolderName)

SVAR gCell_ID



//NewLayout/N=Collateddata/W=(287,32.5,878.5,524.5)
NewLayout/N=Collateddata/W=(522,44.75,1113,536.75)

AppendLayoutObject/F=0/T=0/R=(32,-27,282,194) Graph MeasurementsA
AppendLayoutObject/F=0/T=0/R=(190,8,408,160) Graph MeasurementsB
AppendLayoutObject/F=0/T=0/R=(417,18,566,152) Graph MeasurementsC

Appendlayoutobject/F=0/R=(26,339,284,488) graph H_current_trace
Appendlayoutobject/F=0/R= (300,164,571,326) graph IV_plot
Appendlayoutobject/F=0/R=(293,329,578,498.5) graph AP_calc_trace
//Appendlayoutobject/F=0/R=(23,670,281,815) graph SFAtrace
AppendLayoutObject/F=0/R=(22,670,164,814) Graph SFAtrace
Appendlayoutobject/F=0/R=(303,501,574.5,658.5) graph FixedCurrVsAPs
//Appendlayoutobject/F=0/R=(305,675,584,809.5) graph MaxNumAPtrace
AppendLayoutObject/F=0/R=(300,674,584,808) Graph MaxNumAPtrace
Appendlayoutobject/F=0/R=(23,491,285.5,657) graph Rheobasegraph
Appendlayoutobject/F=0/R=(23,157,281,324) graph Hyperpolarizations
AppendLayoutObject/F=0/R=(23,672,285,812) Graph For_dd_check

PrintSettings/W=Collateddata margins={0,0,0,0}


String SaveFileNameData = gCustomPath+gCell_ID+".pdf"
SavePict/E=-8/O/WIN=Collateddata as SaveFileNameData

End


