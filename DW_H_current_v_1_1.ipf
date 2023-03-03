


Function HCurrent(Analysis, WorkingFolder)

String Analysis, WorkingFolder


//Trace folder organization
SVAR gCellFolderName = root:gCellFolderName
DFREF CellFolderDFR = $gCellFolderName

setdatafolder CellFolderDFR
SVAR gAbfFiles
SVAR CellFolderFilePath

newdatafolder/S gHyperpolFold
DFREF HypDF = GetDataFolderDFR()
String/g CellFolderDFR:gHyperpolFold =  GetDataFolder(1)
String HyperDFStr = GetDataFolder(1)

NewDataFolder/O/S Smoothed
DFREF SmoothedDF = GetDataFolderDFR()
String/g CellFolderDFR:gSmoothedDF =  GetDataFolder(1)
String SmoothedDF2 = GetDataFolder(1)


setdatafolder root:
SVAR FileName
SVAR gAnalysisType
String S_fileName

NVAR gAutoScaleCurr
NVAR gBaselineScaleCurr
NVAR gRmAuto
NVAR gHypStep

NVAR gAutoScaleVolt

String PassiveCharFile

Variable HCurrMin, HCurrMax, HCurrAmp,HCurrMaxTime,HCurrMinTime, HCurrFound
Variable  YAxisMin,YAxisMax,MaxPos
Variable index


//Open trace file

if( StringMatch(gAnalysisType, "Manual Analysis"))
Variable refNum
String message = "Select passive membrane properties file"
String outputPath
String fileFilters = "Axon stats files (*.abf):.abf;"
fileFilters += "All Files:.*;"


print ("**********************open file*********************")
Open /D /R /F=fileFilters /M=message refNum

print ("**********************neuro*********************")

else


PassiveCharFile = stringfromlist(0, gAbfFiles)

S_fileName = CellFolderFilePath+PassiveCharFile

endif

Setdatafolder root:

NMImportFile( "new" ,S_fileName)
DoWindow /K ImportPanel

NVAR  NumWaves

Variable/g HypDF:NumWaves = NumWaves

setdatafolder :ABFHeader:

//Check scaling and gains
Wave fTelegraphAdditGain
Variable/g HypDF:Vm_prim_gain =  fTelegraphAdditGain[0]
Variable/g  HypDF:Im_sec_gain =  fTelegraphAdditGain[1]
Variable/g CellFolderDFR:gIm_sec_gain = fTelegraphAdditGain[1]




setdatafolder ::


DFREF NMFolderName =getdatafolderdfr()
String NMFolder = getdatafolder(1)






//Rescaling
index = 0
do
	//Voltage Step

	String TrcPotNm = "RecordA" +num2str(index)
	Wave TracePot = $TrcPotNm
	TracePot=TracePot/gAutoScaleVolt

	Duplicate/O   $TrcPotNm, HypDF:$(TrcPotNm)


	//Current Step
	String TrcCmdCurrNm = "RecordB" +num2str(index)
	Wave TraceCmdCurr = $TrcCmdCurrNm
	TraceCmdCurr=TraceCmdCurr/gAutoScaleCurr//*gBaselineScaleCurr

	Duplicate/O   $TrcCmdCurrNm, HypDF:$(TrcCmdCurrNm)

	index  +=1

while(index<NumWaves)



//Define region of trace to take measurments based on Max Current Trace

//Max current trace ID
TrcCmdCurrNm = "RecordB" +num2str(NumWaves-1)
Wave TraceCmdCurr = $TrcCmdCurrNm

//Smooth command current trace
String IClampTrcSmNm = TrcCmdCurrNm+"_smth"
Duplicate/O   $TrcCmdCurrNm, SmoothedDF:$(IClampTrcSmNm)
Smooth 1000,  SmoothedDF:$(IClampTrcSmNm)

//Find step maximum and minimum and 1/2 max to determine threshold
Wavestats/Q SmoothedDF:$(IClampTrcSmNm)
variable halfCurrStepval = (V_max+V_min)/2 

//Find times at which current crosses threshold (i.e. step region)
FindLevels/DEST=stepregiontimes/Q SmoothedDF:$(IClampTrcSmNm) halfCurrStepval
Wave stepregiontimes

