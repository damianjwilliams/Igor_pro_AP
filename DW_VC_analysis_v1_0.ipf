#pragma rtGlobals=1		// Use modern global access method.
#include <FilterDialog> menus=0

////Checked 2014-01-30, Wave references should work with clampex 10.4 data. 

Menu "DJW Voltage Clamp Macros", dynamic
"Get Cell info",/Q, Get_Cell_Info()
"Passive Membrane Properties",/Q, AxopatchMemProps()
"Persistent Inward Current Analysis",/Q, CalculatePIC()
"Delayed Rectifer Analysis ",/Q,DelayedRectifierAnalysis()
"Export Voltage Clamp Data",/Q, FixUndefinedValues() 

End




Function CalculatePIC()

// Calculate resting membrane properties from file


Variable refNum
String message = "Select PIC voltage clapm file"
String outputPath
String fileFilters = "Axon stats files (*.abf):.abf;"
fileFilters += "All Files:.*;"
Open /D /R /F=fileFilters /M=message refNum

SVAR CellIDfolderpath = root:gCellIDfolderpath


Setdatafolder $CellIDfolderpath
Newdatafolder PIC_amplitude

String/g gPICCellID = S_fileName[strsearch(S_fileName,":", Inf,1)+1,(strlen(S_fileName)-5)]


Setdatafolder root:


NMImportFile( "new" ,S_fileName)
DoWindow /K ImportPanel

string tempPICfolder = GetDataFolder(1)
string newPICfolderpath = CellIDfolderpath+":PIC_amplitude:"

movedatafolder $tempPICfolder, $newPICfolderpath

String VClampPICFold = newPICfolderpath+"nm"+gPICCellID+":"

string/g root:gVClampPICFold = VClampPICFold

SVAR gVClampPICFold = root:gVClampPICFold

string VClampNum_traces_name = gVClampPICFold+"NumWaves"
NVAR VClampNum_traces = $VClampNum_traces_name
print VClampNum_traces
Setdatafolder $gVClampPICFold 
	
variable/g gVClampfirsttrace = 0
variable/g gVClamplasttrace = VClampNum_traces-1

SVAR gVClampPICFold = root:gVClampPICFold
Setdatafolder $gVClampPICFold
NVAR gVClampFirstTrace = gVClampFirstTrace
NVAR gVClampLastTrace = gVClampLastTrace
Variable m
Variable VClampNumTraceSubset = (gVClampLastTrace-gVClampFirstTrace)+1


//Make/N=(IClampNumTraceSubset)/O IClampCommand_current
//Make/N=(IClampNumTraceSubset)/O IClampVoltage

variable tracenumber = 0


for(m=gVClampFirstTrace;m<(gVClampLastTrace+1);m+=1)

Setdatafolder $gVClampPICFold

string VClampTrcComVoltNm = "RecordB"+num2str(m)
string/g gVoltageTraceName = VClampTrcComVoltNm
Wave VClampTraceVolt = $VClampTrcComVoltNm
string VClampTrcRecCurrNm = "RecordA" +num2str(m)
Wave VClampTraceCurr = $VClampTrcRecCurrNm


//voltage region for calculating leak

Variable LeakVoltStart = -80
Variable LeakvoltEnd = -60

FindLevel/EDGE=1/P/R=[2200] VClampTraceVolt, LeakVoltStart
	variable LeakVoltStartPoint = V_LevelX

FindLevel/EDGE=1/P/R=[2200] VClampTraceVolt, LeakVoltEnd
	variable LeakVoltEndPoint = V_LevelX
	
	

CurveFit/NTHR=0 line  VClampTraceCurr[ LeakVoltStartPoint,LeakVoltEndPoint] /X=VClampTraceVolt /D 
Wave W_coef
Variable LeakGrad = W_coef[1]
Variable LeakIntercept = W_coef[0]

Wavestats VClampTraceVolt

String LeakSubtractName = "leak_subtract_"+num2str(m)

