
#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later




Constant K_t_after_stim_pp = 1.5
Constant K_measurement_period_pp = 20




Function check_PP_folder()

string folder_list = IndexedDir(pathname_for_pp, 0,0)



if(stringmatch(folder_list,"PP")==1)

Setdatafolder root:
SVAR  gCellFolderName
Setdatafolder $(gCellFolderName)
variable/g pp_files_present = 1
newdataFolder/O/S paired_pulse

make/N=0 pp_freq_a,pp_ratio_a

Create_PP_file_list()
 
 
endif


End



//Get PP file list

Function Create_PP_file_list()

String List_of_files,Current_file,Current_file_path,PP_files,Decomp_file,Other_files,Membrane_test_files
variable i,Num_files,refNum
String Single_stim_files

pathInfo pathname_for_pp 
string path_name_first_bit = S_path 
string full_pp_path_name = path_name_first_bit+"PP"
newpath/O full_pp_folder_path full_pp_path_name



List_of_files = IndexedFile(full_pp_folder_path,-1,".abf")
Num_files = ItemsInList (List_of_files)

PP_files = ""
Other_files = ""
Membrane_test_files = ""
Single_stim_files = ""

print("****")
i = 0
do

	Current_file = StringFromList(i,List_of_files)
	Current_file_path = S_path+Current_file
	//print(Current_file_path)
	Open/P=full_pp_folder_path/R refNum as Current_file
	FStatus refNum
	print(Current_file)
	print((round(V_logEOF/1000))*1000)
	
	if((round(V_logEOF/1000)*1000)==7.4e5)
	
		print("PP A")
		PP_files = AddListItem(Current_file, PP_files)
		
	elseif((round(V_logEOF/1000)*1000)==1.46e+06)
		print("PP B")
		PP_files = AddListItem(Current_file, PP_files)
		
	elseif((round(V_logEOF/1000)*1000)==1.1e+06)
		print("PP C")
		PP_files = AddListItem(Current_file, PP_files)
	
	elseif((round(V_logEOF/1000)*1000)==307e+3)
		print("PP D")
		PP_files = AddListItem(Current_file, PP_files)
		
		
	elseif(((round(V_logEOF/1000)*1000)==1.1e5))//|(round(V_logEOF/1000)*1000)==5.6e5)
		print("Single stem")
		Single_stim_files = AddListItem(Current_file, Single_stim_files)
	
	elseif((round(V_logEOF/1000)*1000)==1.447e+06)
		print("Decomposition A")
		Decomp_analysis(Current_file,S_path)
	elseif((round(V_logEOF/1000)*1000)==2.66e+06)
		print("Decomposition B")
		Decomp_analysis(Current_file,S_path)
	elseif((round(V_logEOF/1000)*1000)== 1.127e+06)
		print("Decomposition C")
		Decomp_analysis(Current_file,S_path)
	elseif((round(V_logEOF/1000)*1000)== 4.819e+06)
		print("Decomposition D")
		Decomp_analysis(Current_file,S_path)
		
		
		
	elseif((round(V_logEOF/1000)*1000)==1.76e+05)
		print("Membrane test")
		Membrane_test_files = AddListItem(Current_file,Membrane_test_files)
		
	else	
	
	Other_files = AddListItem(Current_file, Other_files)
	
	
	endif
		
	i++

while(i < Num_files)

print(strlen(PP_files))

if(numtype(strlen(PP_files)))
    abort
 else
  PP_analysis(PP_files,S_path)
  print("yes")
endif


print("PP_test")
print(PP_files)
print("******")


print("membrane_test")
print(Membrane_test_files)
print("******")

print("Single Stim")
print(Single_stim_files)
print("******")

End


//Open and average PP file

Function PP_analysis(List_of_files,Folder_path)

String List_of_files,Folder_path

Variable Num_files,i,idx
string Current_file_path,Current_file,I_trace_name,Stim_trace_name,I_trace_list

String/g gCell_file = ParseFilePath(0, Folder_path, ":", 1, 0)
print(gCell_file)


