

//Current clamp Long step analysis. Calculates single AP charactersitics of the 1st AP
// evoked by  the minimum current step which evokes an AP. Calculate Spike Frequency adaptaion on step where number of APs is greater than 6.

//Changes in version 1_1 (Changed 2014-01-30)
//Wave references changed to work with clampex 10.4 data. 

//Changes in version 2_0 (Changed 2014-06-30)
//Action potential rise and fall rates calculated using the dv/dt plot to determine maximum rate of rise and fall


//Changes in version 2_1 (changes 2015-05-04)
//True rheobase calculated

//Changed so that AP must be > 0 mV to be included

//Improves AP No vs Current amplitude formatting

//Changed for scaling (changes 2018-07-26)


//constant K_start_step_time = 10
//constant K_end_step_time =  510

//
//constant K_start_step_AP_time = 123.4
//constant K_end_step_AP_time =  1123.4

constant K_start_step_AP_time = 126.6
constant K_end_step_AP_time =  1126.6

constant K_start_step_Hyp_time = 139
constant K_end_step_Hyp_time =  2139
constant K_AP_detect_start_time = -2
constant K_AP_detect_end_time = 2



Function load_steps_traces(Analysis, WorkingFolder)
String Analysis, WorkingFolder

Setdatafolder root:

SVAR gCellFolderName = root:gCellFolderName
DFREF CellFolderDFR = $gCellFolderName

SVAR gAnalysisType
NVAR gAutoScaleCurr
NVAR gAutoScaleVolt
NVAR gDepolStep

setdatafolder CellFolderDFR
SVAR gAbfFiles
SVAR CellFolderFilePath

String Baseline,Amplitude


if( StringMatch(gAnalysisType, "Manual Analysis"))


Variable refNum
String message = "Select Action Potential properties file"
String outputPath
String fileFilters = "Axon stats files (*.abf):.abf;"
fileFilters += "All Files:.*;"

Open /D /R /F=fileFilters /M=message refNum

else

string APFile = stringfromlist(1, gAbfFiles)

S_fileName = CellFolderFilePath+APFile
endif

Setdatafolder root:


NMImportFile( "new" ,S_fileName)
DoWindow /K ImportPanel


String TempAPFolder = GetDataFolder(1)

String/g CellFolderDFR:gAPFold =  GetDataFolder(1)

String/g CellFolderDFR:gAPTrace = ParseFilePath(0, S_fileName, ":", 1, 0)

RenameDataFolder  $TempAPFolder, ActionPotential


SetDataFolder CellFolderDFR

MoveDataFolder root:ActionPotential, $gCellFolderName


DifferentiatePlot()

End

Function DifferentiatePlot()

Variable Baseline,Amplitude,i

String TrcPotNm, TrcCmdCurrNm


SetDataFolder root:
NVAR gAutoScaleCurr
NVAR gAutoScaleVolt
NVAR gBaselineScaleCurr
SVAR gCellFolderName
SVAR gCustompath
NVAR gDepolStep
NVAR gSelectedRadioButton

SetDataFolder $(gCellFolderName)

SVAR gAPFold
SVAR gAPDFpath
SVAR gCell_ID
SVAR gGenotype





Setdatafolder ActionPotential

NVAR Num_traces = NumWaves

//Scale Voltage Current

for(i=0;i<Num_traces;i+=1)

TrcPotNm = "RecordA" +num2str(i)
Wave TracePot = $TrcPotNm
TracePot = TracePot/gAutoScaleVolt

TrcCmdCurrNm = "RecordB" +num2str(i)
Wave TraceCmdCurr = $TrcCmdCurrNm
TraceCmdCurr = TraceCmdCurr/gAutoScaleCurr

endfor

//Make folder for AP times
string AP_times_folder_name = gCustompath+gCell_ID+"_"+gGenotype+":"
NewPath/C/O AP_times_folder, AP_times_folder_name


print "number of waves = "+num2str(Num_traces)


Variable SamplesPerWave
Variable num_points
Variable j,FirstAPOnly,k
string File_name

Make/O/N=(Num_traces) NumberAPs
Make/O/N=(Num_traces) ComCurrValues


