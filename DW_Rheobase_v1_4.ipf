


Function RheobasePlot()




Setdatafolder root:

SVAR gCellFolderName

Setdatafolder $(gCellFolderName)

NVAR ScaleVolt = root:gScaleVolt
NVAR ScaleCurr = root:gScaleCurr



Setdatafolder ActionPotential



Variable j = 0
Variable RheobaseValue


Wave NumberAPs
Wave ComCurrValues


Display/N=Rheobasegraph



NVAR Num_traces = NumWaves


Do

string TrcPotNm = "RecordA" +num2str(j)
Wave TracePot = $TrcPotNm
string TrcCmdCurrNm = "RecordB" +num2str(j)
Wave TraceCmdCurr = $TrcCmdCurrNm




if (NumberAPs[j] >=1)

Appendtograph/W=Rheobasegraph, $TrcPotNm
ModifyGraph/W=Rheobasegraph rgb($TrcPotNm)=(65000,0,0)
RheobaseValue = ComCurrValues[j]

Setdatafolder $(gCellFolderName)

variable/g gRheobase = RheobaseValue

Setdatafolder ActionPotential


break

endif


Appendtograph/W=Rheobasegraph $TrcPotNm
ModifyGraph/W=Rheobasegraph rgb($TrcPotNm)=(0,0,0)

j+=1

while (j<Num_traces)



SetAxis/W=Rheobasegraph left -80,70
Label/W=Rheobasegraph Left "Membrane Potential (mV)"
Label/W=Rheobasegraph bottom "Time (ms)"
TextBox/W=Rheobasegraph/C/N=text1/F=0/A=MT "Rheobase = "+num2str(round(RheobaseValue))+" pA"


Datatable()

end