//Define time during step to do measurments (btw 20 ms after start step and 20 ms before end step)
//variable stepstarttime = (stepregiontimes[0])
//variable stependtime = (stepregiontimes[1])

//Manual step region times////////////////////////////////////////////// 

variable stepstarttime = K_start_step_Hyp_time
variable stependtime = K_end_step_Hyp_time

///////////////////////////////////////////////////////////////////////

variable HMeasStartTime = (stepregiontimes[0])+20
variable HMeasEndTime = (stepregiontimes[1])-20

Display/N=H_Current_trace

variable q = 0

HCurrFound = 0

//loop through traces

do

	string IClampTrcVoltNm = "RecordA"+num2str(q)
	Wave IClampTraceVolt = $IClampTrcVoltNm
	string IClampTrcCurrNm = "RecordB" +num2str(q)
	Wave IClampTraceCurr = $IClampTrcCurrNm

//Smooth current trace 
	string IClampTrcCurrSm = "RecordB"+num2str(q)+"_smth"
	Duplicate/O $IClampTrcCurrNm, SmoothedDF:$(IClampTrcCurrSm)
	Smooth 1000, SmoothedDF:$(IClampTrcCurrSm)


	string IClampTrcVoltNmSm = "RecordA"+num2str(q)+"_smth"
	Duplicate/O $IClampTrcVoltNm, SmoothedDF:$(IClampTrcVoltNmSm)
	Smooth 100, SmoothedDF:$(IClampTrcVoltNmSm)

//Measure command current amplitude
	WaveStats/Q/R=(HMeasStartTime,HMeasEndTime) SmoothedDF:$(IClampTrcVoltNmSm)

	print("Start Measure region " +num2str(HMeasStartTime))
	print("End Measure region" +num2str(HMeasEndTime))
	print("Trace ID "+IClampTrcVoltNmSm)
	print ("Maximum voltage "+num2str(V_min))

	q += 1

//Take H current measurement from voltage trace if minimum voltage is -80 
	if((V_min<-80))

		HCurrFound = 1
		HCurrMin = V_min
		//Record amplitude at 100 ms before end of H current measurment region 
		WaveStats/Q/R=(HMeasEndTime-100,HMeasEndTime) SmoothedDF:$(IClampTrcVoltNmSm)
		HCurrMax = V_avg

		HCurrAmp = HCurrMax-HCurrMin

		Print(HCurrAmp)

		Appendtograph/W=H_Current_trace, HypDF:$IClampTrcVoltNm

		String/g HCurrTrace = IClampTrcVoltNm
		
		break

	endif

while (q<  NumWaves)


//Add annotations to trace (region of measurement and H current amplitude
if(HCurrFound==1)

	DoUpdate/W=H_Current_trace

	DoWindow/F H_Current_trace

	GetAxis/W=H_Current_trace left
	YAxisMin = V_min
	YAxisMax = V_max

	SetDrawEnv dash = 3
	SetDrawEnv linepat=4
	SetDrawEnv xcoord= bottom,ycoord= left
	DrawLine/W=H_Current_trace stepstarttime+20, YAxisMax, stepstarttime+20, YAxisMin

	SetDrawEnv dash = 3
	SetDrawEnv linepat=4
	SetDrawEnv xcoord= bottom,ycoord= left
	DrawLine/W=H_Current_trace stependtime-20, YAxisMax, stependtime-20, YAxisMin

	SetDrawEnv dash = 3
	SetDrawEnv linepat=4
	SetDrawEnv xcoord= bottom,ycoord= left
	DrawLine/W=H_Current_trace stepstarttime+20, HCurrMin, stependtime-20, HCurrMin


	SetDrawEnv dash = 3
	SetDrawEnv linepat=4
	SetDrawEnv xcoord= bottom,ycoord= left
	DrawLine/W=H_Current_trace stependtime-220, HCurrMax, stependtime-20,HCurrMax

	Variable Midpoint = ((stependtime-220)+(stependtime-20))/2
	SetDrawEnv arrow=3
	SetDrawEnv arrowlen=5
	SetDrawEnv xcoord= bottom,ycoord= left
	DrawLine/W=H_Current_trace Midpoint, HCurrMin, Midpoint,HCurrMax
	Variable/g CellFolderDFR:gHCurrent = HCurrAmp
	TextBox/W=H_Current_trace/C/N=text1/F=0/A=MC "H current = "+num2str(round(HCurrAmp))+" mV"
	
	
	Label/W=H_Current_trace Left "Membrane Potential (mV)"
	Label/W=H_Current_trace bottom "Time (ms)"

