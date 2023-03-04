//#pragma TextEncoding = "UTF-8"
//#pragma rtGlobals=3		// Use modern global access method and strict wave access.


constant K_double_dif =  1




Function Abf_files_in_folder()

setdataFolder root:

//Create Tables

Make/O/N=0 APThresholdTbl
Make/O/N=0 APMaxRateMSTbl
Make/O/N=0 double_diff_peak_oneTbl
Make/O/N=0 double_diff_peak_twoTbl
Make/O/N=0 peak_ratioTbl
Make/O/N=0 double_diff_latencyTbl
Make/O/N=0 max_sec_difTbl


End


Function double_plot(TrcPotNm)

String TrcPotNm
String Smoothed_trace_name = TrcPotNm+"_sm"
String Diff_smoothed_trace_name = TrcPotNm+"_sm_dif"
Wave AP_times_df
Variable k
Make/N=0 AP_points

Variable Number_of_APs

DFREF diff_folder = GetdataFolderDFR()

Setdatafolder root:
SVAR gCellFolderName = root:gCellFolderName
DFREF CellFolderDFR = $gCellFolderName
setdataFolder diff_folder


//Differentiate
variable max_x = numpnts($TrcPotNm)*deltax($TrcPotNm)
print(max_x)
variable sample_freq = deltax($TrcPotNm)
Duplicate/O $TrcPotNm, $Smoothed_trace_name
print(deltax($TrcPotNm))
	if(deltax($TrcPotNm)==0.002)
		
		FilterFIR/LO={0.015,0.016,101}/WINF=KaiserBessel20 $Smoothed_trace_name
	else
		FilterFIR/LO={0.2,0.3,101}/WINF=KaiserBessel20 $Smoothed_trace_name
	
	endif


Differentiate $Smoothed_trace_name/D = $Diff_smoothed_trace_name
FindLevels/EDGE=1/Q/R=(K_start_step_AP_time,K_end_step_AP_time)/DEST=AP_times_df/M=2 $Diff_smoothed_trace_name, 5

print("levels_found" + num2str(V_LevelsFound))


Variable APStartA,APEndA,AP_VmaxA
variable yes_double_hump
variable first_AP = 0

yes_double_hump = 0 



if(V_LevelsFound>0)		

		For(k=0;k<numpnts(AP_times_df);k+=1)
		
		//AP start times

			APStartA =(AP_times_df[k])-1
			APEndA = (AP_times_df[k])+4
			
			//Get AP amplitude

			Wavestats/Q/R=(APStartA,APEndA)$TrcPotNm	
			
			APStartA =(AP_times_df[k])-5
			APEndA = (AP_times_df[k])+10
			print("AP start time: "+num2str(APStartA))
			print("AP end time: "+num2str(APEndA))
			print("Max amplitude: "+num2str(V_max))

			AP_VmaxA = V_max

			if(V_max>0)
				InsertPoints inf,1, AP_points
				AP_points[inf] =  AP_times_df[k]							
				
				if(first_AP ==0)
				
					APStartA =(AP_times_df[k])-4
					APEndA = (AP_times_df[k])+10					
					
					
					Duplicate/O/R=(APStartA,APEndA) $Smoothed_trace_name AP_region AP_region_filt				
			
					//Differentiate AP					
					Differentiate AP_region/D=AP_region_dif
					Differentiate AP_region_dif/D=AP_region_sec_dif
					
					
					//Differentiate AP	 filter	
					
					
					Duplicate/O/R=(APStartA,APEndA) $Smoothed_trace_name AP_region_filt
					
					Make/O/D/N=0 coefs
					FilterFIR/DIM=0/LO={0.15,0.2,101}/COEF coefs, AP_region_filt					
						
					Differentiate AP_region_filt/D=AP_region_dif_filt
					Differentiate AP_region_dif_filt/D=AP_region_sec_dif_filt
					
					//New filtered 
			
					//Measurements
					//Threshold
			
					//Display AP_region
					FindLevel/EDGE=1/P/Q AP_region_dif, 5
					Variable Vthresholdpoint = V_LevelX
					Variable V_threshold = AP_region[round(V_LevelX)]
					//print(num2str(Vthresholdpoint))
					print("Voltage threshold: "+num2str(V_threshold))
			
					//Amplitude
					Wavestats/Q AP_region
					Variable Amplitude = V_max - V_threshold
					print("AP amplitude: "+num2str(Amplitude))
			
					//Max
					Wavestats/Q AP_region_dif
					Variable Maxdif = V_max
					print("Diff amplitude: "+num2str(Maxdif))					
					
					variable hump_one,hump_two,double_diff_peak_one, double_diff_peak_two,peak_ratio
					variable double_diff_peak_time_one, double_diff_peak_time_two,double_diff_latency							
					
					Display/N=For_dd_check AP_region_sec_dif_filt,AP_region_sec_dif
					DoWindow For_dd_check	
					Label/W=For_dd_check	 left "mV/ms²"
					Label/W=For_dd_check	 bottom "ms"	
					ShowInfo
					WaveStats/Q AP_region_sec_dif
					Variable max_sec_dif = V_max
					ModifyGraph/W=For_dd_check rgb(AP_region_sec_dif_filt)=(0,0,65535,32767)
					ModifyGraph/W=For_dd_check rgb(AP_region_sec_dif)=(65535,0,0,32767)
					
					if(K_run_double_dif == 1)
						
						
						if (UserCursorAdjust(30) != 0)
							return -1
						endif

						if (strlen(CsrWave(A))>0 && strlen(CsrWave(B))>0)	// Cursors are on trace?				
				
							hump_one = pcsr(A)
							hump_two = pcsr(B)
				
							print "-------------------------------------------"
				
							double_diff_peak_one = AP_region_sec_dif[hump_one]
							double_diff_peak_two = AP_region_sec_dif[hump_two]
							peak_ratio = double_diff_peak_one/double_diff_peak_two
				
							print("Peak one amplitude: "+num2str(AP_region_sec_dif[hump_one]))
							print("Peak two amplitude: "+num2str(AP_region_sec_dif[hump_two]))
				
							double_diff_peak_time_one = IndexToScale(AP_region_sec_dif,hump_one,0)
							double_diff_peak_time_two = IndexToScale(AP_region_sec_dif,hump_two,0)
				
							double_diff_latency = double_diff_peak_time_two - double_diff_peak_time_one
							print("Peak one time: "+num2str(double_diff_peak_time_one))
							print("Peak two time: "+num2str(double_diff_peak_time_two))			
							print("Latency: "+num2str(double_diff_latency))
							
							yes_double_hump = 1
							
							
							
							
						else
						
						
							print("**********no cursors on trace*************")
						
							double_diff_peak_one = NaN
							double_diff_peak_two = NaN
							peak_ratio = NaN									
							double_diff_latency = NaN
						endif
					
					
					endif
						
						//DoWindow/K For_dd_check
						
					else
					
					print("******************8getting stuck here************8")
					
						//double_diff_peak_one = NaN
					//	double_diff_peak_two = NaN
					//	peak_ratio = NaN									
					//	double_diff_latency = NaN
					//	max_sec_dif = NaN
					
					
					
					endif
					
					ModifyGraph/W=For_dd_check gfRelSize=5, frameStyle= 0
					
					Variable xmax, xmin
					GetAxis/W=For_dd_check Bottom; xmax = V_max
					GetAxis/W=For_dd_check Bottom; xmin = V_min
					
					//SetAxis/W=For_dd_check bottom (xmin+3),(xmax-3)
					
					if(yes_double_hump == 1)
					
						TextBox/W=For_dd_check/C/N=text0/F=0/A=LT "DD peak one amp: "+num2str(double_diff_peak_one)+"\nDD peak two amp: "+num2str(double_diff_peak_two)+"\nDD ratio: "+num2str(peak_ratio)+"\nDD latency: "+num2str(double_diff_latency)

					
					
						DFREF CurrentDF = GetDataFolderDFR()
					
						setdatafolder CellFolderDFR
					
						Variable/g gdouble_diff_peak_one,gdouble_diff_peak_two,gpeak_ratio,gdouble_diff_latency
					 	gdouble_diff_peak_one = double_diff_peak_one
					 	gdouble_diff_peak_two = double_diff_peak_two
					 	gpeak_ratio = peak_ratio
					 	gdouble_diff_latency = double_diff_latency
					 
					 
						setDataFolder CurrentDF
						
					endif
					
					first_AP =1				
								
				endif				
											
			//endif

		endfor
		
