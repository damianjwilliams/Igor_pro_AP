
//Constant k_stim_time = 156.3



Constant K_t_after_stim = 2
Constant K_dc_measurement_period = 30

Constant K_Cl_rev = -65
Constant K_cation_reversal_potential = 0 
Constant  K_junction_potential = -15

//Constant K_decomp_measurement_region_start = 148
//Constant K_decomp_measurement_region_end = 167

Constant K_dc_V_step_start = 106
Constant K_dc_V_Step_end = 221



Function CalcDiagDialog()

 Variable x=9,y=146.25
  Prompt x, "Final sweep: " // Set prompt for x param
  Prompt y, "Stim_time: " // Set prompt for x param
  DoPrompt "Enter final sweep start at zero", x,y
  if (V_Flag) 
  return -1 
  endif 
  Print "Diagonal="+num2str(x)
  variable/g gLast_sweep = x
  variable/g gStim_time = y
End



Function Decomp_analysis(Current_file,S_path)

String Current_file,S_path

String Current_file_path = S_path+Current_file







NMImportFile( "new" ,Current_file_path)
DoWindow /K ImportPanel
print(Current_file_path)

Variable idx,i
Variable CFError
NVAR Num_traces = NumWaves

Make/O/N=0 Voltage_table
Make/O/N=0 Total_current_table


CalcDiagDialog()

NVAR gLast_sweep
NVAR gStim_time


