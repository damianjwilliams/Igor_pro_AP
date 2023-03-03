#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function DIV_calculate(PlateDate)

String PlateDate

SVAR gCellFolderName = root:gCellFolderName

SetDataFolder $(gCellFolderName)

SVAR gDate



Variable PlateYear, PlateMonth, PlateDay,ExpYear, ExpMonth, ExpDay
Variable  PlateSecs, ExpSecs, DIV

sscanf PlateDate, "%d-%d-%d", PlateYear, PlateMonth, PlateDay

ExpDay = str2num(gDate[4,5])
ExpMonth = str2num(gDate[2,3])
ExpYear= str2num("20"+gDate[0,1])



PlateSecs = Date2secs(PlateYear, PlateMonth, PlateDay)
ExpSecs = Date2secs(ExpYear, ExpMonth, ExpDay)

DIV = (ExpSecs-PlateSecs)/(24*60*60)

print "DIV"+num2str(DIV)


Variable/g root:gDIV = DIV

End