//If voltage trace doesn't reach -80 mV then ignore
else
	Variable/g CellFolderDFR:gHCurrent = NaN
	TextBox/W=H_Current_trace/C/N=text1/F=0/A=MC "No H Current Measurement"
endif


SVAR FileName
String/g CellFolderDFR:HypTrace =  FileName

setdatafolder root:

KillDataFolder $NMFolder


End


//Calculate Input resistance

Function Rmem()


Print ("*****************************************Start Rm*************************************")

//Define minimum voltage used for measurement (avoid H current contamination chose -80)

Variable MaxVoltageRm = -80


//Folder organization
SetDataFolder root:
NVAR gSelectedRadioButton
NVAR gBaselineScaleCurr
NVAR gAutoScaleCurr
NVAR gHypStep
SVAR gCellFolderName 
DFREF CellFolderDFR = $gCellFolderName
Setdatafolder CellFolderDFR


SVAR gHyperpolFold
DFREF HyperpolFoldDFR = $gHyperpolFold


setdatafolder HyperpolFoldDFR

NVAR Im_sec_gain

variable i,m,j,offset
string TrcCmdCurrNm,TrcPotNm

Display/N=Hyperpolarizations
Display/N=CurrentSteps


Wave W_FindLevels
Wave W_coef

SVAR HCurrTrace
NVAR NumWaves

Make/O/N=0 IClampCommand_current
Make/O/N=0 IClampVoltage

Make/O/N=0 TauRise
Make/O/N=0 TauFall
Make/O/N=0 UsedCalc
Make/O/N=0 GraphNo

Make/O/N=0 RiseTauCalc
Make/O/N=0 FallTauCalc



i = 0
j = 0




//Define region of trace to take measurements based on Max Current step (can use the same region as H current measurement method )

TrcCmdCurrNm = "RecordB" +num2str(NumWaves-1)
Wave TraceCmdCurr = $TrcCmdCurrNm

String IClampTrcVoltNmSmA = TrcCmdCurrNm+"_smthA"
Duplicate/O  $TrcCmdCurrNm, $IClampTrcVoltNmSmA
Smooth 1000, $IClampTrcVoltNmSmA

Wavestats/Q $IClampTrcVoltNmSmA

variable halfCurrStepval = (V_max+V_min)/2 
FindLevels/DEST=stepregiontimes/Q $IClampTrcVoltNmSmA, halfCurrStepval

//Measurement period times
Wave stepregiontimes

//Step period
//variable stepstarttime = (stepregiontimes[0])
//variable stependtime = (stepregiontimes[1])


//Manual step region times////////////////////////////////////////////// 

variable stepstarttime = K_start_step_Hyp_time
variable stependtime = K_end_step_Hyp_time

///////////////////////////////////////////////////////////////////////



//Baseline period times (15 - 30 ms before step
variable NormStartTime = (stepstarttime)-30
variable NormEndTime = (stepstarttime)-15

//Middle region (used for current amplitude) maybe use for current steps for H current (middle 400 ms)
Variable MidRegion = ((stependtime-stepstarttime)/2)+stepstarttime
variable MeasureStartTime = MidRegion-200
variable MeasureEndTime = MidRegion+200



//FindLevels/DEST=stepregionpoint/Q/P $IClampTrcVoltNmSmA, halfCurrStepval
//variable stepstartpoint = (stepregionpoint[0])
//variable stependpoint = (stepregionpoint[1])

variable stepstartpoint=x2pnt($IClampTrcVoltNmSmA, stepstarttime)
variable stependpoint=x2pnt($IClampTrcVoltNmSmA, stependtime)

print "Step Start point = " +num2str(MeasureStartTime)
print "Step Start point = "+num2str(MeasureEndTime)


do

