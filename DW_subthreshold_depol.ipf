#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later


Function subthreshold_depol(rheobase_trace_number)
variable rheobase_trace_number

variable subt_start,subt_end,v_end,v_hump,v_delta_hump,v_hump_loc

variable subthreshold_trace_number = rheobase_trace_number-1
string subt_trace_name = "RecordA"+num2str(subthreshold_trace_number)

Wave subt_trace = $subt_trace_name

Duplicate/O subt_trace, subt_trace_sm
Smooth 100, subt_trace_sm

subt_start = K_start_step_AP_time+5
subt_end =  K_end_step_AP_time-5

Wavestats/Q/R=(subt_start,subt_start+200) subt_trace
v_hump = V_max
v_hump_loc = V_maxloc

WaveStats/Q/R=(subt_end-100,subt_end) subt_trace
v_end = V_avg

v_delta_hump = v_hump - v_end

Display/N=sub_hump subt_trace

DoUpdate/W=H_Current_trace
GetAxis/W=H_Current_trace left
variable YAxisMin = V_min
variable YAxisMax = V_max


SetDrawEnv xcoord=bottom,ycoord=left,dash=3,linepat=4
DrawLine/W=sub_hump subt_start, v_end, subt_end, v_end

SetDrawEnv xcoord=bottom,ycoord=left,dash=3,linepat=4
DrawLine/W=sub_hump subt_start, YAxisMin, subt_start, YAxisMax

SetDrawEnv xcoord=bottom,ycoord=left,dash=3,linepat=4
DrawLine/W=sub_hump subt_end, YAxisMin, subt_end,YAxisMax


SetDrawEnv xcoord=bottom,ycoord=left,dash=3,linepat=4
DrawLine/W=sub_hump v_hump_loc, v_hump, v_hump_loc,v_end

TextBox/W=sub_hump/C/N=text1/F=0/A=MC "subthreshold depoloarization = "+num2str(round(v_delta_hump))+" mV"

DoUpdate/W=H_Current_trace


End