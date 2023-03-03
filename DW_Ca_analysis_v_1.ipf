//#pragma rtGlobals=3		// Use modern global access method and strict wave access.


//Constant kChangeCutOff=1
Constant kFitCutOff=0.7
Constant kRawChangeCutOff = 50


Function RenameMe()

setdatafolder root:


String ColName, ColList,NameCurrentFile
Variable TotalColNum,index,i,k,FilesInFolder

GetFileFolderInfo/D
print S_path

NewPath/O myPath S_path
string/g fullpathname = S_path

//print IndexedFile(myPath, -1, ".txt")

FilesInFolder = ItemsInList(IndexedFile(myPath,-1, ".txt"))


for (k=0;k<FilesInFolder;k+=1)

setdatafolder root:


NameCurrentFile = (StringFromList(k,IndexedFile(myPath, -1, ".txt")))

PRint("Current File Name: "+NameCurrentFile)


LoadWave/A/J/D/K=2/L={0,0, 0,2, 0}/P=myPath NameCurrentFile


ColList = WaveList("*",";","")

//Find and rename time wave
Do

ColName =  StringFromList(i, ColList)
String TimeAppend = ColName+"_s"



	Wave/T CurrCol = $ColName
	Note CurrCol CurrCol[0]

	string ColIdent =  note(CurrCol)
	
	string ColIdentForm =  ReplaceString(":", ColIdent,"_")
	 ColIdentForm =  ReplaceString(" ",  ColIdentForm,"_")
	print ("Current Column: "+ ColIdentForm)
	
	 //180517_d4_f2_APP_thaps_KCl_APP_Time_(s)
	
	

	if(StringMatch(ColIdentForm,"*Time*"))
	
		
	
	//Make new folder based on Date_Dish_field	
	
	String expr="([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([[:graph:]]+)"
	String XDateStr,Dish, Field, Celltype, Treatment,ID
	SplitString/E=(expr) ColIdentForm, XDateStr,Dish, Field, Celltype, Treatment,ID
	
	
	
	
	 
	
	
	String NewFolderName = "X"+ XDateStr+"_"+Dish+"_"+Field+"_"+Treatment
	
	
	NewFolderName = ReplaceString("-", NewFolderName,"_")
	
	print("New Folder name "+ NewFolderName)
	
	NewDataFolder  $NewFolderName
	
	
	
	DeletePoints 0,2, CurrCol
	Make/D /N=(numpnts(CurrCol))  TimeWave
	Wave TimeWave
	TimeWave  = str2num(CurrCol)
	Note TimeWave ColIdentForm
			
	MoveWave root:TimeWave, root:$(NewFolderName):
		
	KillWaves CurrCol
		
		
		
		break
		
	endif
		
		
i +=1

while (i<ItemsInList(ColList))

AddToFolderPlot(NewFolderName)


endfor

End


//Move rest of waves
Function AddToFolderPlot(NewFolderName)

String NewFolderName 
Variable index

String ColList = WaveList("*",";","")

For(index=0; index<(ItemsInList(ColList));index+=1)

	String ColName =  StringFromList(index, ColList)
	String NumericRename = ColName+"_n"

	Wave/T CurrCol = $ColName
	Note CurrCol CurrCol[0]

	string ColInfo =  note(CurrCol)



	DeletePoints 0,2, CurrCol
	Make/D /N=(numpnts(CurrCol))  $NumericRename 
	Wave NumWave = $NumericRename 
	NumWave  = str2num(CurrCol)
	Note NumWave ColInfo
	
	print("Current folder: "+ NewFolderName)


MoveWave root:$(NumericRename), root:$(NewFolderName):


endfor

setdatafolder root:$(NewFolderName):


setdatafolder root:


killwaves/A

Calculations(NewFolderName)

end




//Calculation on each plot 

Function Calculations(NewFolderName)

string NewFolderName
SVAR gCustomPathCa = root:gCustomPathCa

NVAR gBaselineThreshold = root:gBaselineThreshold
NVAR gFoldChangeThreshold = root:gFoldChangeThreshold
NVAR gTauThreshold = root:gTauThreshold
NVAR gReturnToBaselineThreshold = root:gReturnToBaselineThreshold
NVAR gSizeThreshold = root:gSizeThreshold






Variable StartTimeMax = kStartTimeMax
Variable EndTimeMax = kEndTimeMax




SetDatafolder root:$(NewFolderName):

Make/O/N=0 Final_intensity,Fold_change_max,Baseline_intensity, Max_intensity,Percent_recovery,Area_under_curve,Tau,Fail_ID
Make/T/O/N=0 ROI_ID,Time_ID


Variable index
Variable PlotNo,LayoutNo

String ColList = WaveList("*_n",";","")

For(index=0; index<(ItemsInList(ColList));index+=1)