//Voltage Step 
	TrcPotNm = "RecordA" +num2str(i)
	Wave TracePot = $TrcPotNm


//Current Step
	TrcCmdCurrNm = "RecordB" +num2str(i)
	Wave TraceCmdCurr = $TrcCmdCurrNm


//Smooth Current Step
	String  TrcCmdCurrNmSm = TrcCmdCurrNm+"_smth"
	Duplicate/O  $TrcCmdCurrNm, $TrcCmdCurrNmSm
	Smooth 1000, $TrcCmdCurrNmSm

//Calculate Delta for current step (subtract from baseline )


//Measure current amplitude during baseline period  
	Wavestats/Q/R=( NormStartTime,NormEndTime) $TrcCmdCurrNmSm
	Variable SubVal = V_avg
	Wave SmoothedCurrentStep = $TrcCmdCurrNmSm


//Apply subtraction and scale
	SmoothedCurrentStep=SmoothedCurrentStep-SubVal


//Raw Voltage measurement during measurement period 
	WaveStats/Q/R=(MeasureStartTime,MeasureEndTime) TracePot
	Appendtograph/W=CurrentSteps, SmoothedCurrentStep
	Appendtograph/W=Hyperpolarizations, TracePot
	ModifyGraph/W=Hyperpolarizations rgb($TrcPotNm)=(43520,43520,43520)


//Print("Raw Baseline Voltage ="+num2str(V_avg))
//Print("Maximum amplitde depolarization ="+num2str(MaxVoltageRm))


//Only measure if less than voltage threshold
	if((V_avg>MaxVoltageRm))

		WaveStats/Q/R=(MeasureStartTime,MeasureEndTime) SmoothedCurrentStep
//-------------------------------------------------------------------------Manual Current step amplitude------------		
		
	variable IClamphold_curr_amp
	
	//if(gSelectedRadioButton==1)
	//IClamphold_curr_amp = V_avg
	//else
	//IClamphold_curr_amp = gHypStep * i
	//endif
	
	IClamphold_curr_amp = -10 * i
	
		
