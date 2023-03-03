#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include <FilterDialog> menus=0

Function DIV_calc(PlateDate,CellIdent)
// Calculate DIV

String PlateDate
String CellIdent

variable PlateDay = str2num(PlateDate[8,9])
variable PlateMonth = str2num(PlateDate[5,6])
variable PlateYear= str2num(PlateDate[0,3])
variable RecDay = str2num(cellIdent[4,5])
variable RecMonth = str2num(cellIdent[2,3])
variable RecYear= str2num("20"+cellIdent[0,1])

variable DIV = (date2secs(RecYear, RecMonth, RecDay) -  date2secs(PlateYear, PlateMonth, PlateDay))/(24*60*60)

print (DIV)

variable/g root:gDIV = DIV


end