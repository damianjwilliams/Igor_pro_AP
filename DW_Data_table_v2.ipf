//#pragma rtGlobals=3		

//DataTable() version 1_0
//Constructs and saves data table in tab delimited text format

//DataTable() version 1_1
//2014-06-23 Adds RMP data

//DataTable() version 1_2
//2014-06-30 replaces rate of rise and fall with maximum rate rise fall

//DataTable() version 1_3
//2015-05-04 adds new rheobase and max current 



Function ManualAdd()
	PauseUpdate; Silent 1		// building window...
	NewPanel /W=(333,308,523,508) /N=NextLoop
	CheckBox check0,pos={72,89},size={40,14}, title="H current"
	CheckBox check0,value= 0
	CheckBox check1,pos={75,39},size={40,14},title="\"Hump\""
	CheckBox check1,value= 0
	DrawText 40,20,"Boxes Checked"
	Button button1,pos={60,147},size={50,20},title="OK",proc = kill
	PauseForUser nextLoop
	
	
End

Function kill(ctrlName) : ButtonControl
	String ctrlName
	controlinfo check0
	if (V_value == 1)
	String/G root:gHCurrent = "Present"
	else
	String/G root:gHCurrent = "Absent"
	endif
	print (V_value)
	
	controlinfo check1
	if (V_value == 1)
	String/G root:gHump = "Present"
	else
	String/G root:gHump = "Absent"
	endif
	print(V_value)
	
	KillWindow NextLoop

End



Function Datatable()

//ManualAdd()

Setdatafolder root:

SVAR gCellFolderName
SVAR gCustompath



SVAR/Z gCell_subtype = gCell_subtype
if(!SVAR_Exists(gCell_subtype))
String/g  gCell_subtype = "undefined"
endif  

NVAR/Z gAutoScaleCurr
if(!NVAR_Exists(gAutoScaleCurr))
Variable/g  gAutoScaleCurr = NaN
endif

NVAR/Z gHypStep
if(!NVAR_Exists(gHypStep))
Variable/g  gHypStep = NaN
endif

NVAR/Z gDepolStep
if(!NVAR_Exists(gDepolStep))
Variable/g  gDepolStep = NaN
endif   

  



Setdatafolder $gCellFolderName

NVAR/Z gIm_sec_gain
if(!NVAR_Exists(gIm_sec_gain))
Variable/g  gIm_sec_gain = NaN
endif


NVAR/Z gDIV = root:gDIV
if(!NVAR_Exists(gDIV))
Variable/g  gDIV = NaN
endif  


NVAR/Z gPassage
if(!NVAR_Exists(gPassage))
Variable/g  gPassage = NaN
endif  


NVAR/Z gInputResistance
if(!NVAR_Exists( gInputResistance))
Variable/g   gInputResistance = NaN
endif  



//
NVAR/Z gAvRiseCap
if(!NVAR_Exists( gAvRiseCap))
Variable/g   gAvRiseCap = NaN
endif  

NVAR/Z gAvRiseCapSEM
if(!NVAR_Exists( gAvRiseCapSEM))
Variable/g   gAvRiseCapSEM = NaN
endif  

NVAR/Z gAvFallCap
if(!NVAR_Exists( gAvFallCap))
Variable/g   gAvFallCap = NaN
endif  

NVAR/Z gAvFallCapSEM
if(!NVAR_Exists( gAvFallCapSEM))
Variable/g   gAvFallCapSEM = NaN
endif  

NVAR/Z gCapacitance
if(!NVAR_Exists(gCapacitance))
Variable/g  gCapacitance = NaN
endif  

NVAR/Z gRm
if(!NVAR_Exists(gRm))
Variable/g  gRm = NaN
endif

NVAR/Z gRa
if(!NVAR_Exists(gRa))
Variable/g  gRa = NaN
endif  

NVAR/Z gHold
if(!NVAR_Exists(gHold))
Variable/g  gHold = NaN
endif  
  

///

NVAR/Z gRmOrig
if(!NVAR_Exists(gRmOrig))
Variable/g  gRmOrig = NaN
endif  

NVAR/Z gRmManual
if(!NVAR_Exists(gRmManual))
Variable/g  gRmManual = NaN
endif  

NVAR/Z gRmAuto
if(!NVAR_Exists(gRmAuto))
Variable/g  gRmAuto = NaN
endif  