variable n=0
variable o=0
FirstAPOnly = 0


//Determine region for step times
TrcPotNm = "RecordA" +num2str(Num_traces-1)
 Wave TracePot = $TrcPotNm
 

TrcCmdCurrNm = "RecordB" +num2str(Num_traces-1)
 Wave TraceCmdCurr = $TrcCmdCurrNm
 

Wavestats/Q $TrcCmdCurrNm

Smooth 20, $TrcCmdCurrNm

variable halfCurrStepval = (V_max+V_min)/2 



FindLevels/DEST=stepregiontimes/Q $TrcCmdCurrNm, halfCurrStepval

Wave stepregiontimes

variable stepstarttime = (stepregiontimes[0])
variable stependtime = (stepregiontimes[1])

Print " Step start  time " +num2str(stepstarttime)

//If there is a problem with step time calculation can use manually defined start/end times

stepstarttime = K_start_step_AP_time
stependtime = K_end_step_AP_time


for(j=0;j<Num_traces;j+=1)


	//Setdatafolder $gAP_train_1_path
	TrcPotNm = "RecordA" +num2str(j)
	 Wave TracePot = $TrcPotNm
	TrcCmdCurrNm = "RecordB" +num2str(j)
	Wave TraceCmdCurr = $TrcCmdCurrNm
	

	//Command current amplitude
	//Baseline
	Wavestats/Q/R=(stepstarttime-25,stepstarttime-15) $TrcCmdCurrNm
	Baseline = V_avg

	//Raw amplitude
	Wavestats/Q/R=(stepstarttime-25,stepstarttime-15) $TrcCmdCurrNm
	Amplitude = V_avg

	//Delta amplitude	
	Wavestats/Q/R=(stepstarttime,stependtime) $TrcCmdCurrNm
//---------------------------------------------------------------Changed to manual step calc-------
	//if(gSelectedRadioButton==1)
	//ComCurrValues[j] = V_avg
	//else
	//ComCurrValues[j] = gDepolStep * j
	//endif
	ComCurrValues[j] = 20 * j
	
	

//-------------------------------------------------------------------------------------------------


	//Differentiate voltage plot to find AP times
	
	
	string Filtered_trace_name = "RecordA" +num2str(j)+"_filtered"
	string TrcPotDiffNm = "RecordA" +num2str(j)+"_DIF"
	
	Duplicate/O Tracepot, $Filtered_trace_name
	
	if(deltax($TrcPotNm)==0.002)
		FilterFIR/LO={0.015,0.016,101}/WINF=KaiserBessel20 $Filtered_trace_name		
	else
		Make/O/D/N=0 coefs
		FilterFIR/DIM=0/LO={0.15,0.2,101}/COEF coefs, $Filtered_trace_name	
	endif
	
	
	

	Differentiate $Filtered_trace_name/D=$TrcPotDiffNm
	//Smooth 200, $TrcPotDiffNm
	WaveStats/Q $TrcPotDiffNm
	string AP_times_Nm = "RecordA" +num2str(j)+"_AP_times"

	Make/O/D/N=0 $AP_times_Nm
	Make/O/D/N=0 RealAPNo
	
	print("start time: "+num2str(stepstarttime)+" end time: " + num2str(stependtime))
	
	//Find potential APs using first derivative
	Findlevels/DEST=$AP_times_Nm/EDGE=1/Q/R=(K_start_step_AP_time,K_end_step_AP_time)/M=2 $TrcPotDiffNm, 5	
	
	///Correct for step time 
	string corr_AP_times_name  = AP_times_Nm+"_corr"
	Make/O/D/N=0 $corr_AP_times_name
	//Duplicate/O $AP_times_Nm $corr_AP_times_name
	Wave Corr_AP_times = $corr_AP_times_name
	

	
	//if aps founds in trace
	if(V_flag==1)
	

		Variable AP_start_time, AP_end_time, AP_VmaxA
		Wave AP_times = $AP_times_Nm		
		
		//go through each 'AP'
		For(k=0;k<numpnts(AP_times);k+=1)
			AP_start_time =(AP_times[k])+K_AP_detect_start_time			
			AP_end_time = (AP_times[k])+K_AP_detect_end_time	
			Wavestats/Q/R=(AP_start_time,AP_end_time)Tracepot
			AP_VmaxA = V_max			
			print("AP start time: "+num2str(AP_start_time))			
			print("AP end time: "+num2str(AP_end_time))
			print("AP max amplitude: "+num2str(AP_VmaxA))			
			
			//Consider a real AP with a max val above zero

			if(V_max>0)
			print("accept")
			
				//Add a maximum AP height value to RealAPNo		
			
				InsertPoints k,1, RealAPNo
				RealAPNo[k] = AP_VmaxA	
				
				//Add a AP timepoint to Corrected AP times				
							
				InsertPoints inf,1, Corr_AP_times
				Corr_AP_times[inf] =  AP_times[k]
				
			else
			
			print("ignore!!!")
			
			endif

		Endfor
		
		

		//if no APs detected add zero value to table
		if((numpnts(RealAPNo)==0))

			killwaves AP_times
			NumberAPs[j] = 0

		else
		
		//if APs detected, add the number of points in RealAPNo wave which
		//is equivalent to the number of APs in a sweep
			NumberAPs[j] = numpnts(RealAPNo)
			Corr_AP_times -= stepstarttime
			
		endif


	variable AP_calc_done = 0
	
	
	print("Number of action potentials: "+num2str(numpnts(RealAPNo)))

	if ((numpnts(RealAPNo)>0)&FirstAPOnly==0)	

			
		double_plot(TrcPotNm)
		Wavestats/Q/R=(10,20) $TrcCmdCurrNm
		Variable Base_Line_Rheobase = V_avg
		string/g gAPFileName = TrcPotNm
		Wavestats/Q/R=(stepstarttime+2,stependtime-2) $TrcCmdCurrNm
		Variable  Rheobase = (V_avg - Base_Line_Rheobase)