Num_files = ItemsInList (List_of_files)

i = 0

do

Current_file = StringFromList(i,List_of_files)
Current_file_path = Folder_path+Current_file


NMImportFile( "new" ,Current_file_path)
DoWindow /K ImportPanel
print(Current_file_path)



NVAR Num_traces = NumWaves

I_trace_list = ""

for(idx=0;idx<Num_traces;idx+=1)

	I_trace_name = "RecordA" +num2str(idx)
	Wave I_trace = $I_trace_name

	Stim_trace_name = "RecordC" +num2str(idx)
	Wave Stim_trace = $Stim_trace_name
	
	print(I_trace_name)
	
	if(idx == 0)	
		print("ignore")
		
	else
		
		I_trace_list = AddListItem(I_trace_name, I_trace_list)
		
	endif




print(I_trace_list)	
	
endfor


fWaveAverage(I_trace_list, "", 3, 1, "average_trace", "average_trace_STE")

PP_calcs(Current_file)


i++

while(i < Num_files)



print (Num_files)





setdatafolder root:
PPLayout()


End

Function PPLayout()

Setdatafolder root:

SVAR  gCellFolderName
SVAR gCustomPath

Setdatafolder $(gCellFolderName)
SVAR gCell_ID



NewLayout/k=1/N=AutoPP
String ListofWindows = WinList("PP*",";","WIN:1")
ListofWindows = sortlist(ListofWindows)

variable i

for(i=0;i<itemsinlist(ListofWindows);i+=1)

	String CurrentPPPlot = Stringfromlist(i,ListofWindows)
	print CurrentPPPlot
	Appendlayoutobject/W=AutoPP graph $CurrentPPPlot
	Execute("Tile/O=0")

endfor

String SaveFileNameData = gCustomPath+gCell_ID+"_PP.pdf"
SavePict/E=-8/O/WIN=AutoPP as SaveFileNameData

End


//PP file analysis


Function PP_calcs(Current_file)

String Current_file



Wave average_trace, average_trace_STE,RecordC0,W_FindLevels
Variable xmin,xmax,ymin,ymax
variable Time_after_stim, Total_duration
variable stim_time_1,stim_time_2,PP_measurement_start_1,PP_measurement_end_1,PP_measurement_start_2,PP_measurement_end_2
variable Frequency, Max_amp_1, Max_amp_2,PP_ratio,Peak_location_1,Peak_location_2


DFREF curr_df = getDataFolderDFR()

setdataFolder root:
SVAR  gCellFolderName
Setdatafolder $(gCellFolderName)
Setdatafolder paired_pulse

Wave pp_ratio_a
Wave pp_freq_a
setDataFolder curr_df

Variable number_of_points = numpnts(average_trace)


Wavestats/Q RecordC0
Make/O/D/N=0 Crossings
FindLevels/EDGE=1/D=Crossings RecordC0, V_max/2

Display/N=trace_se/W=(48,66,601,394) average_trace

GetAxis/W=trace_se Left; ymin = V_min
GetAxis/W=trace_se Left; ymin = V_min
GetAxis/W=trace_se Bottom; xmax = V_max
GetAxis/W=trace_se Bottom; xmin = V_min

ErrorBars/W=trace_se average_trace SHADE= {0,0,(34952,34952,34952),(0,0,0,0)},wave=(average_trace_STE,average_trace_STE)


ModifyGraph/W=trace_se axisEnab(left)={0.2,0.9}
AppendToGraph/W=trace_se/L=left2/B=bottom2 RecordC0
ModifyGraph/W=trace_se axisEnab(left2)={0,0.15},freePos(left2)=0,freePos(bottom2)={0,left2}
ModifyGraph noLabel(left2)=2,axThick(left2)=0,lSize=0.3,axThick=0.3
ModifyGraph noLabel(bottom2)=2,axThick(bottom2)=0



//Paired_pulse_analysis



Time_after_stim = K_t_after_stim_pp
Total_duration = K_measurement_period_pp

