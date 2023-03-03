
//v1_0 (2013-10-30) Measures the peak and baseline of fields of cells.

//v3_0 (2014-01-22) Plots average traces and normalized average traces

//v3_1 (2014-04-09) Loads ImageJ data from second column, plots normalized traces as fields, reorders the graphs on the final field layout

//v3_11 (2014-12-01) Finds Image ID for plotting using variable of tab position

//v_4 (2015-07-29) Add cell size, remove manual check

//v_5 (2015-09-04) Change to work with cell lines info on analysis txt file

//v_5_2 Ability to normalise

//v_5_3 (2015-11-24) Works with Igor v7
//calculates Tau and replaces (s) with _s_
// corrects fold change
// Rearranges waves in the correct order

//v6 Simplified so only for input


Constant kStartTimeMax=1
Constant kEndTimeMax=30




#include <Waves Average>

Menu "DJW Generic Ca analysis", dynamic

"Switch Ca path",/Q,Panel1()
"Basic Ca analysis",/Q, GenCaDetails()



End


Function GenCaDetails()

Variable StartTimeMax = kStartTimeMax
Variable EndTimeMax = kEndTimeMax

print("ST "+num2str(StartTimeMax))
print ("ET "+num2str(EndTimeMax))

Setdatafolder root:


String CaCellLines
String CaPlateDate = StrVarOrDefault("root:gCaPlateDate", "YYYY-MM-DD")
Variable CaPassage = NumVarOrDefault("root:gCaPassage", 1)
String CaExperimentDate = StrVarOrDefault("root:gCellident", "YYYY-MM-DD")
String CaExperimentNotes =  StrVarOrDefault("root:gCaExperimentNotes", "2s 5s 10s 30mM KCl, Fura-2")
String FileNameExtra =  StrVarOrDefault("root:gFileNameExtra", "")

Prompt CaCellLines,"Cell line"
Prompt CaPlateDate, "Plating Date"
Prompt CaPassage, "Passage number"
Prompt CaExperimentDate "Experiment Date"
Prompt CaExperimentNotes "Experiment Notes"
Prompt FileNameExtra "Extra Text for File Name"


DoPrompt "Cell Information",CaCellLines, CaPlateDate, CaPassage,CaExperimentDate, CaExperimentNotes,FileNameExtra

String/G root:gCaCellLines = CaCellLines
String/G root:gCaPlateDate = CaPlateDate
String/G root:gCaCellLines = CaCellLines
Variable/G root:gCaPassage = CaPassage
String/G root:gCaExperimentDate = CaExperimentDate
String/G root:gCaExperimentNotes = CaExperimentNotes
String/G root:gFileNameExtra = FileNameExtra

GenCaDIVCalc()

GenCaSetThresholds()

End


Function GenCaDIVCalc()

SVAR gCaPlateDate = root:gCaPlateDate
SVAR gCaExperimentDate = root:gCaExperimentDate 

GenConvertYYYYMMDDToIgorDate(gCaPlateDate)
NVAR gIgorDate  = root:gIgorDate
Variable IgorPlateDate = gIgorDate

GenConvertYYYYMMDDToIgorDate(gCaExperimentDate)
NVAR  gIgorDate  = root:gIgorDate
Variable IgorExptDate = gIgorDate

Variable/g root:gCaDIV = (IgorExptDate-IgorPlateDate)/(24*60*60)
Print (gIgorDate)

End


Function GenConvertYYYYMMDDToIgorDate(dateStr)
	String dateStr		// In YYYY-MM-DD format
 
	String separatorStr = "-"
 
	Variable month, day, year
	String formatStr = "%d" + separatorStr + "%d" + separatorStr + "%d"
	sscanf dateStr, formatStr, year, month, day
	Variable dt = date2secs(year, month, day )
	Variable/g root:gIgorDate = dt
	print(dt)
	
End



Function GenCaSetThresholds()


Setdatafolder root:
Variable BaselineThreshold = NumVarOrDefault("root:gBaselineThreshold", 1)
Variable FoldChangeThreshold = NumVarOrDefault("root:gFoldChangeThreshold",  1.1)
Variable ReturnToBaselineThreshold = NumVarOrDefault("root:gReturnToBaselineThreshold",  80)
Variable TauThreshold = NumVarOrDefault("root:gTauThreshold", 50)
Variable SizeThreshold = NumVarOrDefault("root:gSizeThreshold", 1)
String IncludePlots 

Prompt BaselineThreshold, "Maximum baseline intensity"
Prompt FoldChangeThreshold, "Minimum intensity fold change percent"
Prompt ReturnToBaselineThreshold, "Percent recovery to baseline"
Prompt TauThreshold, "Maximum tau"
Prompt SizeThreshold, "Minimum Size (um2)"
Prompt IncludePlots , "Draw Plots?" popup "Yes;No"

DoPrompt "Thresholds for analysis",BaselineThreshold,FoldChangeThreshold,ReturnToBaselineThreshold,TauThreshold,SizeThreshold,IncludePlots

Variable/G root:gBaselineThreshold = BaselineThreshold
Variable/G root:gFoldChangeThreshold = FoldChangeThreshold
Variable/G root:gTauThreshold = TauThreshold
Variable/G root:gReturnToBaselineThreshold = ReturnToBaselineThreshold
Variable/G root:gSizeThreshold = SizeThreshold
Variable/G root:gSizeThreshold = SizeThreshold
String/G root:gIncludePlots = IncludePlots



RenameMe()

End