Make/N=(V_npnts)/O $LeakSubtractName

Wave LeaksubtractWave = $LeakSubtractName

LeaksubtractWave = VClampTraceCurr - (VClampTraceVolt*LeakGrad+LeakIntercept)
SetScale/P x 0,0.1,"", LeaksubtractWave


string VClampFilteredName= "Filtered_"+VClampTrcRecCurrNm
Wave VClampFilteredWave = $VClampFilteredName

string VClampLeakFilteredName= "Filtered_"+LeakSubtractName
Wave VClampLeakFilteredWave = $VClampLeakFilteredName

//Duplicate/O  VClampTraceCurr, RecordA0_filtered; DelayUpdate
//Make/O/D/N=0 coefs; DelayUpdate
//FilterFIR/DIM=0/LO={0.03,0.035,92}/COEF coefs, RecordA0_filtered

Duplicate/O $LeakSubtractName, $VClampLeakFilteredName; DelayUpdate
Make/O/D/N=0 coefs; DelayUpdate
FilterFIR/DIM=0/LO={0.03,0.035,92}/COEF coefs,$VClampLeakFilteredName

Duplicate/O VClampTraceCurr, $VClampFilteredName; DelayUpdate
Make/O/D/N=0 coefs; DelayUpdate
FilterFIR/DIM=0/LO={0.03,0.035,92}/COEF coefs, $VClampFilteredName

String PICGraphName = "PICGraphRep"+num2str(m+1)

Display/N=$PICGraphName $LeakSubtractName, VClampTraceCurr,$VClampLeakFilteredName,$VClampFilteredName
ModifyGraph rgb($VClampTrcRecCurrNm)=(65535,39168,0)
ModifyGraph rgb($VClampLeakFilteredName)=(0,26112,65535)
ModifyGraph rgb($VClampFilteredName)=(13056,39168,13312)
ModifyGraph zero(left)=8
Label left "Current (pA)"
Label bottom "Time (ms)"



//Set Graph axis dimensions

Variable MaxForGraph

 Wavestats/R=(2000,6000) VClampTraceCurr
 
 Maxforgraph = (V_max*1.1)
 
 SetAxis/W=$PICGraphName left -75,Maxforgraph


endfor

//Average the traces 

testave()





end


Function testave()
string Mean_trace_name = "Averaged PIC trace"
variable j
SVAR VoltageTraceName = gVoltageTraceName
SVAR gCellIDfolderPath = root:gCellIDfolderPath
Make/N=(90000)/O $Mean_trace_name
Wave Mean_trace = $Mean_trace_name
Wave Voltagetrace  = $VoltageTraceName //for calculating region of  PIC
String LeakSubtractWaveList = WaveList("Filtered_leak*",";", "")
Print (LeakSubtractWaveList)
Variable NumLeakSubtractWave = (ItemsInList(LeakSubtractWaveList))
Print (NumLeakSubtractWave)


for(j=0;j<NumLeakSubtractWave;j+=1)

string WorkingTraceName = StringFromList(j, LeakSubtractWaveList)

Wave Workingtrace = $WorkingTraceName

Mean_trace = (Mean_trace+Workingtrace)

endfor

Mean_trace = Mean_trace/NumLeakSubtractWave



//Display Mean_trace
//ModifyGraph zero(left)=6


//Define region to measure PIC start

Variable PICregionStart = -85


FindLevel/EDGE=1/P/Q Voltagetrace, PICregionStart
 PICregionStart = V_LevelX

//Define region end PIC measurement
Wavestats/Q  Voltagetrace

Variable PICregionEnd = V_maxRowLoc

//Find min location 

Wavestats/Q/R=[(PICregionStart),(PICregionEnd)] Mean_trace
Variable PICMaxloc = V_minRowLoc
Variable PICMaxVal = V_min
Variable PICMaxVolt = Voltagetrace[V_minRowLoc]
 