//-------------------------------------------------------------------------------------------------------	----------	
		
		// 

		InsertPoints Inf,1,IClampCommand_current
		IClampCommand_current[Inf] = IClamphold_curr_amp


		//Measure change in voltage amplitude
		WaveStats/Q/R=(NormStartTime,NormEndTime) TracePot
		variable IClampvoltage_start = V_avg
		
		//print "Baseline Voltage: "+num2str(V_avg)
		
		WaveStats/Q/R=(MeasureStartTime,MeasureEndTime) TracePot
		variable IClampvoltage_end = V_avg
		
		//print "Step Voltage: "+num2str(V_avg)

		//Print "Voltage Amplitude =  " +num2str(IClampvoltage_end - IClampvoltage_start)

		InsertPoints Inf,1,IClampVoltage
		IClampVoltage[Inf] = (IClampvoltage_end - IClampvoltage_start)
		ModifyGraph/W=Hyperpolarizations rgb($TrcPotNm)=(55040,0,0)
		
		
		//////////////////////////////////////////Capacitance measurment/////////////////////////////
		
		Variable AbsoluteVoltageAmp = sqrt((IClampvoltage_end - IClampvoltage_start)^2)
		
		//Print "Voltage Amplitude =" + num2str(AbsoluteVoltageAmp)
		
			if(AbsoluteVoltageAmp>5)
		
		
			Print("*****************************Reaches Cap measurment threshold**************************")
		
		
		
			Print "Baseline Voltage = "+ num2str(IClampvoltage_start)
			Print "Maximum Voltage = "+num2str(IClampvoltage_end)
		
		
			Variable EightyPercent = 0.8* (IClampvoltage_end - IClampvoltage_start)
			Variable TwentyPercent = 0.2* (IClampvoltage_end - IClampvoltage_start)
		
			Print "Eighty Percent voltage change = "+num2str(EightyPercent)
			Print "Twenty Percent voltage change = "+num2str(TwentyPercent)
		
			Variable EightyPercentRaw = (EightyPercent+IClampvoltage_start)
			Variable TwentyPercentRaw = (TwentyPercent+IClampvoltage_start)
			
			Print "Eighty Percent raw voltage = "+num2str(EightyPercent+IClampvoltage_start)
			Print "Twenty Percent raw voltage = "+num2str(TwentyPercent+IClampvoltage_start)			
		
		
			Variable LevelTwentyRise = 0
			Variable LevelEightyRise = 0
			Variable LevelTwentyFall = 0
			Variable LevelEightyFall = 0
		
			Print(TrcPotNm)
			
			//20% rise		
			FindLevel/P/R=[stepstartpoint,] TracePot, TwentyPercentRaw			
			if(V_flag ==0)	
				
				Variable TwentyPercentRising = V_LevelX			
				print("Twenty Rise Point = "+ num2str(V_LevelX))						
				LevelTwentyRise = 1			
				
			endif
			
			//80% rise			
			FindLevel/P/R=[stepstartpoint,] TracePot, EightyPercentRaw			
			if(V_flag ==0)	
				
				Variable EightyPercentRising = V_LevelX			
				print("Eighty Rise Point = "+ num2str(V_LevelX))						
				LevelEightyRise = 1			
				
			endif
			
			
			//80% fall			
			FindLevel/Q/P/R=[stependpoint,] TracePot, EightyPercentRaw			
			if(V_flag ==0)	
				
				Variable EightyPercentFalling = V_LevelX			
				print("Eighty Fall Point = "+ num2str(V_LevelX))						
				LevelEightyFall = 1			
				
			endif
			
			//20% fall			
			FindLevel/Q/P/R=[stependpoint,] TracePot, TwentyPercentRaw				
			if(V_flag ==0)	
				
				Variable TwentyPercentFalling = V_LevelX			
				print("Twenty Fall Point = "+ num2str(V_LevelX))						
				LevelTwentyFall = 1			
				
			endif			
			
		
		
		
		
			if(LevelTwentyRise+LevelEightyRise+LevelTwentyFall+LevelEightyFall==4)
			
			
			String CapPlotTraceNm = "Cap_trace_"+num2str(i)
			
			
			Display/N=$CapPlotTraceNm $TrcPotNm
		
		
				String RiseCoffNm  = TrcPotNm+"_Rise_Coeff"
				String FallCoffNm  = TrcPotNm+"_Fall_Coeff"
				String RiseFitNm  = TrcPotNm+"_Rise_fit"
				String FallFitNm  = TrcPotNm+"_Fall_fit"				
				
				//Duplicate/D $TrcPotNm,$RiseFitNm
				
				//Make/O/N=(numpnts($TrcPotNm)) $RiseFitNm
				//Make/O/N=200 $RiseFitNm
				
				
				//Tau calculations
				
					
		
				
				
				variable TauOneVal,TauTwoVal,V_AbortCode,CFerror,V_FitQuitReason,V_FitError, RisingTau,FallingTau
				string AutoFitNm
				
				//Rising Tau	
				
				V_FitError=0

				CurveFit/NTHR=0/Q exp_XOffset,TracePot[TwentyPercentRising,EightyPercentRising]/D

				Wave W_coef

				if (V_FitError)
			
						
					Print V_FitQuitReason
					RisingTau = NaN
					
			
				else
				
					AutoFitNm = "fit_"+TrcPotNm
				
					ModifyGraph  rgb($AutoFitNm)=(19712,0,39168)
				
					Rename $AutoFitNm $RiseFitNm				
															
					Duplicate/O W_coef,   $RiseCoffNm
				
					Wave RiseCoff = $RiseCoffNm
						
					RisingTau = RiseCoff[2]							

				endif	
						
				
				
				
				//Falling Tau	
				
				V_FitError=0		
				
		
				CurveFit/NTHR=0/Q exp_XOffset,TracePot[TwentyPercentFalling,EightyPercentFalling]/D
				
				if (V_FitError)
			
						
					Print V_FitQuitReason
					FallingTau = NaN
					
			
				else
				
				
					ModifyGraph  rgb($AutoFitNm)=(19712,0,39168)
				
					Rename $AutoFitNm $FallFitNm
				
				
					Duplicate/O W_coef, $FallCoffNm
				
					Wave FallCoff = $FallCoffNm
				
					FallingTau =  FallCoff[2]
				
				endif	
				
				
				
				
				
				
				//Print(TrcPotNm)
				Print ("Rising Tau = " + num2str(RisingTau))
				Print ("Falling Tau = " + num2str(FallingTau))
				
				String GlobalRisingTauNm = TrcPotNm+"RisingTau"
				String GlobalFallingTauNm = TrcPotNm+"FallingTau"
				
				Variable/g $GlobalRisingTauNm = RisingTau
				Variable/g $GlobalFallingTauNm = FallingTau
				
				
				
				InsertPoints Inf,1,  TauRise
				TauRise[Inf] = round((RisingTau)*10)/10
				
				InsertPoints Inf,1,  TauFall
				TauFall[Inf] = round((FallingTau)*10)/10
				
				InsertPoints Inf,1,  GraphNo	
				GraphNo[Inf] = i
				
				
				
				
				
				
				if((FallingTau+RisingTau)<400)
				
				
					InsertPoints Inf,1,  UsedCalc				
					UsedCalc[Inf] = 1	
					
					//Used for calculations
					InsertPoints Inf,1,  RiseTauCalc
					RiseTauCalc[Inf] = round((RisingTau)*10)/10
				
					InsertPoints Inf,1, FallTauCalc
					FallTauCalc[Inf] = round((FallingTau)*10)/10
				
				
				else
				
					InsertPoints Inf,1,  UsedCalc	
					UsedCalc[Inf] = 0			
				
				endif
				
				
				
				
		
			endif
			
			
		endif
		
		