for(idx=0;idx<gLast_sweep;idx+=1)

	String I_trace_name = "RecordA" +num2str(idx)
	Wave I_trace = $I_trace_name
	
	String ComV_trace_name = "RecordB" +num2str(idx)
	Wave ComV_trace = $ComV_trace_name

	//String Stim_trace_name = "RecordC" +num2str(idx)
	//Wave Stim_trace = $Stim_trace_name
	
	//Stim position
	//Wavestats/Q Stim_trace	
	//FindLevel/EDGE=1 Stim_trace, V_max/2	

	
	Variable dc_measurement_region_start, dc_measurement_region_end, Baseline_region_start, Baseline_region_end
	
	
	
	////This for curve fitting the step region data to remove underlying changes/////
	
	//Mask region period
	
	Variable Mask_region_A_start,Mask_region_A_end,Mask_region_B_start,Mask_region_B_end
	
	Mask_region_A_start = K_dc_V_step_start+30
	Mask_region_A_end = gStim_time-2
	Mask_region_B_start = gStim_time +K_dc_measurement_period
	Mask_region_B_end = K_dc_V_step_end-20
	
	//Measurement period
	dc_measurement_region_start = gStim_time + K_t_after_stim	
	dc_measurement_region_end = dc_measurement_region_start +k_dc_measurement_period	
	Baseline_region_end = gStim_time-1	
	Baseline_region_start = Baseline_region_end-5	
	
	String Maskname = I_trace_name+"_mask"
	String Select_name = I_trace_name+"_selection"
	
	Duplicate I_trace $Maskname
	
	Duplicate/O/R=[x2pnt(I_trace,Mask_region_A_start),x2pnt(I_trace,K_dc_V_Step_end-1)] I_trace $Select_name
	
	Wave Selection_wave = $Select_name
	
	Wave Mask = $Maskname
	
	//First mask area
	Mask[x2pnt(Mask,0),x2pnt(Mask,Mask_region_A_start)] = NaN
	//Second mask area
	Mask[x2pnt(Mask,Baseline_region_end),x2pnt(Mask,dc_measurement_region_end)] = NaN
	//I_trace(Baseline_region_start,V_step_start+15) = NaN
	
	Wavestats/Q Mask
	//Third mask area
	Mask[x2pnt(Mask,K_dc_V_Step_end-1),(numpnts(Mask)-1)] = NaN
	
	
	//CurveFit/L=(numpnts($Select_name)) dblexp_XOffset $Maskname /D
	CurveFit/L=(numpnts($Select_name)) line $Maskname /D
	
	
	
	
	
	//Decompo_analysis
	
	try
				Variable V_FitError = 0
				CurveFit/L=(numpnts($Select_name)) line $Maskname /D
				print("**************************************************")
				print(V_FitError)
				print("**************************************************")
				
				if (V_FitError) 
				continue
				endif
				
				CFerror = GetRTError(1)
				
				
				
				

				if(CFError==0)
				
				print("no_error")
				
				
				
				endif


				if (CFerror != 0)

						
						Print GetErrMessage(CFerror)
						
						//ErrorType = "Fit error"

				endif
			
				CFerror = GetRTError(1)	// 1 to clear the error

			catch
	
			
		
		endtry
		

	
	
	String fit_wave_name = "fit_"+maskname
	Wave fit_wave = $fit_wave_name	
	string subtracted_wave_name = I_trace_name+"_subtraction"	
	Duplicate/O Selection_wave, $subtracted_wave_name
	Wave subtracted_wave = $subtracted_wave_name
	
	Wave selected_part = $Select_name	
	subtracted_wave = selected_part-fit_wave
	
	//----------
	
	
	string inward_I_trace_name = I_trace_name+"_inward"
	string outward_I_trace_name = I_trace_name+"_outward"	
	
	Duplicate/O $Select_name, $inward_I_trace_name,$outward_I_trace_name	
	
	wave inward_trace = $inward_I_trace_name	
	wave outward_trace = $outward_I_trace_name	
	
	for(i=0;i<numpnts(subtracted_wave);i+=1)	
	//print(i)
	
	
	if(subtracted_wave[i]>0)
		inward_trace[i] = 0
		outward_trace[i] = subtracted_wave[i]
		
	else
	
		inward_trace[i] = subtracted_wave[i]
		outward_trace[i] = 0
		
	endif	
	
	endfor
	
	//display $inward_I_trace_name
	//display $outward_I_trace_name
	
	//print(area($inward_I_trace_name,Measurement_region_start, Measurement_region_end))
	//print(area($outward_I_trace_name,Measurement_region_start, Measurement_region_end))
	
	
	//--------
	
	variable total_inward_current,total_outward_current, total_current
	
	//total_inward_current = sqrt((area($inward_I_trace_name,Measurement_region_start, Measurement_region_end))^2)
	//total_outward_current =sqrt((area($outward_I_trace_name,Measurement_region_start, Measurement_region_end))^2)
	total_inward_current = area($inward_I_trace_name,dc_measurement_region_start,dc_measurement_region_end)
	total_outward_current = area($outward_I_trace_name,dc_measurement_region_start, dc_measurement_region_end)
	total_current = total_inward_current+total_outward_current
	
	
	
	
	
	
	
	print("inward: "+num2str(total_inward_current)+"\noutward: "+num2str(total_outward_current)+"\ntotal_current: "+num2str(total_current))
	
	//ModifyGraph mode=7,lsize=0.1,hbFill=4,rgb=(34952,34952,34952),plusRGB=(16385,49025,65535,32768)
	//SetAxis bottom 140.26,198.26
	//--------
	
	//Command_voltage
	
	Wavestats/Q/R=(Baseline_region_start,Baseline_region_end) ComV_trace
	//Variable Command_voltage = V_avg+(K_junction_potential*-1)
	
	variable start_voltage = -135
	variable increment = 10
	variable command_voltage =  start_voltage+(increment*idx)+(K_junction_potential*-1)
	print("************************************command***********************************")
	print(command_voltage)
	print("******************************************************************************")
	
	InsertPoints inf,1, Voltage_table
		 Voltage_table[inf] =  command_voltage	
	
	
	//Baseline
	Wavestats/Q/R=(Baseline_region_start,Baseline_region_end) I_trace
	Variable Leak = V_avg
	
	print("Voltage step: "+num2str(Command_voltage)+" Leak_current: "+num2str(Leak))	
	
	
	
	String I_trace_selection_name = I_trace_name+"_selection"
	Duplicate/R=(Baseline_region_start,dc_measurement_region_end)/O $I_trace_name,$I_trace_selection_name
	
	Wave Trace_analysis =  $I_trace_selection_name
	
	Trace_analysis = Trace_analysis-Leak
	
	//Display Trace_analysis
	
	//Amplitude
	Wavestats/Q/R=(dc_measurement_region_start,dc_measurement_region_end) Trace_analysis
	Variable Max_outward = V_max
	Variable Max_outward_t = V_maxloc
	
	Variable Max_inward = V_min	
	Variable Max_inward_t = V_minloc	
	
	print("Outward current: "+num2str(Max_inward))
	
	if(Max_inward>(-8000))
		InsertPoints inf,1, Total_current_table
		Total_current_table[inf] = total_current	
	
	
	
	endif
	
	Display/N=trace_region/W=(48,66,601,394) subtracted_wave

	variable ymin,ymax,xmin,xmax
	
	String Area_wave_name = I_trace_name+"_area"	
	
	Duplicate/R=(dc_measurement_region_start, dc_measurement_region_end) subtracted_wave $Area_wave_name
	
	AppendtoGraph/W=trace_region $Select_name
	AppendToGraph/W=trace_region $Area_wave_name	
	
	GetAxis/Q/W=trace_region left; ymin = V_min
	GetAxis/Q/W=trace_region left; ymax = V_max
	
	GetAxis/Q/W=trace_region bottom; xmin = V_min
	GetAxis/Q/W=trace_region bottom; xmax = V_max
	
	print(" y min: "+num2str(ymin)+" y max: "+num2str(ymax)+ " x min: "+num2str(xmin)+" x max: "+num2str(xmax))	
		
	
	//Peak inward
	SetDrawEnv/W=trace_region xcoord= bottom,ycoord= left
	SetDrawEnv/W=trace_region dash = 2
	DrawLine/W=trace_region Max_inward_t,Max_inward, xmin, Max_inward

	//Peak outward
	SetDrawEnv/W=trace_region xcoord= bottom,ycoord= left
	SetDrawEnv/W=trace_region dash = 2
	DrawLine/W=trace_region Max_outward_t,Max_outward, xmin, Max_outward
	
	string plot_name = "PSC_"+num2str(idx)
	
	RenameWindow trace_region $plot_name	
	
	Wavestats/Q/R=(dc_measurement_region_start, dc_measurement_region_end) Trace_analysis
	
	ModifyGraph/W=$plot_name rgb($Select_name)=(61166,61166,61166)
	ModifyGraph/W=$plot_name mode($Area_wave_name)=7,lsize($Area_wave_name)=0.1,hbFill($Area_wave_name)=4,rgb($Area_wave_name)=(34952,34952,34952),negRGB($Area_wave_name)=(0,43690,65535),plusRGB($Area_wave_name)=(52428,52428,52428),useNegRGB($Area_wave_name)=1,usePlusRGB($Area_wave_name)=1,useNegPat($Area_wave_name)=1,hBarNegFill($Area_wave_name)=4
	
	
	
	
	endfor
		
	
	
	
	
	
	
	
	//edit Voltage_table,Total_current_table
	
	Display/N=decomp_A Total_current_table vs Voltage_table	
	ModifyGraph/W=decomp_A mode=3,marker=19	
	CurveFit/TBOX=768 line ::Total_current_table /X=::Voltage_table /D
	
	Wave W_coef
	
	variable intercept = W_coef[0]
	variable slope = W_coef[1]  
	
	print("intercept: "+ num2str(intercept) + "slope: "+ num2str(slope))
	
	
