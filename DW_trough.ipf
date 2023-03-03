#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later


function trough(gCellFolderName)
string gCellFolderName

//get threshold
DFREF currDF = getdataFolderDFR()
setDataFolder $gCellFolderName
NVAR gAP_threshold

setDatafolder currDF

Wave  NumberAPs
String trace_wave_nm
variable ap_trough, ap_fast_trough, ap_slow_trough
Findlevel/EDGE=1/P NumberAPs,1
variable cross_val = ceil(V_LevelX)

trace_wave_nm = "RecordA"+num2str(cross_val)
wave trace_wave = $trace_wave_nm


string ap_times_wave = trace_wave_nm+"_AP_times"
Wave AP_times = $ap_times_wave


variable ap_trough_time_start,ap_trough_time_end,ap_fast_trough_time_end,ap_fast_trough_time_start
variable ap_slow_trough_time_start,ap_slow_trough_time_end
variable ap_trough_val, ap_fast_trough_val, ap_slow_trough_val

Wavestats/R=(AP_times[0],AP_times[0]+3) trace_wave

variable AP_peak_time = V_maxloc
print("AP peak time: "+num2str(AP_peak_time))

if(numpnts(AP_times)==1)
ap_trough_time_start = AP_peak_time
ap_trough_time_end = K_end_step_AP_time
ap_fast_trough_time_start = AP_peak_time
ap_fast_trough_time_end = AP_peak_time + 5
ap_slow_trough_time_start = AP_peak_time + 5
ap_slow_trough_time_end = K_end_step_AP_time
else
ap_trough_time_start = AP_peak_time
ap_trough_time_end = AP_times[1]
ap_fast_trough_time_start = AP_peak_time
ap_fast_trough_time_end = AP_peak_time + 5
ap_slow_trough_time_start = AP_peak_time + 5
ap_slow_trough_time_end = AP_times[1]
endif

//complete trough

print("****")
Wavestats/R=(ap_trough_time_start,ap_trough_time_end) trace_wave
ap_trough_val = V_min
variable ap_trough_val_loc = V_minloc
print("****")

//fast trough
Wavestats/R=(ap_fast_trough_time_start,ap_fast_trough_time_end) trace_wave
ap_fast_trough_val = V_min
variable ap_fast_trough_val_loc = V_minloc
print("****")

//slow trough
Wavestats/R=(ap_slow_trough_time_start,ap_slow_trough_time_end) trace_wave
ap_slow_trough_val = V_min
variable ap_slow_trough_val_loc = V_minloc
print("****")

Display/N=troughs $trace_wave_nm

//x0, y0, x1, y1
//all trough value
SetDrawEnv xcoord= bottom,ycoord= left,dash=2,linethick=1,linefgc=(0,65535,0)
DrawLine/W=troughs ap_trough_val_loc,ap_trough_val,ap_trough_val_loc,gAP_threshold

//fast trough value
SetDrawEnv xcoord= bottom,ycoord= left,dash=2,linethick=1,linefgc=(0,65535,0)
DrawLine/W=troughs ap_fast_trough_val_loc,ap_fast_trough_val,ap_fast_trough_val_loc,gAP_threshold

//slow trough value
SetDrawEnv xcoord= bottom,ycoord= left,dash=2,linethick=1,linefgc=(0,65535,0)
DrawLine/W=troughs ap_slow_trough_val_loc,ap_slow_trough_val,ap_slow_trough_val_loc,gAP_threshold


//Trough baseline
SetDrawEnv xcoord= bottom,ycoord= left,dash=2,linethick=1
DrawLine/W=troughs AP_peak_time,gAP_threshold,ap_trough_time_end,gAP_threshold

wavestats/Q trace_wave

//all trough area
SetDrawEnv xcoord= bottom,ycoord= left,dash=3,linethick=1
DrawLine/W=troughs ap_trough_time_start,V_max,ap_trough_time_start,V_min

//fast trough area start
SetDrawEnv xcoord= bottom,ycoord= left,dash=3,linethick=1
DrawLine/W=troughs ap_fast_trough_time_start,V_max,ap_fast_trough_time_start,V_min

//fast trough end
SetDrawEnv xcoord= bottom,ycoord= left,dash=3,linethick=1
DrawLine/W=troughs ap_fast_trough_time_end,V_max,ap_fast_trough_time_end,V_min

//slow trough end
SetDrawEnv xcoord= bottom,ycoord= left,dash=3,linethick=1
DrawLine/W=troughs ap_slow_trough_time_end,V_max,ap_slow_trough_time_end,V_min


Tag/W=troughs/N=text0/F=0/B=1/A=RT $trace_wave_nm, ap_slow_trough_val_loc, "slow"
Tag/W=troughs/N=text1/F=0/B=1/A=LT $trace_wave_nm, ap_trough_val_loc, "all"
Tag/W=troughs/N=text2/F=0/B=1/A=LT $trace_wave_nm, ap_fast_trough_val_loc, "fast"


ModifyGraph/W=troughs/Z gfRelSize=6

Label left "Voltage (mV)"
Label bottom "Time (ms)"
TextBox/W=troughs/C/N=text3/F=0/A=MT "Trough calculations"

DFREF currDF
currDF = getdataFolderDFR()

SetDataFolder  $(gCellFolderName)
variable/g gap_trough_val = ap_trough_val
variable/g gap_fast_trough_val = ap_fast_trough_val
variable/g gap_slow_trough_val = ap_slow_trough_val

setDataFolder CurrDF


end