Make/O/N=(numpnts(AP_points)) AP_zero


AP_zero = 1

Number_of_APs = numpnts(AP_points)


endif


if(numpnts(AP_points)>0)

	Number_of_APs = numpnts(AP_points)

else

	Number_of_APs = 0
	V_threshold = NaN
	Amplitude = NaN
	Maxdif = NaN

endif




End









Function UserCursorAdjust(autoAbortSecs)
	
	Variable autoAbortSecs
	Wave AP_region_sec_dif
	
	//Display/N=For_dd_check AP_region_sec_dif

	DoWindow/F For_dd_check					// Bring graph to front
	if (V_Flag == 0)									// Verify that graph exists
		Abort "UserCursorAdjust: No such graph."
		return -1
	endif

	NewPanel /K=2 /W=(187,368,437,531) as "Pause for Cursor"
	DoWindow/C tmp_PauseforCursor					// Set to an unlikely name
	AutoPositionWindow/E/M=1/R=For_dd_check			// Put panel near the graph

	DrawText 21,20,"Adjust the cursors and then"
	DrawText 21,40,"Click Continue."
	Button button0,pos={80,58},size={92,20},title="Continue"
	Button button0,proc=UserCursorAdjust_ContButtonProc
	//Button button1,pos={120,58},size={92,20},title="Ignore"
	//Button button1,proc=UserCursorAdjust_ContButtonProc
	Variable didAbort= 0
	if( autoAbortSecs == 0 )
		PauseForUser tmp_PauseforCursor,For_dd_check
	else
		SetDrawEnv textyjust= 1
		DrawText 162,103,"sec"
		SetVariable sv0,pos={48,97},size={107,15},title="Aborting in "
		SetVariable sv0,limits={-inf,inf,0},value= _NUM:10
		Variable td= 10,newTd
		Variable t0= ticks
		Do
			newTd= autoAbortSecs - round((ticks-t0)/60)
			if( td != newTd )
				td= newTd
				SetVariable sv0,value= _NUM:newTd,win=tmp_PauseforCursor
				if( td <= 10 )
					SetVariable sv0,valueColor= (65535,0,0),win=tmp_PauseforCursor
				endif
			endif
			if( td <= 0 )
				DoWindow/K tmp_PauseforCursor
				didAbort= 1
				break
			endif
				
			PauseForUser/C tmp_PauseforCursor,For_dd_check
		while(V_flag)
	endif
	return didAbort
End

Function UserCursorAdjust_ContButtonProc(ctrlName) : ButtonControl
	String ctrlName

	DoWindow/K tmp_PauseforCursor				// Kill self
End
