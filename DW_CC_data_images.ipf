#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function MeasureforImage()

Setdatafolder root:

SVAR gCellFolderName
SVAR gCustompath

Setdatafolder $gCellFolderName

NVAR/Z gInputResistance
if(!NVAR_Exists( gInputResistance))
Variable/g   gInputResistance = NaN
endif  

NVAR/Z gRMP = gRMP
if(!NVAR_Exists(gRMP))
Variable/g  gRMP = NaN
endif  

NVAR/Z gAP_duration = gAP_duration
if(!NVAR_Exists(gAP_duration))
Variable/g gAP_duration = NaN
endif   


Variable APsVar

NVAR/Z gMaxNoAPs = gMaxNoAPs
if(!NVAR_Exists(gMaxNoAPs))
Variable/g  gMaxNoAPs = NaN
APsVar = 0
else
APsVar = gMaxNoAPs
endif


NVAR/Z gRheobase = gRheobase
if(!NVAR_Exists(gRheobase))
Variable/g  gRheobase = NaN
endif  

SVAR/Z gCell_ID = gCell_ID
if(!SVAR_Exists(gCell_ID))
String/g  gCell_ID = "undefined"
endif

NewNotebook/F=1/N=Image_data as "Image Data"

Notebook Image_data, fstyle=1, text =  gCell_ID+"\r"
Notebook Image_data text = "MR:  " + num2str(round((gInputResistance)/10)*10) +" MOhm\r"
Notebook Image_data text = "RMP:  " + num2str(gRMP) +" mV\r"
Notebook Image_data text = "AP_dur:  " + num2str(round((gAP_duration)*10)/10)+" ms\r"
Notebook Image_data text = "APs:  " + num2str(gMaxNoAPs)+"\r"
Notebook Image_data text = "Rheo:  " + num2str(round(gRheobase)) +" pA\r"

//String SaveFileNameData = gCustomPath+gCell_ID+"_.txt"

//SaveNotebook/O/S=6 Image_data as SaveFileNameData


End