simple_iv(dc_measurement_region_start, dc_measurement_region_end)


End





Function simple_iv(dc_measurement_region_start, dc_measurement_region_end)

variable dc_measurement_region_start
variable dc_measurement_region_end

variable i,peak_inward_current,peak_inward_current_loc
variable inward_current
string trace_list = WaveList("*_subtraction",";","")
string current_trace
Wave voltage_table
variable/g gX_val






//k_decomp_measurement_region_start = 147
//k_decomp_measurement_region_end = 166

Make/O/N=0 decomp_I_values_IV



print(trace_list)
Display/N=dc_corrected_steps_plot



for(i=0;i<itemsinList(trace_list);i+=1)
current_trace = stringFromList(i,trace_list)
Wave trace = $current_trace

	if(i==0)
		Wavestats/R=(dc_measurement_region_start, dc_measurement_region_end) trace
		//peak_inward_current = V_min	
		peak_inward_current_loc = V_minloc
		print("----"+num2str(peak_inward_current_loc)+"------")
		gX_val = rightx(trace)
		
			
	endif

	inward_current = trace(peak_inward_current_loc)
	print(inward_current)
	InsertPoints inf,1, decomp_I_values_IV
	decomp_I_values_IV[inf] =  inward_current

AppendToGraph/W=dc_corrected_steps_plot trace
endfor

//Draw region where calc is made
wavestats/Q trace