Print "Maximum PIC ampitude = " + num2Str(PICMaxVal)+ " pA"
Print "Voltage at Maximum PIC ampitude = " + num2Str(PICMaxVolt)+ " mV"

SetScale/P x 0,0.1,"", Mean_trace



Variable PICMaxTime = deltax(Mean_trace)*PICMaxloc
print (PICMaxTime)


Display/N=PICRampTraces


Newfreeaxis/O/W=PICRampTraces TopYaxis
AppendToGraph/W=PICRampTraces/L=TopYaxis Mean_trace 
ModifyGraph/W=PICRampTraces/Z  axisEnab (TopYaxis)={0.3,0.95};
ModifyGraph/W=PICRampTraces/Z freePos(TopYaxis)={0.1,kwFraction};
ModifyGraph/W=PICRampTraces/Z axisEnab (bottom)={0.1,0.9};
ModifyGraph/W=PICRampTraces/Z zero(TopYaxis)=6
Wavestats/Q Mean_trace
SetAxis/W=PICRampTraces TopYaxis,((PICMaxVal)+(PICMaxVal*0.1)),V_max
Label TopYaxis "Current (pA)"

Newfreeaxis/O/W=PICRampTraces LowerYaxis
AppendToGraph/W=PICRampTraces/L=LowerYaxis Voltagetrace 
ModifyGraph/W=PICRampTraces/Z  axisEnab (LowerYaxis)={0.1,0.25};
ModifyGraph/W=PICRampTraces/Z freePos(LowerYaxis)={0.1,kwFraction};
ModifyGraph/W=PICRampTraces/Z axisEnab (bottom)={0.1,0.9};
Wavestats/Q Voltagetrace
SetAxis/W=PICRampTraces LowerYaxis, V_min,V_max
Label LowerYaxis "Command Voltage (mV)"

Label bottom "Time (ms)"


Variable x1,x2,y1,y2
x1 = PICMaxTime
x2 = PICMaxTime
y1 = 0
y2 = PICMaxVal


SetDrawEnv xcoord=bottom,ycoord= TopYaxis
SetDrawEnv dash = 3
SetDrawEnv linethick=2
DrawLine x1,y1,x2,y2

Setdatafolder $gCellIDfolderPath

NVAR gVC_cap = gVC_cap

Variable/g gVC_PIC_Max_I = PICMaxVal/gVC_cap
Variable/g gVC_PIC_Max_V = PICMaxVolt

end



Function AxopatchMemProps()

//String savDF = GetDataFolder(1)

Setdatafolder root:



Variable refNum
String message = "Select passive membrane properties file"
String outputPath
String fileFilters = "Axon stats files (*.sta):.sta;"
fileFilters += "All Files:.*;"
Open /D /R /F=fileFilters /M=message refNum

String/G gOutputPath = S_fileName
//String/g gPassMemFileID = S_fileName[strsearch(S_fileName,":", Inf,1)+1,(strlen(S_fileName)-5)]


variable FilesInFolder
variable i
string Nameoffile
SVAR gCellIDFolderpath = root:gCellIDFolderpath


Setdatafolder $gCellIDFolderpath

String/g gPassMemFileID = S_fileName[strsearch(S_fileName,":", Inf,1)+1,(strlen(S_fileName)-5)]

String savDF = GetDataFolder(1)

NewDataFolder/S  AxoPassMem

String/g root:gPassMemFold = GetDataFolder(1)

LoadWave/W/A/E=1/G/O S_fileName

Wavestats/Q Memb_Test_0_Memb_Test_Ra__MOhm_
Variable VC_RA = V_avg

Wavestats/Q Memb_Test_0_Memb_Test_Rm__MOhm_
 Variable VC_RM = V_avg

Wavestats/Q Memb_Test_0_Memb_Test_Cm__pF_
Variable VC_cap = V_avg

Wavestats/Q Memb_Test_0_Memb_Test_Holding__ 
Variable VC_hold = V_avg