String ColName =  StringFromList(index, ColList)

Wave ROI = $ColName

Wave TimeWave

InsertPoints Inf,1, ROI_ID
	ROI_ID[Inf] = note(ROI)

InsertPoints Inf,1, Time_ID
	Time_ID[Inf] = note(TimeWave)


//Baseline and Final Fluorescence
WaveStats/Q ROI
Variable baseline = (mean(ROI ,0,3))
	InsertPoints Inf,1, Baseline_intensity
	Baseline_intensity[Inf] = baseline
	
Variable end_aver = (mean(ROI ,v_npnts-2,v_npnts))
	InsertPoints Inf,1, Final_intensity
	Final_intensity[Inf] = end_aver
	
//Maximum Fluorescence and fold change
WaveStats/Q/R=(StartTimeMax,EndTimeMax) ROI
Variable PeakTimeLoc = V_maxRowLoc
Variable maxval = (V_max)
Variable ChangeFactor = maxval/baseline
String FoldChangeStr
sprintf  FoldChangeStr, "%.*g", 4, ChangeFactor
Variable PercentMaxEnd = round((1-((end_aver-baseline)/(maxval-baseline)))*100)


	InsertPoints Inf,1, Max_intensity
	Max_intensity[Inf] = maxval
	
	InsertPoints Inf,1, Fold_change_max
	Fold_change_max[Inf] = ChangeFactor

	InsertPoints Inf,1, Percent_recovery
	Percent_recovery[Inf] = PercentMaxEnd


/////////////////////

variable NumberNormalizedPoints = numpnts(ROI)
variable Iter

String NormWaveName = ColName+"_norm"

Make/N=(NumberNormalizedPoints)/O/D $NormWaveName

Wave NormWave = $NormWaveName

for (Iter=0;Iter<NumberNormalizedPoints;Iter+=1)
NormWave[Iter] = ROI[Iter]/baseline
endfor




//Area calculatation/////////////////////////////////////////////////////////////

variable AreaStartTime = 0
variable AreaEndTime =  90

Variable AreaStartPoint,AreaEndPoint,CalcArea, AreaValue

FindLevel/EDGE=1/P/Q TimeWave, AreaStartTime
AreaStartPoint = V_LevelX

FindLevel/EDGE=1/P/Q TimeWave, AreaEndTime
AreaEndPoint = V_LevelX

AreaValue = area (Normwave,AreaStartPoint,AreaEndPoint)

InsertPoints Inf,1, Area_under_curve
	 Area_under_curve[Inf] = AreaValue

///////////////////////////////Fail ID///////////////////////////////////////////////////////////
Variable FailID =0
  
if(baseline>gBaselineThreshold)
FailID = 1
else
FailID = 0
endif

if((ChangeFactor<gFoldChangeThreshold)|ChangeFactor<0.9)
FailID = FailID+2
else
FailID = FailID
endif

if((PercentMaxEnd<gReturnToBaselineThreshold)|(PercentMaxEnd>120))
FailID = FailID+4
else
FailID = FailID
endif


InsertPoints Inf,1,Fail_ID
	Fail_ID[Inf] =  FailID

//if(CellSize<gSizeThreshold)
//FailID = FailID+8
//else
//FailID = FailID
//endif

///////////////////////////////////////////////////////////////////////////////////////////



/////////////////////////////////////////////Tau///////////////////////////////////////
variable tau_calc_max,tau_calc_min,point_tau_calc_max,point_tau_calc_min,TauV,TauError


if(FailID==0)

	WaveStats/Q ROI
	tau_calc_max =  (((v_max - baseline)*0.80) + baseline)
	tau_calc_min = (((v_max - baseline)*0.33) + baseline)


	FindLevel/P/Q/R=(V_maxloc,V_npnts), ROI, tau_calc_max
	point_tau_calc_max = round(V_LevelX)

	
	FindLevel/P/Q/R=(V_maxloc,V_npnts), ROI, tau_calc_min
	point_tau_calc_min =  round(V_LevelX)

		if((point_tau_calc_min-point_tau_calc_max)>1)


			try
				
				CurveFit/Q/NTHR=0 exp_XOffset  ROI[point_tau_calc_max, point_tau_calc_min]/X=TimeWave/D
				Variable CFerror = GetRTError(1)	// 1 to clear the error
				Wave W_coef				
				TauV = W_coef[2]
				CFerror = GetRTError(1)	// 1 to clear the error

				if(TauError==0)

					String CurveFitName = "fit_"+ColName					
					//ModifyGraph/W=$Plot_name rgb($CurveFitName)=(0,0,39168)
				endif


//AppendToGraph $("fit_"+theWave)

				if (CFerror != 0)

						TauV = NaN
						TauError = 1 //Failed Tau fitting
						Print GetErrMessage(CFerror)

				endif

			catch
	
			
		
			endtry
		
		else
		
			TauV = NaN
			

		endif