display/N=decomp_I_V/L=current /B=voltage decomp_I_values_IV vs voltage_table
ModifyGraph/W=decomp_I_V mode(decomp_I_values_IV)=3,marker(decomp_I_values_IV)=19,freePos(current)={0,voltage},freePos(voltage)={0,current} 
//SetAxis/W=decomp_I_V current *,100
SetAxis/W=decomp_I_V voltage -120,20
Doupdate/W=decomp_I_V

CurveFit/X=1 line decomp_I_values_IV /X=Voltage_table /D



TextBox/W=decomp_I_V/C/N=text_decomp_IV/F=0/A=MT/E "Erev at at max inward I"
Label/W=decomp_I_V current "Current (pA)";DelayUpdate
Label/W=decomp_I_V voltage "Voltage"


Wave W_coef
variable y_intercept = W_coef[0]
variable slope = W_coef[1]
print(y_intercept) 

variable Erev = (y_intercept*-1)/slope
print("Reversal_potential = " +num2str(Erev))
variable/g gErev = Erev

erev_f(peak_inward_current_loc,dc_measurement_region_start,dc_measurement_region_end)


End



Function erev_f(peak_inward_current_loc,dc_measurement_region_start,dc_measurement_region_end)
//Function erev_f()


variable peak_inward_current_loc
variable dc_measurement_region_start
variable dc_measurement_region_end


variable i,peak_inward_current,j
variable inward_current
string trace_list = WaveList("*_subtraction",";","")
string current_trace
Wave voltage_table

NVAR gX_val,gErev,gStim_time
SVAR FileName

string trace_name = getDataFolder(0)
DFREF decomp_folder =  getdataFolderDFR()
Setdatafolder root:
SVAR gCustompath
SVAR  gCellFolderName

Setdatafolder $(gCellFolderName)
SVAR gCell_ID
SVAR gGenotype


setdataFolder decomp_folder


Make/O/N=0 decomp_I_values
Make/O/N=0 Erev_wave
Display/N=dc_corrected_steps_plot_ii
Make/O/N=0 G_wave


print(trace_list)
//Display/N=dc_corrected_steps_plot

//Number of  time points to caculate

Wave RecordA0_subtraction

make/O/N=0 man_voltage




//for(j=measurement_region_start_point;j<measurement_region_end_point;j+=1)
for(j=0;j<numpnts(RecordA0_subtraction);j+=1)
	
	Make/O/N=0 decomp_I_values

	for(i=0;i<itemsinList(trace_list);i+=1)
		current_trace = stringFromList(i,trace_list)
		Wave trace = $current_trace
		inward_current = trace[j]
		//print(inward_current)
		InsertPoints inf,1, decomp_I_values
		decomp_I_values[inf] =  inward_current
		if(j==0)
			AppendToGraph/W=dc_corrected_steps_plot_ii trace
		
		endif
		
	endfor
	
	CurveFit/Q line decomp_I_values /X=voltage_table /D
	Wave W_coef
	variable y_intercept = W_coef[0]
	variable slope = W_coef[1]
	//print(y_intercept) 

	variable Erev = (y_intercept*-1)/slope
	//print(j)
	//print("Reversal_potential = " +num2str(Erev))
	
	InsertPoints inf,1, Erev_wave
		Erev_wave[inf] =  Erev
	
	InsertPoints inf,1, G_wave
		G_wave[inf] =  slope
	
endfor

Copyscales/I RecordA0_subtraction,Erev_wave

//print(deltax(Erev_wave))

//variable measurement_region_start_point = x2pnt(Erev_wave,measurement_region_start)
//variable measurement_region_end_point = x2pnt(Erev_wave,measurement_region_end)

//print(measurement_region_start_point)
//print(measurement_region_end_point)

//Display/N=combo_trace Erev_wave

ModifyGraph/W=dc_corrected_steps_plot_ii axisEnab(left)={0.4,0.9}
AppendToGraph/W=dc_corrected_steps_plot_ii/L=left_erev/B=bottom_erev Erev_wave
ModifyGraph/W=dc_corrected_steps_plot_ii axisEnab(left_erev)={0,0.35},freePos(left_erev)=0//freePos(bottom_erev)={0,left_erev}
SetAxis/W=dc_corrected_steps_plot_ii bottom dc_measurement_region_start,dc_measurement_region_end
SetAxis/W=dc_corrected_steps_plot_ii bottom_erev dc_measurement_region_start,dc_measurement_region_end
SetAxis/W=dc_corrected_steps_plot_ii left_erev -80,10
ModifyGraph/W=dc_corrected_steps_plot_ii noLabel(bottom)=2,axThick(bottom)=0
SetAxis/W=dc_corrected_steps_plot_ii/A=2 left