//Make global variables

String savDF2 = GetDataFolder(1)

Setdatafolder $gCellIDFolderpath

Variable/g gVC_RA = VC_RA
Variable/g gVC_RM = VC_RM
Variable/g gVC_cap = VC_cap
Variable/g gVC_hold = VC_hold

Setdatafolder $savDF2

PauseUpdate; Silent 1		// building window...
NewPanel/N=pass_mem_props/W=(488,90,1296,906)

Button button0,pos={338,754},size={100,40},proc=ButtonProcA,title="Continue",fSize=16



Display/W=(0,0,404,363)/HOST=pass_mem_props/N=R_access Memb_Test_0_Memb_Test_Ra__MOhm_ vs Time___s_
SetAxis left 0,50;DelayUpdate
Label left "Access Resistance (MOhms)"
Label bottom "Time (s)"
TextBox/C/N=text0/F=0 "Mean access resitance (MOhm) = "+ num2str(VC_RA)

Display/W=(404,0,808,363)/HOST=pass_mem_props/N=R_mem Memb_Test_0_Memb_Test_Rm__MOhm_ vs Time___s_
SetAxis left 0,3000;DelayUpdate
Label left "Membrane Resistance (MOhms)"
Label bottom "Time (s)"
TextBox/C/N=text0/F=0 "Mean membrane resitance (MOhm) = "+ num2str(VC_RM)

Display/W=(404,362,808,725)/HOST=pass_mem_props/N=I_hold Memb_Test_0_Memb_Test_Holding__ vs Time___s_
SetAxis left -100,0;DelayUpdate
Label left "Holding current (pA)"
Label bottom "Time  (s)"
TextBox/C/N=text0/F=0  "Mean holding current (pA) = "+ num2str(VC_hold)

Display/W=(0,362,404,725)/HOST=pass_mem_props/N=Cap Memb_Test_0_Memb_Test_Cm__pF_ vs Time___s_
SetAxis left 0,100;DelayUpdate
Label left "Membrane Capacitance (pF)"
Label bottom "Time (s)"
TextBox/C/N=text0/F=0 "Mean membrane capacitance (pF) = "+num2str(VC_cap)


SetDataFolder savDF


end

Function ButtonProcA(ba) : ButtonControl

//Controls action of Analyse button
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			
			Print "balls"
			
			Dowindow/K pass_mem_props
			Dowindow/K Table0
			
			
			//execute"trace_input()"
		
	endswitch

	return 0
End



Function DelayedRectifierAnalysis()

Variable LeakCalcStartTime = 5
Variable LeakCalcEndTime = 45
Variable DelayedRectStartTime = 200
Variable DelayedRectEndTime = 240
Variable EK = -82


// Calculate Delayed rectifier properties from file


Variable refNum
String message = "Select Delayed Rectifier recording file"
String outputPath
String fileFilters = "Axon stats files (*.abf):.abf;"
fileFilters += "All Files:.*;"
Open /D /R /F=fileFilters /M=message refNum

SVAR CellIDfolderpath = root:gCellIDFolderPath
SVAR PassMemFold = root:gPassMemFold


Setdatafolder $CellIDfolderpath
Newdatafolder Delayed_Rect
String/g gDelayRectCellID = S_fileName[strsearch(S_fileName,":", Inf,1)+1,(strlen(S_fileName)-5)]


Setdatafolder root:


NMImportFile( "new" ,S_fileName)
DoWindow /K ImportPanel

string tempDelaRectfolder = GetDataFolder(1)
string newDelaRectfolderpath = CellIDfolderpath+":Delayed_Rect:"

movedatafolder $tempDelaRectfolder, $newDelaRectfolderpath

String DelaRectFold = newDelaRectfolderpath+"nm"+gDelayRectCellID+":"

string/g root:gDelaRectFold = DelaRectFold

SVAR gDelaRectFold = root:gDelaRectFold