stim_time_1 = Crossings[0]
stim_time_2 = Crossings[1]

Frequency = 1000/(Crossings[1]-Crossings[0])

print(Frequency)

print(stim_time_1)
print(stim_time_2)

//Stim region
PP_measurement_start_1 = stim_time_1 + Time_after_stim
PP_measurement_end_1 = PP_measurement_start_1 + Total_duration
PP_measurement_start_2 = stim_time_2 + Time_after_stim
PP_measurement_end_2 = PP_measurement_start_2 + Total_duration

//Measurements 

WaveStats/Q/R=(PP_measurement_start_1,PP_measurement_end_1) average_trace

Max_amp_1 = V_min
Peak_location_1 = V_minloc

WaveStats/Q/R=(PP_measurement_start_2,PP_measurement_end_2) average_trace

Max_amp_2 = V_min
Peak_location_2 = V_minloc

PP_ratio = Max_amp_2/Max_amp_1

print("Max amp 1:" + num2str(Max_amp_1) +" Max amp 2:"+ num2str(Max_amp_2)+" PP ratio:"+ num2str(PP_ratio))


//Region measurement 1 
SetDrawEnv/W=trace_se xcoord= bottom,ycoord= left
SetDrawEnv/W=trace_se dash = 3
DrawLine/W=trace_se PP_measurement_start_1,ymin, PP_measurement_start_1,ymax

SetDrawEnv/W=trace_se xcoord= bottom,ycoord= left
SetDrawEnv/W=trace_se dash = 3
DrawLine/W=trace_se PP_measurement_end_1,ymin, PP_measurement_end_1,ymax


//Region measurement 2
SetDrawEnv/W=trace_se xcoord= bottom,ycoord= left
SetDrawEnv/W=trace_se dash = 3
DrawLine/W=trace_se PP_measurement_start_2,ymin, PP_measurement_start_2,ymax

SetDrawEnv/W=trace_se xcoord= bottom,ycoord= left
SetDrawEnv/W=trace_se dash = 3
DrawLine/W=trace_se PP_measurement_end_2,ymin, PP_measurement_end_2,ymax


//Peak 1
SetDrawEnv/W=trace_se xcoord= bottom,ycoord= left
SetDrawEnv/W=trace_se dash = 2
DrawLine/W=trace_se (Peak_location_1-50),Max_amp_1, Peak_location_1, Max_amp_1


//Peak 2
SetDrawEnv/W=trace_se xcoord= bottom,ycoord= left
SetDrawEnv/W=trace_se dash = 2
DrawLine/W=trace_se (Peak_location_1-50),Max_amp_2, Peak_location_2, Max_amp_2

//SetAxis/W=trace_se left (Peak_location_1-50),(Peak_location_2+75)
ModifyGraph/W=trace_se expand = 0.8


SetAxis/W=trace_se bottom (Peak_location_1-50),(Peak_location_2+75)
SetAxis/W=trace_se bottom2 (Peak_location_1-50),(Peak_location_2+75)

//Set Y axis for PP

variable y_max_plot = abs(Max_amp_2)*1.5
variable y_min_plot = abs(Max_amp_2)*-1.5


SetAxis/W=trace_se left y_min_plot,y_max_plot


Variable Rounded_freq = round(Frequency)

String File_no_ext = RemoveEnding(current_file, ".abf")
String New_plot_name = "PP_freq_"+num2str(Rounded_freq)+"_"+File_no_ext

RenameWindow trace_se, $New_plot_name

TextBox/W=$New_plot_name/C/N=text0/A=RB/X=10/Y=10 "Trace ID: "+Current_file+"\nPP Frequency: "+num2str(Rounded_freq)+"\nPP ratio: "+num2str(PP_ratio)



InsertPoints inf,1, pp_freq_a
				pp_freq_a[inf] =  Rounded_freq
				
InsertPoints inf,1, pp_ratio_a
				pp_ratio_a[inf] =  PP_ratio
				





End


