Doupdate/W=dc_corrected_steps_plot_ii

GetAxis/Q/W=dc_corrected_steps_plot_ii left
SetDrawEnv xcoord= bottom,ycoord= left,dash=3,linethick=1
DrawLine/W=dc_corrected_steps_plot_ii peak_inward_current_loc,V_max,peak_inward_current_loc,V_min

Label/W=dc_corrected_steps_plot_ii left "Current (pA)"
Label/W=dc_corrected_steps_plot_ii bottom_erev "Time (ms)"
Label/W=dc_corrected_steps_plot_ii left_erev "Veq (mV)"

Doupdate/W=dc_corrected_steps_plot_ii



//Rename g_wave

KillWaves/Z synaptic_conductance
rename G_wave, synaptic_conductance

Wave synaptic_conductance

Copyscales/I RecordA0_subtraction, synaptic_conductance
Display/N=dc_g_syn_plot synaptic_conductance


//Calculation of Gi Ge
variable E_rev_e = 0
variable E_rev_i = -65

Duplicate/O RecordA0_subtraction inhibitory_conductance,excitatory_conductance,prop_inhib_trace,prop_excite_trace

inhibitory_conductance=(synaptic_conductance*(E_rev_e-Erev_wave))/(E_rev_e-E_rev_i)
excitatory_conductance=G_wave-inhibitory_conductance


Wavestats/Q/R=(dc_measurement_region_start, dc_measurement_region_end) synaptic_conductance
		//peak_inward_current = V_min	
variable peak_conductance_loc = V_maxloc
variable peak_conductance = V_max
print("peak conductance location ----"+num2str(peak_conductance_loc)+"------")

variable peak_total_conductance_val = synaptic_conductance(peak_conductance_loc)
variable inhibitory_conductance_val = inhibitory_conductance(peak_conductance_loc)
variable excitatory_conductance_val = excitatory_conductance(peak_conductance_loc)

print(peak_total_conductance_val)
print(inhibitory_conductance_val)
print(excitatory_conductance_val)

variable/g ggi_fraction = inhibitory_conductance_val/peak_total_conductance_val
variable/g gei_ratio = excitatory_conductance_val/inhibitory_conductance_val

print("Gi fraction = "+num2str(ggi_fraction))
print("E/I ratio = "+num2str(gei_ratio))
print("Peak conductance = "+num2str(peak_conductance))
print("Erev = "+ num2str(gErev))


appendtoGraph/W=dc_g_syn_plot inhibitory_conductance,excitatory_conductance
ModifyGraph/W=dc_g_syn_plot rgb(inhibitory_conductance)=(1,26214,0),rgb(excitatory_conductance)=(0,0,65000)
Legend/W=dc_g_syn_plot/C/N=text0/F=0/A=RT
SetAxis/W=dc_g_syn_plot bottom dc_measurement_region_start,dc_measurement_region_end
SetAxis/W=dc_g_syn_plot/A=2 left
Label/W=dc_g_syn_plot left "Conductance (nS)";DelayUpdate
Label/W=dc_g_syn_plot bottom "Time (ms)"
TextBox/W=dc_g_syn_plot/C/N=text1/F=0/A=MT/E "Synaptic conductance decomposition"

Doupdate/W=dc_g_syn_plot

GetAxis/Q/W=dc_g_syn_plot left
SetDrawEnv xcoord= bottom,ycoord= left,dash=3,linethick=1
DrawLine/W=dc_g_syn_plot peak_conductance_loc,V_max,peak_conductance_loc,V_min
//DrawLine/W=dc_g_syn_plot 150,V_max,150,V_min


//prop_trace = inhibitory_fract_trace/G_wave



prop_inhib_trace = inhibitory_conductance/(inhibitory_conductance+excitatory_conductance)
prop_excite_trace = excitatory_conductance/(excitatory_conductance+inhibitory_conductance)

//display/N=prop_plot prop_inhib_trace
//appendToGraph/W=prop_plot prop_excite_trace