NVAR/Z gCapTauOrig
if(!NVAR_Exists(gCapTauOrig))
Variable/g  gCapTauOrig = NaN
endif  

NVAR/Z  gCapTauManual
if(!NVAR_Exists( gCapTauManual))
Variable/g   gCapTauManual = NaN
endif  

NVAR/Z gCapTauAuto 
if(!NVAR_Exists(gCapTauAuto ))
Variable/g gCapTauAuto  = NaN
endif  

///



NVAR/Z gRMP = gRMP
if(!NVAR_Exists(gRMP))
Variable/g  gRMP = NaN
endif  

// Humps






NVAR/Z gdouble_diff_peak_one = gdouble_diff_peak_one
if(!NVAR_Exists(gdouble_diff_peak_one))
Variable/g gdouble_diff_peak_one = NaN
endif   

NVAR/Z gdouble_diff_peak_two = gdouble_diff_peak_two
if(!NVAR_Exists(gdouble_diff_peak_two))
Variable/g gdouble_diff_peak_two = NaN
endif   

NVAR/Z gpeak_ratio = gpeak_ratio
if(!NVAR_Exists(gpeak_ratio))
Variable/g gpeak_ratio = NaN
endif  

NVAR/Z gdouble_diff_latency = gdouble_diff_latency
if(!NVAR_Exists(gdouble_diff_latency))
Variable/g gdouble_diff_latency = NaN
endif 

NVAR/Z gfirst_isi = gfirst_isi
if(!NVAR_Exists(gfirst_isi))
Variable/g gfirst_isi = NaN
endif 


NVAR/Z gChange_in_AP_amplitude = gChange_in_AP_amplitude
if(!NVAR_Exists(gChange_in_AP_amplitude))
Variable/g gChange_in_AP_amplitude = NaN
endif   

NVAR/Z gChange_in_AP_rate = gChange_in_AP_rate
if(!NVAR_Exists(gChange_in_AP_rate))
Variable/g gChange_in_AP_rate = NaN
endif  

NVAR/Z gChange_in_AP_threshold  = gChange_in_AP_threshold 
if(!NVAR_Exists(gChange_in_AP_threshold))
Variable/g gChange_in_AP_threshold = NaN
endif 

NVAR/Z ghalf_max_AP_sweep  = ghalf_max_AP_sweep 
if(!NVAR_Exists(ghalf_max_AP_sweep))
Variable/g ghalf_max_AP_sweep = NaN
endif


NVAR/Z gAP_duration = gAP_duration
if(!NVAR_Exists(gAP_duration))
Variable/g gAP_duration = NaN
endif   

NVAR/Z gAP_amplitude = gAP_amplitude
if(!NVAR_Exists(gAP_amplitude))
Variable/g gAP_amplitude = NaN
endif   

NVAR/Z gAP_risetime = gAP_risetime
if(!NVAR_Exists(gAP_risetime))
Variable/g gAP_risetime = NaN
endif  

NVAR/Z gAP_falltime = gAP_falltime
if(!NVAR_Exists(gAP_falltime))
Variable/g gAP_falltime = NaN
endif  

 
NVAR/Z gMax_AP_rise = gMax_AP_rise
if(!NVAR_Exists(gMax_AP_rise))
Variable/g gMax_AP_rise = NaN
endif  

NVAR/Z gMax_AP_fall = gMax_AP_fall
if(!NVAR_Exists(gMax_AP_fall))
Variable/g gMax_AP_fall = NaN
endif  


NVAR/Z gAP_threshold =  gAP_threshold
if(!NVAR_Exists( gAP_threshold))
Variable/g  gAP_threshold = NaN
endif  

NVAR/Z gAP_SFA =  gAP_SFA
if(!NVAR_Exists( gAP_SFA))
Variable/g  gAP_SFA = NaN
endif

NVAR/Z gI_at_max_AP =  gI_at_max_AP
if(!NVAR_Exists( gI_at_max_AP))
Variable/g  gI_at_max_AP = NaN
endif  

Variable APsVar

NVAR/Z gMaxNoAPs = gMaxNoAPs
if(!NVAR_Exists(gMaxNoAPs))
Variable/g  gMaxNoAPs = NaN
APsVar = 0
else
APsVar = gMaxNoAPs
endif