endif

	
	//Blue H current trace
	if (SVAR_exists(HCurrTrace))

		if(StringMatch(HCurrTrace,TrcPotNm))
			
			ModifyGraph/W=Hyperpolarizations rgb($TrcPotNm)=(0,0,52224)
		
		endif
		
	endif



	i += 1



while (i< NumWaves)

Label/W=Hyperpolarizations Left "Membrane Potential (mV)"
Label/W=Hyperpolarizations bottom "Time (ms)"
TextBox/W=Hyperpolarizations/C/N=text1/F=0/A=MT "Hyperpolarizing steps"


Display/N=IV_plot IClampVoltage vs IClampCommand_current
ModifyGraph mode=3
Label left "Voltage change (mV)"
Label bottom "Current injection (pA)"



Display/N=Taus RiseTauCalc vs FallTauCalc
ModifyGraph/W=Taus mode=3
ModifyGraph/W=Taus marker=19
ModifyGraph/W=Taus rgb=(0,0,65280)
Label/W=Taus left "Tau fall (ms)"
Label/W=Taus bottom "Tau rise (ms)"
//SetAxis/W=Taus left 0,100
//SetAxis/W=Taus bottom 0,100



V_FitError=0		

Variable InputResistance	


try
	CurveFit/NTHR=1/Q line  IClampVoltage /X=IClampCommand_current /D; AbortOnRTE
	
	if (V_FitError)
			
		Print V_FitQuitReason
		InputResistance = NaN
					
	else
				
		Wave W_coef
		InputResistance = (W_coef[1]*1e3)
				
	endif	

catch
	
	if (V_AbortCode == -4)
		
		Print "Error during curve fit:"
		cfError = GetRTError(1) // 1 to clear the error
		Print GetErrMessage(cfError,3)
		InputResistance = NaN
	
	endif

endtry		
		

TextBox/W=IV_plot/C/N=text2/F=0/A=LT "R\Bmem\M = "+num2str(round(InputResistance))+" \[0M\F'Symbol'W\]0"

//No scale
variable/g CellFolderDFR:gRmOrig =  InputResistance/gAutoScaleCurr
variable RmOrig =  InputResistance/gAutoScaleCurr
//ManualScale
variable/g CellFolderDFR:gInputResistance =  InputResistance
variable RmManual =  InputResistance
//File scale
variable/g CellFolderDFR:gRmAuto =(InputResistance/(gAutoScaleCurr))*Im_sec_gain
variable RmAuto =(InputResistance/gAutoScaleCurr)*Im_sec_gain



print "Manual adjusted Input Resistance = " + num2str( InputResistance)