//print "Action potential times " +  (AP_times)
		FindLevel/EDGE=1/P/Q/R=(stepstarttime+1,stependtime-1) $TrcPotDiffNm, 5
	//print (V_LevelX)
		Variable Vthresholdpoint = V_LevelX
		Variable Vthresholdtime = (round(V_LevelX)*(deltax(tracepot)))
		
		
	//Plot AP	
	
	//Coordinates for plotting AP potential 10 ms before and after plot
		Variable startplot = (round(V_LevelX)*(deltax(tracepot))-4)
		Variable endplot = (round(V_LevelX)*(deltax(tracepot))+15)
	
		Duplicate/O/R=(startplot,endplot) Tracepot, CheckAPplot
		
		Display CheckAPplot
		
		String/g gFullAPCalcTrace = TrcPotNm
	
	//calculate Vthreshold
		Smooth 200, CheckAPplot	
	
		Differentiate CheckAPplot /D=CheckAPplot_dif
		FindLevel/EDGE=1/Q/P CheckAPplot_dif, 5
		
		Variable AP_Vthreshold = CheckAPplot[V_LevelX]
		
		
	
	//Calculate Vmax
		Wavestats/Q CheckAPplot
		Variable AP_max_amp = V_max
		Variable AP_max_time = V_maxloc
	 
		
	
	//Calculate AP duration
		
		Variable FiftyPercentAP		
		FiftyPercentAP=((AP_max_amp-AP_Vthreshold)*0.5)+AP_Vthreshold	
		
		Variable/g gPlotFiftyPercentAP = FiftyPercentAP		
		Variable/g gAP_Vthreshold = AP_Vthreshold
		Variable/g gAP_max_amp = AP_max_amp
		
		
		print "Maximum AP value = " +num2str(AP_max_amp)
		print "AP threshold = " +num2str(AP_Vthreshold)	
		Print "Fifty Percent AP Value = "+num2str(FiftyPercentAP)		
		
	
		FindLevel/EDGE=1/Q CheckAPplot, FiftyPercentAP
		Variable FiftyPercentAPriseTime = V_LevelX
		Variable/g gPlotFiftyPercentAPrisetime = FiftyPercentAPriseTime	
	
		print "50% rise time = " + num2str(FiftyPercentAPriseTime)+" ms"
		
		FindLevel/EDGE=2/Q CheckAPplot, FiftyPercentAP
		Variable FiftyPercentAPfallTime = V_LevelX
		Variable/g gFiftyPercentAPfallTime = FiftyPercentAPfallTime
		
		print "50% fall time = " + num2str(FiftyPercentAPfallTime)+" ms"		
		
	
		Variable AP_duration = FiftyPercentAPfallTime-FiftyPercentAPriseTime
		print  "AP duration = "+num2str(AP_duration)+" ms"
	
	//Calculate max rate of rise and fall of AP
	
		Wavestats/Q CheckAPplot_dif
		Variable Max_AP_rise = V_max
		Variable Max_AP_rise_loc = V_maxloc
		Variable Max_AP_fall = V_min
		Variable Max_AP_fall_loc = V_minloc
		
		
		DFREF CurrDF
		CurrDF = GetDataFolderDFR()
		
		SetDataFolder  $(gCellFolderName)
	
		Variable/g gMax_AP_rise = Max_AP_rise
		Variable/g gMax_AP_rise_loc = Max_AP_rise_loc
		Variable/g gMax_AP_fall = Max_AP_fall
		Variable/g gMax_AP_fall_loc = Max_AP_fall_loc	
		
		Variable/g gAP_duration = AP_duration
		Variable/g gAP_amplitude = AP_max_amp
		Variable/g gAP_threshold = AP_Vthreshold
		
		Variable/g gMax_AP_rise = Max_AP_rise
		Variable/g gMax_AP_fall = Max_AP_fall
		
		SetdataFolder CurrDF		
			
		
		DrawAPplot(Vthresholdtime,AP_Vthreshold,AP_max_amp,FiftyPercentAPfallTime,FiftyPercentAPriseTime,FiftyPercentAP,AP_max_time)
		FirstAPOnly=1			
		
	
	endif


	
	endif