string VClampNum_traces_name = gDelaRectFold+"NumWaves"
NVAR VClampNum_traces = $VClampNum_traces_name
print VClampNum_traces
Setdatafolder $gDelaRectFold 
	
variable/g gVClampfirsttrace = 0
variable/g gVClamplasttrace = VClampNum_traces-1

SVAR gDelaRectFold = root:gDelaRectFold
NVAR gVClampFirstTrace = gVClampFirstTrace
NVAR gVClampLastTrace = gVClampLastTrace
Variable m
Variable VClampNumTraceSubset = (gVClampLastTrace-gVClampFirstTrace)+1
variable tracenumber = 0


variable Num_traces = VClampNumTraceSubset
variable/g gNumber_traces = Num_traces 


Variable SamplesPerWave
Variable x1
Variable y1
Variable x2
Variable y2
Variable gradient
Variable intercept
Variable num_points
Variable j
string File_name
Variable CurrentAmp,VoltageStep,ConductanceVal

//Make Waves for conductance calculations, max amplitude, voltage steps etc


Make/N=(gNumber_traces)/O Voltage_steps,Conductance,Current


//Make plots for delayed rectifier and voltage command

Display/N=Delayed_traces as"Delayed Rectifier"


Display/N=V_command_traces as "Voltage command"




//Calculate leak and delete from control trace

for(j=0;j<gNumber_traces;j+=1)

Setdatafolder $gDelaRectFold 
string TrcCrrNm = "RecordA" +num2str(j)
Wave TraceCurr = $TrcCrrNm
string TrcCmdNm = "RecordB" +num2str(j)
Wave TraceCmd = $TrcCmdNm

y1 = 0
x1 = 0
WaveStats/Q/R=(LeakCalcStartTime,LeakCalcEndTime) TraceCurr
y2 = V_avg
WaveStats/Q/R=(LeakCalcStartTime,LeakCalcEndTime) TraceCmd
x2 = V_avg
gradient = ((y2-y1)/(x2-x1))
intercept = y2-(gradient*x2)


WaveStats/Q TraceCurr

num_points = V_npnts


string leakNm = "Leak_adjusted_" +num2str(j)

Duplicate/O $TrcCrrNm, $leakNm

Wave LeakAdjust = $leakNm

LeakAdjust = TraceCurr - (TraceCmd*gradient+intercept)

//Calculate max current voltage driving force voltage
WaveStats/Q/R=(DelayedRectStartTime,DelayedRectEndTime) LeakAdjust
CurrentAmp = V_avg
WaveStats/Q/R=(DelayedRectStartTime,DelayedRectEndTime) TraceCmd
VoltageStep = V_avg

Voltage_steps[j] = VoltageStep
Current[j] = CurrentAmp
Conductance[j] = CurrentAmp/(VoltageStep-EK)

AppendToGraph/W=Delayed_traces $leakNm 
AppendToGraph/W=V_command_traces $TrcCmdNm

endfor


//Calculate Gmax //Ignores the first 5 points becasue of errors amplified by measurements close to EK

WaveStats/Q/R=[5,gNumber_traces] Conductance

Variable Gmax = V_max


//Calculates and plots %Gmax slope activation, midpoint activation

Make/N=(gNumber_traces)/O Gmax_graph =(conductance/Gmax)*100


Display/N=Gmaxplot Gmax_graph vs  Voltage_steps
SetAxis/A=2 left;DelayUpdate
//SetAxis bottom -60,59.976616
Label left "Conductance (% Gmax)"
Label bottom "Command Voltage (mV)"
TextBox/C/N=text1/F=0/A=MT "Conductance % max"


CurveFit/NTHR=0 Sigmoid  Gmax_graph /X=voltage_steps /D
ModifyGraph/W=Gmaxplot mode(Gmax_graph)=3,marker(Gmax_graph)=8

Wave W_coef

variable midpoint_activation = W_coef[2]
variable slope_activation = W_coef[3]