if(numpnts(RiseTauCalc)>0)
	WaveStats/Q/Z RiseTauCalc
	Variable/g CellFolderDFR:gAvRiseTau = V_avg
	Variable AvRiseTau = V_avg
	Duplicate/O RiseTauCalc, RiseRmCalc
	RiseRmCalc = ((RiseRmCalc/1e3)/(InputResistance*1e6))*1e12
	WaveStats/Q/Z  RiseRmCalc
	Variable AvRiseCap =V_avg
	Variable AvRiseCapSEM =V_sem
	Variable/g CellFolderDFR:gAvRiseCap = AvRiseCap
	Variable/g CellFolderDFR:gAvRiseCapSEM = AvRiseCapSEM
else
	Variable/g CellFolderDFR:gAvRiseTau = NaN
	Variable/g CellFolderDFR:gAvRiseCap = NaN
	Variable/g CellFolderDFR:gAvRiseCapSEM = NaN
	
endif

if(numpnts(FallTauCalc)>0)
	WaveStats/Q/Z FallTauCalc
	Variable/g CellFolderDFR:gAvFallTau = V_avg
	Variable AvFallTau = V_avg
	Duplicate/O FallTauCalc, FallRmCalc
	FallRmCalc = ((FallRmCalc/1e3)/(InputResistance*1e6))*1e12
	WaveStats/Q/Z  FallRmCalc
	Variable AvFallCap =V_avg
	Variable AvFallCapSEM =V_sem
	Variable/g CellFolderDFR:gAvFallCap = AvFallCap
	Variable/g CellFolderDFR:gAvFallCapSEM = AvFallCapSEM
	
else
	Variable/g CellFolderDFR:gAvFallTau = NaN
	Variable/g CellFolderDFR:gAvFallCap = NaN
	Variable/g CellFolderDFR:gAvFallCapSEM = NaN

endif



Variable/g CellFolderDFR:gCapTauOrig = ((AvFallTau/1e3)/(RmOrig*1e6))*1e12
Variable/g CellFolderDFR:gCapTauManual = ((AvFallTau/1e3)/(RmManual*1e6))*1e12
Variable/g CellFolderDFR:gCapTauAuto = ((AvFallTau/1e3)/(RmAuto*1e6))*1e12









CapLabels()


End



//Add values to Cap traces

Function CapLabels()

SetDataFolder root:

SVAR gCellFolderName 
DFREF CellFolderDFR = $gCellFolderName
Setdatafolder CellFolderDFR

NVAR gInputResistance


SVAR gHyperpolFold
DFREF HyperpolFoldDFR = $gHyperpolFold


setdatafolder HyperpolFoldDFR

Wave TauRise,TauFall,UsedCalc,GraphNo


variable i,RisingTau,FallingTau,Used,corrRisingTau,corrFallingTau,corrRm,CapRise,CapFall
String GraphNm



for(i=0;i<numpnts(GraphNo);i+=1)

	GraphNm = "Cap_trace_"+num2str(GraphNo[i])

	CorrRm = gInputResistance*1e6
	
	RisingTau = TauRise[i]
	CorrRisingTau = RisingTau*1e-3

	FallingTau = TauFall[i]
	CorrFallingTau = FallingTau*1e-3
	
	CapRise = (CorrRisingTau/CorrRm)*1e12
	CapFall = (CorrFallingTau/CorrRm)*1e12
	
	
	
	
	Used = UsedCalc[i]

	if(Used==1)
		TextBox/W=$GraphNm/C/N=text0/A=MT/X=-5.32/Y=6.64  "\K(0,0,65280)Falling Tau: "+num2str(FallingTau)+" (ms)\tCap Fall: "+num2str(CapFall)+" (pF)\rRising Tau: "+num2str(RisingTau)+" (ms) \tCap Fall: "+num2str(CapRise)+" (pF)"
	else
		TextBox/W=$GraphNm/C/N=text0/A=MT/X=-5.32/Y=6.64  "\K(65280,0,0)Falling Tau: "+num2str(FallingTau)+" (ms)\tCap Fall:"+num2str(CapFall)+" (pF)\rRising Tau: "+num2str(RisingTau)+" (ms) \tCap Fall:"+num2str(CapRise)+" (pF)"
	endif

endfor




End