endfor

print(gCellFolderName)

trough(gCellFolderName)


//For decrement and SFA calculation

Wave NumberAPs

Wavestats NumberAPs
Variable  RowMaxAPNo = V_maxRowLoc
Variable  MaxNoAPs = V_max
Variable half_max_ap_no = ceil(MaxNoAPs/2)
Variable sweep_half_max

Findlevel/EDGE=1/P NumberAPs  half_max_ap_no
print(V_LevelX)
print(V_max)
Variable half_AP_trace_number = floor(V_LevelX)
String half_max_AP_trace_nm = "RecordA" +num2str(half_AP_trace_number)
Wave half_max_AP_trace = $half_max_AP_trace_nm







//Display/N=half_max_trace $half_max_AP_trace_nm

print(half_max_AP_trace_nm)


String half_max_AP_trace_times_nm = "RecordA" +num2str(half_AP_trace_number)+"_AP_times_corr"

string table_name = "half_max_AP_trace"
Edit/N=$table_name $half_max_AP_trace_times_nm 
SaveTableCopy/W=$table_name/T=1/O/P=AP_times_folder	 as table_name+".txt"






Wave half_max_AP_trace_times = $half_max_AP_trace_times_nm

//Times Corrected_for_plotting
half_max_AP_trace_times += stepstarttime



Variable last_AP_time = half_max_AP_trace_times[numpnts(half_max_AP_trace_times)-1]
Variable penultimate_AP_time = half_max_AP_trace_times[numpnts(half_max_AP_trace_times)-2]
Variable first_AP_time = half_max_AP_trace_times[0]
Variable second_AP_time = half_max_AP_trace_times[1]

//Adaptation between isi
variable first_isi = second_AP_time - first_AP_time
variable last_isi = last_AP_time - penultimate_AP_time
variable SFA = last_isi/first_isi

string temp_cell_folder_name = "cell_"+gCell_ID

variable/G root:$(temp_cell_folder_name):gfirst_isi = first_isi

print("first isi: "+num2str(first_isi))
print("last isi: "+num2str(last_isi))
print("spike_frequency adaptation" + num2str(SFA))