//Trough quantification


NVAR/Z gap_trough_val = gap_trough_val
if(!NVAR_Exists(gap_trough_val))
Variable/g  gap_trough_val = NaN
endif

NVAR/Z gap_fast_trough_val = gap_fast_trough_val
if(!NVAR_Exists(gap_fast_trough_val))
Variable/g  gap_fast_trough_val = NaN
endif

NVAR/Z gap_slow_trough_val =gap_slow_trough_val
if(!NVAR_Exists(gap_slow_trough_val))
Variable/g  gap_slow_trough_val = NaN
endif  

//





NVAR/Z gI_at_max_AP = gI_at_max_AP
if(!NVAR_Exists(gI_at_max_AP))
Variable/g  gI_at_max_AP = NaN
endif





NVAR/Z gHCurrent = gHCurrent
if(!NVAR_Exists(gHCurrent))
Variable/g  gHCurrent = NaN
endif


NVAR/Z gRheobase =gRheobase
if(!NVAR_Exists(gRheobase))
Variable/g  gRheobase = NaN
endif  


SVAR/Z gPlateDate = root:gPlateDate
if(!SVAR_Exists(gPlateDate))
String/g gPlateDate = "undefined"
endif  

SVAR/Z gStaFileNm = gStaFileNm
if(!SVAR_Exists(gStaFileNm))
String/g gStaFileNm = "undefined"
endif  

SVAR/Z gGenotype = gGenotype
if(!SVAR_Exists( gGenotype))
String/g gGenotype = "undefined"
endif

SVAR/Z gReporter = gReporter
if(!SVAR_Exists( gReporter))
String/g gReporter = "undefined"
endif

SVAR/Z gAstro = gAstro
if(!SVAR_Exists(gAstro))
String/g  gAstro = "undefined"
endif 


strswitch(gAstro) // string switch
case "iPS-MNs only":
gAstro = "No"
break
case "Cortical Astrocytes":
gAstro = "Yes"
break
endswitch




NVAR/Z gAP_SFA =  gAP_SFA
if(!NVAR_Exists( gAP_SFA))
Variable/g  gAP_SFA = NaN
endif 

NVAR/Z gAP_SFA =  gAP_SFA
if(!NVAR_Exists( gAP_SFA))
Variable/g  gAP_SFA = NaN
endif 

SVAR/Z  HypTrace
if(!SVAR_Exists(HypTrace))
String/g   HypTrace = "undefined"
endif  

SVAR/Z gAPTrace = gAPTrace
if(!SVAR_Exists(gAPTrace))
String/g  gAPTrace = "undefined"
endif 

SVAR/Z gCell_ID = gCell_ID
if(!SVAR_Exists(gCell_ID))
String/g  gCell_ID = "undefined"
endif  



NewNotebook/F=1/N=cell_data as "Cell Data"

Notebook cell_data tabs={200,280}

