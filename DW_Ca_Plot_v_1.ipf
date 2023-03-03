//#pragma rtGlobals=3		// Use modern global access method and strict wave access.



Function Draw_Ca_Trace(ColName,index,NewFolderName,baseline,ChangeFactor,PercentMaxEnd)

String ColName,NewFolderName
Variable index,baseline,ChangeFactor,PercentMaxEnd

Variable StartTimeMax = kStartTimeMax
Variable EndTimeMax = kEndTimeMax


NVAR BaselineThreshold = root:gBaselineThreshold
NVAR FoldChangeThreshold = root:gFoldChangeThreshold
NVAR ReturnToBaselineThreshold = root:gReturnToBaselineThreshold

Variable StartMaxPoint,  EndMaxPoint,YAxisMin,YAxisMax




//Trace plot
String PlotName=NewFolderName+num2str(index)
Wave TimeWave
Wave ROI = $ColName
Display/N=$PlotName ROI vs TimeWave

//Add Fit trace
String FitName = "fit_"+ColName
if(exists(FitName))
Wave FitWave = $FitName
AppendToGraph/W=$PlotName $FitName
ModifyGraph/W=$PlotName rgb($FitName)=(0,65535,0)
endif

TextBox/C/N=text0/F=0/A=RT/B=1 note(ROI)

if(baseline>BaselineThreshold)
AppendText/W=$PlotName/N=text0 "\K(65280,0,0)Baseline:\t"+num2str(((round(baseline*100)))/100)
else
AppendText/W=$PlotName/N=text0 "\K(0,0,0)Baseline:\t"+num2str(((round(baseline*100)))/100)
endif

if(ChangeFactor<FoldChangeThreshold)
AppendText/W=$PlotName/N=text0 "\K(65280,0,0)Max Chng:\t"+num2str((((ChangeFactor*0.01)))/0.01)
else
AppendText/W=$PlotName/N=text0 "\K(0,0,0)Max Chng:\t"+num2str((((ChangeFactor*0.01)))/0.01)
endif

if(PercentMaxEnd<ReturnToBaselineThreshold)
AppendText/W=$PlotName/N=text0 "\K(652800,0,0)Percent recovery:\t"+num2str((PercentMaxEnd))
else
AppendText/W=$PlotName/N=text0 "\K(0,0,0)Percent recovery:\t"+ num2str((PercentMaxEnd))
endif


End