Variable first_AP_start_t,first_AP_end_t,last_AP_start_t,last_AP_end_t
//First AP

first_AP_start_t =first_AP_time-4
first_AP_end_t = first_AP_time+10	

Duplicate/O/R=(first_AP_start_t,first_AP_end_t) half_max_AP_trace first_AP_trace

last_AP_start_t =last_AP_time-4
last_AP_end_t = last_AP_time+10

Duplicate/O/R=(last_AP_start_t,last_AP_end_t) half_max_AP_trace last_AP_trace


setscale x,0,deltax(first_AP_trace), First_AP_trace,last_AP_trace


wavestats/Q first_AP_trace

variable peak_amplitude = V_max
variable peak_amplitude_loc = V_maxLoc
print(peak_amplitude_loc)




wavestats/Q last_AP_trace

variable peak_amplitude_l = V_max
variable peak_amplitude_loc_l = V_maxLoc
print(peak_amplitude_loc_l)

setscale/P x,0-peak_amplitude_loc,deltax(first_AP_trace), First_AP_trace

setscale/P x,0-peak_amplitude_loc_l,deltax(last_AP_trace), last_AP_trace



Display/N=first_last_traces First_AP_trace,last_AP_trace
SetAxis/W=first_last_traces bottom -0.001,0.002

ModifyGraph/W=first_last_traces rgb(first_AP_trace)=(0,0,65535)
Legend/W=first_last_traces/C/N=text0/F=0/B=1

//Threshold change

//Smooth 200, First_AP_trace

Differentiate First_AP_trace /D=First_AP_trace_dif
FindLevel/EDGE=1/Q/P First_AP_trace_dif, 5000
Variable First_AP_threshold = First_AP_trace[V_LevelX]
print(First_AP_threshold)

//Smooth 200, Last_AP_trace

Differentiate Last_AP_trace /D=Last_AP_trace_dif
FindLevel/EDGE=1/Q/P Last_AP_trace_dif, 5000
Variable Last_AP_threshold = Last_AP_trace[V_LevelX]
print(Last_AP_threshold)


Variable Change_in_AP_threshold = Last_AP_threshold/First_AP_threshold
print("threshold change = less than 1 is depol"+num2str(Change_in_AP_threshold))


//Amplitude change
Variable first_AP_amp = peak_amplitude-first_AP_threshold
print(first_AP_amp)

Variable last_AP_amp = peak_amplitude_l-last_AP_threshold
print(last_AP_amp)

Variable Change_in_AP_amplitude = last_AP_amp/first_AP_amp
print("amplitude change "+num2str(Change_in_AP_amplitude))





//Maximum AP rise rate change

Wavestats/Q First_AP_trace_dif
Variable first_AP_max_rate = V_max

Wavestats/Q Last_AP_trace_dif
Variable Last_AP_max_rate = V_max

Variable Change_in_AP_rate = Last_AP_max_rate/first_AP_max_rate

print("max change "+num2str(Change_in_AP_rate))






Variable begin_trace = -0.001
Variable end_trace = 0.002

Duplicate/O/R=(begin_trace, end_trace) First_AP_trace, first_for_dub
Duplicate/O/R=(begin_trace, end_trace) Last_AP_trace, last_for_dub

setscale/P x,0,deltax(first_for_dub), first_for_dub,last_for_dub



Smooth 10, first_for_dub
Smooth 10, last_for_dub

Differentiate first_for_dub /D=First_AP_dif
Differentiate last_for_dub /D=Last_AP_dif


Display/N=phase_plane First_AP_dif vs first_for_dub
AppendtoGraph/W=phase_plane Last_AP_dif vs last_for_dub
ModifyGraph/W=phase_plane rgb(First_AP_dif)=(0,0,65535)
Legend/W=phase_plane/C/N=text0/F=0/B=1/A=MC












//Amplitude


//Plot AP detection
variable max_x = numpnts(half_max_AP_trace)*deltax(half_max_AP_trace)

Make/O/N=(numpnts(half_max_AP_trace_times)) AP_zero
AP_zero = 1