//Cond norm to cap conductance plot

string CurrDF = GetDataFolder(1)

Setdatafolder $CellIDfolderpath

NVAR Mean_cap = gVC_cap

Setdatafolder  $CurrDF


Make/O/N=(gNumber_traces) Normconductance =((conductance*1000)/Mean_cap)

Display/N=Gplot Normconductance vs  Voltage_steps
SetAxis/A=2 left;DelayUpdate
//SetAxis bottom -60,59.976616
Label left "Norm Conductance"
Label bottom "Command Voltage (mV)"
//TextBox/C/N=text1/F=0/A=MT "Norm Conductance"

CurveFit/NTHR=0 Sigmoid  Normconductance[1,gNumber_traces] /X=Voltage_steps /D
ModifyGraph mode(Normconductance)=3,marker(Normconductance)=8

Wave W_coef
Variable posx1,posx2,posy1,posy2
GetAxis bottom; posx1= V_min
posx2 = V_max
posy1 = W_coef[1]
posy2 = W_coef[1]
Variable Peak_conductance =  W_coef[1]

SetDrawEnv xcoord= bottom,ycoord= left
SetDrawEnv arrow= 0,dash=1

DrawLine posx1,posy1,posx2,posy2

//Resize y axis
variable new_y_min, new_y_max
GetAxis left; new_y_min = V_min
new_y_max = (V_max)*1.1
SetAxis left new_y_min,new_y_max

TextBox/C/N=text0/F=0/A=LT/X=0/Y=10 "Max conductance = "+ num2str(W_coef[1])+ " pS/pF"


//Add labels to plots

Label/W=Delayed_traces left "Current (pA)"
Label/W=Delayed_traces bottom "Time (ms)"
//TextBox/W=Delayed_traces/C/N=text1/F=0/A=MT "Leak subtracted Current"

Label/W=V_command_traces left "Command Voltage (mV)"
Label/W=V_command_traces bottom "Time (ms)"
//TextBox/W=V_command_traces/C/N=text1/F=0/A=MT "Command potential"


//Make global variables for potassium current data

String savDF2 = GetDataFolder(1)

Setdatafolder $CellIDfolderpath

Variable/g gVC_DR_Peak_S  = Peak_Conductance
Variable/g gVC_DR_midpoint_act = midpoint_activation
Variable/g gVC_DR_slope_act = slope_activation

Setdatafolder $savDF2



end





Function  FixUndefinedValues() 

String VC_List_of_variables =   "gVC_RA;gVC_RM;gVC_cap;gVC_hold;gVC_DR_Peak_S;gVC_DR_midpoint_act;gVC_DR_slope_act;gVC_PIC_Max_I;gVC_PIC_Max_V"
String VC_List_of_strings = "gDelayRectCellID;gPICCellID;gPassMemFileID"


Variable i,j,VariableExists,v
String CurrVar,CurrTraceID

Setdatafolder root:

SVAR gCellident = root:gCellident
SVAR gCellIDfolderpath = root:gCellIDFolderpath



Setdatafolder $gCellIDfolderpath

//Add NaN for undefined measurements 

String VC_defined_variables = VariableList("*", ";",4)
Variable VC_No_variables = Itemsinlist(VC_List_of_variables)

for(i=0;i<VC_No_variables;i+=1)
CurrVar  = StringFromList(i, VC_List_of_variables)
String CurrentVarName = CurrVar
VariableExists = (Stringmatch(VC_defined_variables,"*"+CurrVar+"*"))

if (VariableExists==0)
Variable/g $CurrVar = NaN
endif
print CurrVar

Endfor


//Add "undefined" for Trace IDs wher appropriate 

String VC_defined_traces = StringList("*", ";")
Variable VC_No_traces = Itemsinlist(VC_List_of_strings)

for(j=0;j<VC_No_traces;j+=1)
CurrTraceID  = StringFromList(j, VC_List_of_strings)
VariableExists = (Stringmatch(VC_defined_traces,"*"+CurrTraceID+"*"))