Notebook cell_data, fstyle=1, text = "Cell\t" + gCell_ID+"\r"
Notebook cell_data text = "Genotype\t" +gGenotype+"\r"
Notebook cell_data text = "Label\t" +gReporter+"\r"
Notebook cell_data text = "Cell_subtype\t" +gCell_subtype+"\r"
Notebook cell_data text = "Astrocytes\t" +gAstro+"\r"
Notebook cell_data text = "DIV\t" + num2str(gDIV) +"\r"
Notebook cell_data text = "Date_of_plating\t"+ gPlateDate+ "\r"
Notebook cell_data text = "Membrane_resistance_MOhm\t" + num2str(gInputResistance) +"\r"
Notebook cell_data text = "VCCapacitance_pF\t" + num2str(gCapacitance) +"\r"
Notebook cell_data text = "ICCapacitance_rise_pF\t" + num2str(gAvRiseCap) +"\r"
Notebook cell_data text = "ICCapacitance_fall_pF\t" + num2str(gAvFallCap) +"\r"
Notebook cell_data text = "VCRmem_MOhm\t" + num2str(gRm) +"\r"
Notebook cell_data text = "RMP_mV\t" + num2str(gRMP) +"\r"
Notebook cell_data text = "AP_duration_ms\t" + num2str(gAP_duration)+"\r"
Notebook cell_data text = "AP_overshoot_mV\t" + num2str(gAP_amplitude) +"\r"
Notebook cell_data text = "AP_rise_rate_max_mV_per_ms\t" + num2str(gMax_AP_rise) +"\r"
Notebook cell_data text = "AP_fall_rate_max_mV_per_ms\t" + num2str(gMax_AP_fall) +"\r"
Notebook cell_data text = "AP_threshold_mV\t" + num2str(gAP_threshold) +"\r"
Notebook cell_data text = "Max_num_APs\t" + num2str(gMaxNoAPs)+"\r"
Notebook cell_data text = "Rheobase_pA\t" + num2str(gRheobase) +"\r"
Notebook cell_data text = "H_current_mV\t" + num2str(gHCurrent)+"\r"
Notebook cell_data text = "Manual_I_scale_factor_adjustment\t" + num2str(gAutoScaleCurr)+"\r"
Notebook cell_data text = "File_I_scale_factor_adjustment\t" + num2str(gIm_sec_gain)+"\r"
Notebook cell_data text = "I_hold_pA_-80mV\t" + num2str(gHold)+"\r"
Notebook cell_data text = "Raccess_MOhm\t" + num2str(gRa)+"\r"
Notebook cell_data text = "I_at_max_AP\t" + num2str(gI_at_max_AP)+"\r"
Notebook cell_data text = "AP_trough_mV\t" + num2str(gap_trough_val) +"\r"
Notebook cell_data text = "AP_fast_trough_mV\t" + num2str(gap_fast_trough_val) +"\r"
Notebook cell_data text = "AP_slow_trough_mV\t" + num2str(gap_slow_trough_val) +"\r"

Notebook cell_data text = "Double_dif_peak_one\t" + num2str(gdouble_diff_peak_one)+"\r"
Notebook cell_data text = "Double_dif_peak_two\t" + num2str(gdouble_diff_peak_two) +"\r"
Notebook cell_data text = "Double_dif_peak_ratio\t" + num2str(gpeak_ratio)+"\r"
Notebook cell_data text = "Double_dif_peak_latency\t" + num2str(gdouble_diff_latency)+"\r"

Notebook cell_data text = "AP_SFA\t" + num2str(gAP_SFA)+"\r"
Notebook cell_data text = "Change_thresh_over_train\t" + num2str(gChange_in_AP_threshold)+"\r"
Notebook cell_data text = "Change_amp_over_train\t" + num2str(gChange_in_AP_amplitude)+"\r"
Notebook cell_data text = "Change_rate_over_train\t" + num2str(gChange_in_AP_rate)+"\r"
Notebook cell_data text = "First_isi\t" + num2str(gfirst_isi)+"\r"

Notebook cell_data text = "No_scale_Rm_pA\t" + num2str(gRmOrig) +"\r"
Notebook cell_data text = "Manual_scale_Rm_pA\t" + num2str(gInputResistance)+"\r"
Notebook cell_data text = "File_scale_Rm_pA\t" + num2str(gRmAuto) +"\r"
Notebook cell_data text = "No_scale_Cap_pF\t" + num2str(gCapTauOrig)+"\r"
Notebook cell_data text = "Manual_scale_Cap_pF\t" + num2str(gCapTauManual) +"\r"
Notebook cell_data text = "File_scale_Cap_pF\t" + num2str(gCapTauAuto)+"\r"
Notebook cell_data text = "Hyperpolarizing_I_step_pA\t" + num2str(gDepolStep) +"\r"
Notebook cell_data text = "Depolarizing_I_step_pA\t" + num2str(gHypStep)+"\r"

Notebook cell_data text = "Hyperpolarizing_steps_file\t" + HypTrace +"\r"
Notebook cell_data text = "Action_potential_file\t" + gAPTrace +"\r"
Notebook cell_data text = "Memb_test_potential_file\t" + gStaFileNm +"\r"

AppendAPData()


//String SaveFileNameData = gCustomPath+"Ephys Igor output\\"+gCell_ID+".txt"
//SaveNotebook/O/S=6 cell_data as SaveFileNameData


MeasureforImage()


print "finished"