//ModifyGraph/W=prop_plot mode(prop_inhib_trace)=7,hbFill(prop_inhib_trace)=4,lsize(prop_inhib_trace)=0
//ModifyGraph/W=prop_plot useNegRGB(prop_inhib_trace)=1,negRGB(prop_inhib_trace)=(1,52428,52428)
//SetAxis/W=prop_plot left 0,1
//SetAxis/W=prop_plot bottom measurement_region_start,measurement_region_end

//Change axis range for corrected plot


SetAxis/W=dc_corrected_steps_plot bottom dc_measurement_region_start,dc_measurement_region_end

Doupdate/W=dc_corrected_steps_plot

Getaxis/Q/W=dc_corrected_steps_plot_ii left
variable new_correct_steps_plot_max = V_max
variable new_correct_steps_plot_min = V_min

//print("**************")
//print(new_correct_steps_plot_max)
//print(new_correct_steps_plot_min)
//print("**************")

SetAxis/W=dc_corrected_steps_plot left new_correct_steps_plot_min,new_correct_steps_plot_max
SetAxis/W=dc_corrected_steps_plot bottom (dc_measurement_region_start-5),gX_val


Dowindow/F dc_corrected_steps_plot
TextBox/W=dc_corrected_steps_plot/C/N=text_csp/F=0/A=MT/E "Baseline corrected raw I\nline at max inward I"
Label/W=dc_corrected_steps_plot left "Current (pA)";DelayUpdate
Label/W=dc_corrected_steps_plot bottom "Time (ms)"
Doupdate/W=dc_corrected_steps_plot
Getaxis/Q/W=dc_corrected_steps_plot left
SetDrawEnv xcoord= bottom,ycoord= left,dash=3,linethick=1
DrawLine/W=dc_corrected_steps_plot peak_inward_current_loc,V_max,peak_inward_current_loc,V_min
//print(peak_inward_current_loc)
//print(V_max)
//print(V_min)

TextBox/W=dc_corrected_steps_plot_ii/C/N=text_csp_ii/F=0/A=MT/E "Baseline corrected raw with Erev point by point"


Display/N=dc_quant
TextBox/W=dc_quant/C/N=text_dc_quant/F=0/A=MC/E "Cell_ID:"+FileName+"\nE_rev: "+num2str(gErev)+"\ngi_fraction: "+num2str(ggi_fraction)+"\nei_ratio:"+num2str(gei_ratio)




NewLayout/N=dc_plots/W=(54,82,560,448)


if (IgorVersion() >= 7.00)
		LayoutPageAction size=(612,792),margins=(18,18,18,18)
endif
	AppendLayoutObject/W=dc_plots/F=1/T=0/R=(20,154,302,392) Graph dc_corrected_steps_plot
	AppendLayoutObject/W=dc_plots/F=1/T=0/R=(310,400,590,636) Graph dc_corrected_steps_plot_ii
	AppendLayoutObject/W=dc_plots/F=1/T=0/R=(20,400,302,640) Graph dc_g_syn_plot
	AppendLayoutObject/W=dc_plots/F=1/T=0/R=(310,154,590,394) Graph decomp_I_V
	AppendLayoutObject/W=dc_plots/F=1/T=0/R=(22,36,594,144) Graph dc_quant
	
String SaveFileNameDataCap = gCustomPath+gCell_ID+"_decomp_output_Cap.pdf"
SavePict/E=-8/O/WIN=dc_plots as SaveFileNameDataCap	


NewNotebook/F=1/N=dc_data as "Decomposition Data"

Notebook dc_data tabs={200,280}

Notebook dc_data text = "Cell\t" + gCell_ID+"\r"
Notebook dc_data text = "Trace\t" + FileName+"\r"
Notebook dc_data text = "Genotype\t" +gGenotype+"\r"
Notebook dc_data text = "E_rev\t" +num2str(gErev)+"\r"
Notebook dc_data text = "gi_fraction\t" +num2str(ggi_fraction)+"\r"
Notebook dc_data text = "ei_ratio\t" +num2str(gei_ratio)+"\r"
Notebook dc_data text = "stim_time\t" +num2str(gStim_time)+"\r"


String decomp_file_save_name = gCustomPath+gCell_ID+"_decomp.txt"
SaveNotebook/O/S=6 dc_data as decomp_file_save_name

end
















































