String half_max_I_trace_nm = "RecordB" +num2str(half_AP_trace_number)
Wave half_max_I_trace = $half_max_I_trace_nm


Display/N=half_max_trace $half_max_AP_trace_nm

Wavestats half_max_AP_trace

variable line_height = V_max+5




SetDrawEnv xcoord= bottom,ycoord= left
SetDrawEnv linethick=3

DrawLine first_AP_time,line_height,second_AP_time,line_height

SetDrawEnv xcoord= bottom,ycoord= left
SetDrawEnv linethick=3
DrawLine penultimate_AP_time,line_height,last_AP_time,line_height


ModifyGraph/W=half_max_trace axisEnab(left)={0.2,0.9}
AppendToGraph/W=half_max_trace/L=left2/B=bottom2 $half_max_I_trace_nm
ModifyGraph/W=half_max_trace axisEnab(left2)={0,0.15},freePos(left2)=0,freePos(bottom2)={0,left2}
ModifyGraph noLabel(left2)=2,axThick(left2)=0,lSize=0.3,axThick=0.3
ModifyGraph noLabel(bottom2)=2,axThick(bottom2)=0
Setaxis/W=half_max_trace left, -80,55



AppendToGraph/W=half_max_trace/L=left3/B=bottom3  AP_zero vs half_max_AP_trace_times
	ModifyGraph/W=half_max_trace axisEnab(left3)={0.91,1},freePos(left3)=0,freePos(bottom3)={0,left2}
	ModifyGraph/W=half_max_trace mode(AP_zero)=3,marker(AP_zero)=19,msize(AP_zero)=0.2,rgb(AP_zero)=(1,16019,65535)
	ModifyGraph noLabel(left3)=2,axThick(left3)=0
	ModifyGraph noLabel(bottom3)=2,axThick(bottom3)=0
	Setaxis/W=half_max_trace bottom3, 0, max_x


DFREF CurrentDF
//Save varaibles
CurrentDF = getdataFolderDFR()

SetDataFolder  $(gCellFolderName)
Variable/g gAP_SFA = SFA
Variable/g gChange_in_AP_amplitude = Change_in_AP_amplitude
Variable/g gChange_in_AP_rate = change_in_AP_rate
Variable/g gChange_in_AP_threshold = change_in_AP_threshold
Variable/g ghalf_max_AP_sweep = half_AP_trace_number



SetdataFolder CurrentDF
//



//Plot trace with maximum number of action potentials
//Setdatafolder $gAP_train_1_path
String MaxTrcPotNm = "RecordA" +num2str(RowMaxAPNo)
Wave MaxTracePot = $MaxTrcPotNm

Display/N=MaxNumAPtrace $MaxTrcPotNm
Label left "Membrane potential (mV)"
Label bottom "Time (ms)"

String PlotLabel = gCell_ID+"Max AP firing trace "

TextBox/W=MaxNumAPtrace/B=1/C/N=text1/F=0/A=MT PlotLabel
SetAxis/W=MaxNumAPtrace bottom 0,1500

//For plot
Display/N=MaxAPtracepng $MaxTrcPotNm
SetAxis/W=MaxAPtracepng bottom 0,1500
ModifyGraph/W=MaxAPtracepng noLabel(left)=2,axThick(left)=0
ModifyGraph/W=MaxAPtracepng noLabel(bottom)=2,axThick(bottom)=0

String SaveFileNameData = gCustomPath+"Image_data:"+gCell_ID+"_AP_trace.png"

DoWindow/F MaxAPtracepng

SavePICT/O/C=1/E=-5/TRAN=1/B=576 as SaveFileNameData




//Currrent at maximum number of action potentials
String MaxTrcCurrentNmFxd = "RecordB" +num2str(RowMaxAPNo)
Wave MaxTraceCurrentFxd = $MaxTrcCurrentNmFxd

Wavestats/Q/R=(10,20) $MaxTrcCurrentNmFxd
Variable  Base_Line_Current = V_avg

Wavestats/Q/R=(stepstarttime,stependtime) $MaxTrcCurrentNmFxd