Display/N=MeasurementsA/W=(35.25,52.25,205.5,178.25)
ModifyGraph/W=MeasurementsA gfSize=9
TextBox/W=MeasurementsA/B=1/N=text0/A=LC/X=2.64/Y=-0.60  "Cell:\t\t" + gCell_ID+"\r\rCell line:\t\t" +gGenotype+"\rAstrocytes:\t"+gAstro+"\rDIV:\t\t" + num2str(gDIV) +"\rDate of plating:\t"+ gPlateDate+"\rRinput IC:\t" + num2str(gInputResistance) +"\t\[0M\F'Symbol'W\]0\r"+"RInput VC:\t"+num2str(gRm)+"\t\[0M\F'Symbol'W\]0\rVC Capacitance:\t" + num2str(gCapacitance) +"\tpF\rIC rise tau Cap:\t" + num2str(gAvRiseCap) +" ± "+ num2str(gAvRiseCapSEM)+"\tpF\rIC rise tau Cap:\t" + num2str(gAvFallCap) +" ± "+ num2str(gAvFallCapSEM)+"\tpF\rRMP:\t\t" + num2str(gRMP) +"\tmV\rH current:\t"+num2str(gHCurrent)+"\tmV"



Display/N=MeasurementsB/W=(35.25,43.25,313.5,86)
ModifyGraph/W=MeasurementsB gfSize=9
TextBox/W=MeasurementsB/B=1/N=text3/A=RC/X=2.43/Y=5.26 "Pass. mem. prop. file:\t" + HypTrace +"\rAP char. file :\t\t" +gAPTrace+"\rMemb. test. file :\t" +gStaFileNm+"\rMan. I Scaling fact.:\t"+num2str(gAutoScaleCurr)+"\rFile I Scaling fact.:\t"+num2str(gIm_sec_gain)+"\rR_access:\t" + num2str(round(gRa*100)/100) +"\tMOhm\rI_hold:\t" + num2str(round(gHold*100)/100) +"\tpA\rHyperpol step:\t"+ num2str(gHypStep)+"\tpA\rDepol step:\t"+ num2str(gHypStep)+"\tpA"


Display/N=MeasurementsC/W=(176.25,220.25,332.25,338)
ModifyGraph/W=MeasurementsC gfSize=9
TextBox/W=MeasurementsC/B=1/N=text1/A=MC/X=0.00/Y=1.66  "AP duration:\t" + num2str(round(gAP_duration*100)/100)+"\tms\rAP amplitude:\t" + num2str(round(gAP_amplitude*100)/100) +"\tmV\rMax rt rise:\t" + num2str(round(gMax_AP_rise*100)/100) +"\tmV/ms\rMax rt fall:\t" + num2str(round(gMax_AP_fall*100)/100) +"\tmV/ms\rAP thresh:\t" + num2str(round(gAP_threshold*100)/100) +" \tmV\rAP SFA:\t\t" + num2str(gAP_SFA)+"\rMax No. APs:\t"+num2str(gMaxNoAPs)+"\rRheobase:\t" + num2str(round(gRheobase))+"\tpA\rI at Max AP:\t" + num2str(gI_at_max_AP)+ "\tpA"


MakenewLayout()

SFA_layout()

CapLayout()

End



Function SFA_layout()

Setdatafolder root:
SVAR  gCellFolderName
Setdatafolder $(gCellFolderName)

SVAR gCell_ID,gGenotype,gAPTrace
NVAR gAP_SFA,gChange_in_AP_threshold,gChange_in_AP_rate,ghalf_max_AP_sweep,gChange_in_AP_amplitude

NewLayout/N=SFA_page/W=(200,263,706,861)
	if (IgorVersion() >= 7.00)
		LayoutPageAction size=(612,792),margins=(18,18,18,18)
	endif
	///AppendLayoutObject/W=SFA_page/F=1/T=0/R=(24,16,370,244) Graph half_max_trace
	//AppendLayoutObject/W=SFA_page/F=1/T=0/R=(16,244,292,454) Graph first_last_traces
	//AppendLayoutObject/W=SFA_page/F=1/T=0/R=(292,244,600,454) Graph phase_plane
	//AppendLayoutObject/W=SFA_page/F=1/T=0/R=(292,244,600,454) Graph troughs
	AppendLayoutObject/W=SFA_page/F=1/T=0/R=(18,15,364,243) Graph half_max_trace
	AppendLayoutObject/W=SFA_page/F=1/T=0/R=(14,246,290,456) Graph first_last_traces
	AppendLayoutObject/W=SFA_page/F=1/T=0/R=(292,244,600,454) Graph phase_plane
	AppendLayoutObject/W=SFA_page/F=1/T=0/R=(18,457,596,780) Graph troughs
	
	TextBox/W=SFA_page/C/N=text0/A=RT/X=9.38/Y=0.53 "Cell: "+gcell_ID+"\rGenotype: "+gGenotype+"\rTrace ID: "+gAPTrace+"\rSweep Number: "+num2str(ghalf_max_AP_sweep)+"\rSFA: "+num2str(gAP_SFA)+"\rThrehold change (last/first): "+num2str(gChange_in_AP_threshold)+"\rRate change (last/first): "+num2str(gChange_in_AP_rate)+"\rAmplitude change (last/first):"+num2str(gChange_in_AP_amplitude)
	//ModifyLayout/W=SFA_page width(text0)=228,height(text0)=204