if (VariableExists==0)
String/g $CurrTraceID = "undefined"
endif
print CurrTraceID

Endfor

VCMeasurementsTable()

End



Function VCMeasurementsTable()

Setdatafolder root:

SVAR gCellident = root:gCellident
SVAR gCellIDFolderpath = root:gCellIDFolderpath
NVAR gPassage = gPassage
NVAR gDIV = gDIV
SVAR gPlateDate = gPlateDate
SVAR gAstro = gAstro
SVAR gRecType = gRecType
SVAR gCellline = gCellline


Setdatafolder $gCellIDFolderpath

NVAR gVC_RA = gVC_RA
NVAR gVC_RM = gVC_RM
NVAR gVC_cap = gVC_cap
NVAR gVC_hold = gVC_hold
NVAR gVC_DR_Peak_S = gVC_DR_Peak_S
NVAR gVC_DR_midpoint_act = gVC_DR_midpoint_act
NVAR gVC_DR_slope_act = gVC_DR_slope_act
NVAR gVC_PIC_Max_I = gVC_PIC_Max_I 
NVAR gVC_PIC_Max_V = gVC_PIC_Max_V
SVAR gDelayRectCellID =gDelayRectCellID
SVAR gPICCellID = gPICCellID
SVAR gPassMemFileID = gPassMemFileID

variable roundedPICamp =  round(gVC_PIC_Max_I * (10^2)) / (10^2)


Display/N=VCMeasurements/W=(74.25,95,484.5,278.75)

TextBox/W=VCMeasurements/N=text0/A=LB/X=1.47/Y=41.41 "Cell:\t\t" + gCellident+"\r\rPassage:\t" +num2str(gPassage)+"\rCell line:\t" +gCellline+"\rAstrocytes:\t" +gAstro+"\rDIV:\t\t" + num2str(gDIV) +"\rDate of plating:\t"+ gPlateDate
TextBox/W =VCMeasurements/N=text5/A=LB/X=1.28/Y=4.08 "Recording type:\t" + gRecType+ "\rRmembrane:\t" + num2str(round(gVC_RM)) +"\tMOhm\rCapacitance:\t" + num2str(round(gVC_cap)) +"\tpF\rI hold at -60 mV:\t" + num2str(round(gVC_hold))+"\tpA\rRAccess:\t" + num2str(round(gVC_RA))+"\tpF"
TextBox/W=VCMeasurements/N=text3/A=LB/X=38.57/Y=66.53 "Passive Mem .sta file ID:\t\t" + gPassMemFileID +"\rPIC file ID:\t\t\t" + gPICCellID +"\rDelayed Rectifier ID:\t\t" + gDelayRectCellID
TextBox/W=VCMeasurements/N=text6/A=LB/X=52.10/Y=46.94 "PIC max amplitude:\t"+num2str(roundedPICamp)+"\tpA/pF\rPIC voltage at max:\t"+num2str(round(gVC_PIC_Max_V))+"\tmV"
TextBox/W=VCMeasurements/N=text7/A=LB/X=51.37/Y=21.22 "DR max conductance:\t"+num2str(round(gVC_DR_Peak_S))+"\tpS/pF\rDR act. midpoint:\t\t"+num2str(round(gVC_DR_midpoint_act))+"\tmV\rDR act. slope:\t\t"+num2str(round(gVC_DR_slope_act))+"\tpS/mV"

AppendVCDataToDataFile()

End 


Function AppendVCDataToDataFile()


Setdatafolder root:

SVAR gCellident = root:gCellident
SVAR gCellIDFolderpath = root:gCellIDFolderpath



Setdatafolder $gCellIDFolderpath