Variable  I_at_max_AP = (V_avg - Base_Line_Current)




SetDataFolder  $(gCellFolderName)


variable/g gI_at_max_AP = I_at_max_AP 
variable/g gMaxNoAPs = MaxNoAPs
variable/g gRheobase = Rheobase

SetDataFolder Actionpotential



//Plot maximum number of APs vs command current with markers


Make/O/N=(Num_traces) zwaveformarkers
Make/O/N=((Num_traces),2)/T FixedCurrExport

j = 0

for(j=0;j<Num_traces;j+=1)

if(j==RowMaxAPNo)

zwaveformarkers[j] = 8
FixedCurrExport[j][0] = num2str(ComCurrValues[j])
FixedCurrExport[j][1] = "NaN"

else

zwaveformarkers[j] = 19
FixedCurrExport[j][0] = num2str(ComCurrValues[j])
FixedCurrExport[j][1] = num2str(ComCurrValues[j])

endif


endfor

Display/N=FixedCurrVsAPs NumberAPs vs ComCurrValues
ModifyGraph mode=3
ModifyGraph zmrkNum={zwaveformarkers}
//SetAxis left 0,50
Label left "Number of APs in step"
Label bottom "Command current (pA)"
TextBox/C/N=title0/F=0/A=MT "Number action potentials\r vs current amplitude "
TextBox/C/N=text0/F=0/A=LC "\\K(65280,0,0)\\W508 Max AP"




Setdatafolder $(gCellFolderName)

//Wavestats/Q/R=(startplot,endplot) $TrcPotDiffNm
//		Variable Max_AP_rise = V_max
	//	Variable Max_AP_rise_loc = V_maxloc
	//	Variable Max_AP_fall = V_min
	//	Variable Max_AP_fall_loc = V_minloc
	
		//Variable/g gMax_AP_rise = Max_AP_rise
		//Variable/g gMax_AP_rise_loc = Max_AP_rise_loc
		//Variable/g gMax_AP_fall = Max_AP_fall
		//Variable/g gMax_AP_fall_loc = Max_AP_fall_loc		
		







//endif

End


//////////////////////////////////////////////////////////////////Plots the AP used for characteristics analysis/////////////////

Function DrawAPplot(Vthresholdtime,Vthreshold,AP_amplitude,FiftyPercentAPfallTime,FiftyPercentAPriseTime,FiftyPercentAP,AP_max_time)

Variable Vthresholdtime,Vthreshold,AP_amplitude,FiftyPercentAPfallTime,FiftyPercentAPriseTime,FiftyPercentAP,AP_max_time

Display/N=AP_calc_trace

Setdatafolder root:

SVAR gCellFolderName = root:gCellFolderName

DFREF CellFolderDFR = $gCellFolderName

Setdatafolder CellFolderDFR
SetDataFolder Actionpotential

if(WaveExists(CheckAPplot))



AppendToGraph/W=AP_calc_trace CheckAPplot
ModifyGraph/W=AP_calc_trace/Z gfRelSize=6


Label left "Voltage (mV)"

Label bottom "Time (ms)"

//Draw lines
Variable xmin,xmax,ymin


GetAxis/W=AP_calc_trace/Q Bottom; xmin = V_min
print("*********************************************************"+num2str(xmin))
GetAxis/W=AP_calc_trace/Q Bottom; xmax = V_max
GetAxis/W=AP_calc_trace/Q Left; ymin = V_min


print(VThresholdTime)
print(Vthreshold)
print(AP_amplitude)



//Threshold x0 y0 x1 y1
SetDrawEnv xcoord= bottom,ycoord= left
SetDrawEnv dash = 3
DrawLine xmin,Vthreshold,VThresholdTime,Vthreshold


// AP width
SetDrawEnv xcoord= bottom,ycoord= left
SetDrawEnv dash = 3
DrawLine FiftyPercentAPriseTime, FiftypercentAP,FiftyPercentAPfallTime,FiftypercentAP


// AP amplitude
SetDrawEnv xcoord= bottom,ycoord= left
SetDrawEnv dash = 3
DrawLine xmin, AP_amplitude,AP_max_time,AP_amplitude