else

	TauV = NaN

endif



InsertPoints Inf,1, Tau
	Tau[Inf] = TauV



////////////////////////////End Tau///////////////////////////



//CaWaveData[7] = TauResult
//CaWaveData[9] = TimeWavePeak



//CaWaveData[13] = FailID


//Tau [1][16] = num2str(FailID)
//Tau [1][15] = num2str(CellSize)
//Tau [1][14] = num2str(AreaEndPoint)
//Tau [1][13]= num2str(AreaStartPoint)
//Tau [1][11]= num2str(AreaValue)
//Tau [1][10]= num2str(TimeWavePeak)
//Tau [1][1] = num2str(TauV)



Draw_Ca_Trace(ColName,index,NewFolderName,baseline,ChangeFactor,PercentMaxEnd)






PlotNo+=1

Plotlayout(PlotNo,LayoutNo,NewFolderName)

if(PlotNo==8)
PlotNo=0
LayoutNo+=1
endif


Endfor





String ListofWindowstoKill = WinList("*",";","WIN:5")
ListofWindowstoKill= sortlist(ListofWindowstoKill)
String CurrentKillPlot
Variable KillWinNo

/////Kill all graphs
for(KillWinNo=0;KillWinNo<itemsinlist(ListofWindowstoKill);KillWinNo+=1)
CurrentKillPlot = Stringfromlist(KillWinNo, ListofWindowstoKill)

DoWindow/K CurrentKillPlot
DoWindow/C KillName
KillWindow KillName

endfor



Edit ROI_ID,Time_ID, Final_intensity,Fold_change_max,Baseline_intensity, Max_intensity,Percent_recovery,Area_under_curve,Tau,Fail_ID
SaveTableCopy/O/W=Table0/T=1 as  gCustomPathCa+NewFolderName+".txt"
KillWindow Table0


End



//Make layout	

Function Plotlayout(PlotNo,LayoutNo,NewFolderName)

Variable PlotNo,LayoutNo
String NewFolderName

SVAR gCustomPathCa = root:gCustomPathCa
Print "Plot Number "+num2str(PlotNo)

//Variable LayoutNo

if(PlotNo == 8)

NewLayout/K=1/N=LayoutCaPlot

String ListofWindows = WinList("*",";","WIN:1")

//ListofWindows = sortlist(ListofWindows)

variable WinNo

for(WinNo=0;WinNo<itemsinlist(ListofWindows);WinNo+=1)


String CurrentCaPlot = Stringfromlist(WinNo,ListofWindows)

print CurrentCaPlot

Appendlayoutobject/W=LayoutCaPlot graph $CurrentCaPlot

endfor

Execute("Tile/O=0")

String SaveFileNameData = gCustomPathCa+NewFolderName+"_"+num2str(LayoutNo)+".pdf"


SavePict/E=-8/O/WIN=LayoutCaPlot as SaveFileNameData

LayoutNo+=1

PlotNo=0

String ListofWindowstoKill = WinList("*",";","WIN:5")
ListofWindowstoKill= sortlist(ListofWindowstoKill)
String CurrentKillPlot
Variable KillWinNo

/////Kill all graphs
for(KillWinNo=0;KillWinNo<itemsinlist(ListofWindowstoKill);KillWinNo+=1)
CurrentKillPlot = Stringfromlist(KillWinNo, ListofWindowstoKill)

DoWindow/K CurrentKillPlot
DoWindow/C KillName
KillWindow KillName

endfor

endif

End







endfor


endif
	
	

endfor

//Last plots


NewLayout/K=1/N=LayoutCaPlot

ListofWindows = WinList("*",";","WIN:1")

//ListofWindows = sortlist(ListofWindows)


for(WinNo=0;WinNo<itemsinlist(ListofWindows);WinNo+=1)


CurrentCaPlot = Stringfromlist(WinNo,ListofWindows)

print CurrentCaPlot

Appendlayoutobject/W=LayoutCaPlot graph $CurrentCaPlot

endfor

Execute("Tile/O=0")

SaveFileNameData = gCustomPathCa+gCaExperimentDate+"_"+num2str(LayoutNo)+".pdf"


SavePict/E=-8/O/WIN=LayoutCaPlot as SaveFileNameData


ListofWindowstoKill = WinList("*",";","WIN:5")
ListofWindowstoKill= sortlist(ListofWindowstoKill)


/////Kill all graphs
for(KillWinNo=0;KillWinNo<itemsinlist(ListofWindowstoKill);KillWinNo+=1)
CurrentKillPlot = Stringfromlist(KillWinNo, ListofWindowstoKill)

DoWindow/K CurrentKillPlot
DoWindow/C KillName
KillWindow KillName

endfor