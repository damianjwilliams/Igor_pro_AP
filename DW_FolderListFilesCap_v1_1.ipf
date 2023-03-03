
//2018-05-04 change if to ifelse ti stop flow control error
//2018-05-29 Change Capacitance measurement function 




Function CreateCellFolder()


setdatafolder root:

SVAR S_path =  gCapFolderPath

//GetFileFolderInfo/D
//print S_path
//NewPath/O pathName S_path



Variable NumFolders, LastFolder,CellFolderNum,DateFolderNum

String StringRMP, expr, CellFolder, DateFolder, Dish, CellType, Cell, ExpDate, CellFolderName,LabelID


//Set position in file path of Cell/Date info for parsing
NumFolders = ItemsInList(S_path,":")
CellFolderNum = Numfolders-1
DateFolderNum = Numfolders-2

CellFolder = (StringFromList(CellFolderNum, S_path,":"))
DateFolder =  (StringFromList(DateFolderNum,S_path,":"))

expr = "([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([+-]?[\d+]+)"
SplitString /E=expr CellFolder, Dish, Cell,CellType, LabelID,StringRMP


//expr = "([\w]+)_([\w]+)-([[:graph:]]+)_([\w]+)_([+-]?[\d+]+)"

//SplitString /E=expr CellFolder, Dish, CellType, LabelID, Cell, StringRMP

CellFolderName = "Cell_"+DateFolder+"_"+Dish+"_"+Cell

NewDataFolder/O/S $CellFolderName

String/g root:gCellFolderName = GetDataFolder(1)

String/g gDish = Dish
String/g gCell = Cell
String/g gCellType = CellType
String/g gLabelID = LabelID
String/g gDate = DateFolder
Variable/g gRMP = str2num(StringRMP)

//GetFileFolder()

String/g CellFolderFilePath = S_path
String/g gCell_ID = DateFolder+"_"+Dish+"_"+Cell


End


Function CapFileName()

//String CellFolderFilePath

String FileList,TempStaName,StaFileNam,StaFileNameSemi

SVAR gCellFolderName= root:gCellFolderName

SetDatafolder $(gCellFolderName)

SVAR CellFolderFilePath

NewPath/O CellFolderFilePathNm, CellFolderFilePath



FileList = IndexedFile(CellFolderFilePathNm, -1, "????")


StaFileNameSemi =GrepList(FileList,".*\.sta" )

TempStaName = StaFileNameSemi[0,(strlen(StaFileNameSemi))-2]

print (TempStaName)


String/g StaFileName= TempStaName

End



Function MeasureCapacitance()

setdatafolder root:

SVAR gCellFolderName

setdatafolder $(gCellFolderName)

DFREF saveDFR = GetDataFolderDFR()

SVAR StaFileName
SVAR CellFolderFilePath

String CapPath =  CellFolderFilePath+StaFileName

NewDataFolder/O/S RawCapWaves

LoadWave/G/A/W/Q CapPath

Wave Memb_Test_0_Memb_Test_Rm__MOhm_
Wavestats/Q Memb_Test_0_Memb_Test_Rm__MOhm_
Variable/g saveDFR:gVCRMem = V_avg

Wave Memb_Test_0_Memb_Test_Cm__pF_
Wavestats/Q Memb_Test_0_Memb_Test_Cm__pF_
Variable/g saveDFR:gVCCap = V_avg

Wave Memb_Test_0_Memb_Test_Holding__
Wavestats/Q Memb_Test_0_Memb_Test_Holding__
Variable/g saveDFR:gLeakCurrent = V_avg

end