End




Function CapLayout()

Setdatafolder root:

SVAR  gCellFolderName
SVAR gCustomPath

Setdatafolder $(gCellFolderName)

SVAR gCell_ID


NewLayout/k=1/N=AutoCap

String ListofWindows = WinList("Cap*",";","WIN:1")

ListofWindows = sortlist(ListofWindows)


variable i

for(i=0;i<itemsinlist(ListofWindows);i+=1)



String CurrentCapPlot = Stringfromlist(i,ListofWindows)

print CurrentCapPlot

Appendlayoutobject/W=AutoCap graph $CurrentCapPlot

Execute("Tile/O=0")

endfor

//String SaveFileNameData = gCustomPath+"Ephys Igor output\\"+gCell_ID+"_Cap.pdf"
//SavePict/E=-8/O/WIN=Monkey as SaveFileNameData




End

Function AppendAPData()


Setdatafolder root:



SVAR  gCellFolderName


Setdatafolder $(gCellFolderName)


NVAR pp_files_present


Setdatafolder ActionPotential

Wave NumberAPs
Wave ComCurrValues

variable NumDataPoints =numpnts(ComCurrValues)
variable j

String nb  = "cell_data"
String str 

Notebook $nb selection={endOfFile, endOfFile}

For(j=0;j<NumDataPoints;j+=1)

string  ComI = num2str(ComCurrValues[j])
string  APs = num2str(NumberAPs[j])

str = "ComI - APs\t"+ComI+" - "+APs

Notebook $nb text= str+"\r"

endfor




if(NVAR_Exists(pp_files_present))
	append_paired_pulse_data()
endif 



End



Function append_paired_pulse_data()


Setdatafolder root:



SVAR  gCellFolderName


Setdatafolder $(gCellFolderName)

Setdatafolder paired_pulse

Wave pp_freq_a
Wave pp_ratio_a

variable NumDataPoints =numpnts(pp_ratio_a)
variable j

String nb  = "cell_data"
String str 

Notebook $nb selection={endOfFile, endOfFile}

For(j=0;j<NumDataPoints;j+=1)

string  freq = num2str(pp_freq_a[j])
string  ratio = num2str(pp_ratio_a[j])

str = "PP - freq\t"+freq+" - "+ratio

Notebook $nb text= str+"\r"

endfor


End











Function SaveEverything()

Setdatafolder root:

SVAR  gCellFolderName
SVAR gCustomPath


Setdatafolder $(gCellFolderName)

SVAR gCell_ID


String SaveFileNameDataImage = gCustomPath+"Image_data\\"+gCell_ID+"_image_data.txt"
SaveNotebook/O/S=6 Image_data as SaveFileNameDataImage

//Save Capacitance Traces
String SaveFileNameDataCap = gCustomPath+gCell_ID+"_Cap.pdf"
SavePict/E=-8/O/WIN=AutoCap as SaveFileNameDataCap

//Save Text File
String SaveFileNameDataTxT = gCustomPath+gCell_ID+".txt"
SaveNotebook/O/S=6 cell_data as SaveFileNameDataTxT

String SaveFileNameDataPlot = gCustomPath+gCell_ID+".pdf"
SavePict/E=-8/O/WIN=Collateddata as SaveFileNameDataPlot


String SaveFileNameDataSFA = gCustomPath+gCell_ID+"_SFA.pdf"
SavePict/E=-8/O/WIN=SFA_page as SaveFileNameDataSFA

//


End