//SetDrawEnv xcoord= bottom,ycoord= left
//SetDrawEnv dash = 3
//DrawLine FiftyPercentAPfallTime, FiftypercentAP,FiftyPercentAPfallTime,ymin

NVAR  gMax_AP_rise = gMax_AP_rise
NVAR  gMax_AP_rise_loc = gMax_AP_rise_loc
NVAR  gMax_AP_fall = gMax_AP_fall
NVAR gMax_AP_fall_loc = gMax_AP_fall_loc

string/g root:gMax_AP_rise = num2str(round(gMax_AP_rise))
string/g root:gMax_AP_fall = num2str(round(gMax_AP_fall))


//Tag/W=AP_calc_trace/N=text0/F=0/B=1/A=RT/X=-5/Y=-16 CheckAPplot, gMax_AP_rise_loc, "\{root:gMax_AP_rise} mV/ms"
//Tag/W=AP_calc_trace/N=text1/F=0/B=1/A=LT/X=5/Y=-16 CheckAPplot, gMax_AP_fall_loc, "\{root:gMax_AP_fall} mV/ms"

Tag/W=AP_calc_trace/N=text0/F=0/B=1/A=RT/X=-5/Y=-16 CheckAPplot, gMax_AP_rise_loc, ""
Tag/W=AP_calc_trace/N=text1/F=0/B=1/A=LT/X=5/Y=-16 CheckAPplot, gMax_AP_fall_loc, ""

//TextBox/W=AP_calc_trace/C/N=text3/A=MT/E/B=1/F=0 APFileName
//TextBox/W=AP_calc_trace/C/N=text3/A=MT/E/B=1/F=0 APFileName
//TextBox/C/N=ffds/F=0/A=LT APFileName
//TextBox/W=AP_calc_trace/B=1/C/N=text1/F=0/A=MT 

//print APFileName


SVAR gFullAPCalcTrace = gFullAPCalcTrace

//Inset full AP graph

Newfreeaxis/O/W=AP_calc_trace InsetYaxis
Newfreeaxis/B/O/W=AP_calc_trace InsetXaxis
AppendToGraph/W=AP_calc_trace/B=InsetXaxis/L= InsetYaxis $gFullAPCalcTrace

ModifyGraph/W=AP_calc_trace/Z  axisEnab (InsetYaxis)={0.70,0.95}
ModifyGraph/W=AP_calc_trace/Z axisEnab (InsetXaxis)={0.6,0.95}

ModifyGraph/W=AP_calc_trace lblPos(InsetYaxis)=42,lblPos(InsetXaxis)=38
ModifyGraph/W=AP_calc_trace lblLatPos(InsetXaxis)=1


Label/W=AP_calc_trace/Z InsetXaxis "Time (ms)"
Label/W=AP_calc_trace/Z InsetYaxis "MP (mV)"
Wavestats/Q $gFullAPCalcTrace
variable minval =  V_min
variable maxval = V_max
variable minyval = leftx($gFullAPCalcTrace)
variable maxyval =rightx($gFullAPCalcTrace)
SetAxis/W=AP_calc_trace InsetYaxis, minval,maxval
SetAxis/W=AP_calc_trace InsetXaxis, minyval,maxyval
ModifyGraph/W=AP_calc_trace/Z freePos(InsetXaxis)={minval,InsetYaxis}
ModifyGraph/W=AP_calc_trace/Z freePos(InsetYaxis)={minyval,InsetXaxis}
ModifyGraph/W=AP_calc_trace/Z  tick(InsetXaxis)=3,noLabel(InsetXaxis)=2,axThick(InsetXaxis)=0,minor(InsetYaxis)=0

variable minxval = leftx($gFullAPCalcTrace)
variable maxxval =	rightx($gFullAPCalcTrace)


//setDrawEnv xcoord= bottom,ycoord= left
//SetDrawEnv dash = 3
//DrawLine minxval, 0,maxxval,0

//SetDrawEnv xcoord= bottom,ycoord= left
//SetDrawEnv dash = 3
//DrawLine minxval, 60,maxxval,60




endif



End