NVAR gVC_RA = gVC_RA
NVAR gVC_RM = gVC_RM
NVAR gVC_cap = gVC_cap
NVAR gVC_hold = gVC_hold
NVAR gVC_DR_Peak_S = gVC_DR_Peak_S
NVAR gVC_DR_midpoint_act = gVC_DR_midpoint_act
NVAR gVC_DR_slope_act = gVC_DR_slope_act
NVAR gVC_PIC_Max_I = gVC_PIC_Max_I 
NVAR gVC_PIC_Max_V = gVC_PIC_Max_V
SVAR gDelayRectCellID =gDelayRectCellID
SVAR gPICCellID = gPICCellID
SVAR gPassMemFileID = gPassMemFileID

String nb  = "cell_data"


Notebook $nb selection={endOfFile, endOfFile}

Notebook cell_data text = "VC_Pass_Membrane_File_ID\t" +gPassMemFileID+ "\r"
Notebook cell_data text = "VC_R_Access_M_Ohm\t" + num2str(gVC_RA)+"\r"
Notebook cell_data text = "VC_R_Membrane_M_Ohm\t" + num2str(gVC_RM) +"\r"
Notebook cell_data text = "VC_Capacitance_pF\t" + num2str(gVC_cap) +"\r"
Notebook cell_data text = "VC_I_hold_pA\t" + num2str(gVC_hold) +"\r"
Notebook cell_data text = "Delayed_Rectifier_Trace_ID\t" +gDelayRectCellID+ "\r"
Notebook cell_data text = "DR_S_max_pS_per_pF\t"+ num2str(gVC_DR_Peak_S) +"\r"
Notebook cell_data text = "DR_Activation_curve_midpoint_mV\t" + num2str(gVC_DR_midpoint_act) +"\r"
Notebook cell_data text = "DR_Activation_curve_slope_pS_per_mV\t" + num2str( gVC_DR_slope_act) +"\r"
Notebook cell_data text = "Persistent_Inward Current_TraceID\t" + gPICCellID+ "\r"
Notebook cell_data text = "Maximum_PIC_amplitude_pA_per_pF\t" + num2str(gVC_PIC_Max_I )+"\r"
Notebook cell_data text = "Voltage_at_maximum_PIC_mV\t" + num2str(gVC_PIC_Max_V) +"\r"


End





Function MakeVCLayout()

SVAR gCustomPath = root:CustomPath

NewLayout/N=VClayout/W=(264.75,144.5,856.5,636.5) 
Appendlayoutobject/F=0/R=(16.5,22.5,411,214.5) graph VCMeasurements
Appendlayoutobject/F=0/R=(400.5,16.5,630,231) graph PICRampTraces
Appendlayoutobject/F=0/R=(304.5,430.5,595.5,610.5) graph Gplot
Appendlayoutobject/F=0/R=(303,619.5,595.5,763.5) graph Gmaxplot
Appendlayoutobject/F=0/R=(28.5,654,283.5,762) graph V_command_traces
Appendlayoutobject/F=0/R=(19.5,420,271.5,631.5) graph Delayed_traces
Appendlayoutobject/F=0/R=(370.5,252,561,402) graph PICGraphRep1
Appendlayoutobject/F=0/R=(196.5,252,388.5,402) graph PICGraphRep2
Appendlayoutobject/F=0/R=(28.5,252,216,402) graph PICGraphRep3


PrintSettings/W=VClayout margins={0,0,0,0}

SVAR/Z gCell_ident = root:gCellident

String SaveFileNameData = gCustomPath+"Ephys Igor output\\"+gCell_ident+"_Traces_VC.pdf"

SavePict/E=-8/O/WIN=VClayout as SaveFileNameData

End






Function RemoveVCdata()

Variable i
String CurrWin
String OpenWindows = WinList("*", ";","WIN:7")
Variable NumOpenWindows = Itemsinlist(OpenWindows)

for(i=0;i<NumOpenWindows;i+=1)
CurrWin  = StringFromList(i, OpenWindows)
print (CurrWin)
DoWindow/K $CurrWin

Endfor



End




