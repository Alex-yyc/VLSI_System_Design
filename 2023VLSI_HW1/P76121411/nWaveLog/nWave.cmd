wvSetPosition -win $_nWave1 {("G1" 0)}
wvOpenFile -win $_nWave1 \
           {/home/YanYouChen/VLSI_final/2023VLSI_HW1/P76121411/build/top.fsdb}
wvResizeWindow -win $_nWave1 1920 23 1920 1137
wvSelectGroup -win $_nWave1 {G1}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/top_tb"
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/top_tb/TOP"
wvGetSignalSetScope -win $_nWave1 "/top_tb/TOP/BranchCtrl"
wvGetSignalSetScope -win $_nWave1 "/top_tb/TOP/EXE"
wvGetSignalSetScope -win $_nWave1 "/top_tb/TOP/DM1"
wvGetSignalSetScope -win $_nWave1 "/top_tb/TOP/EXE"
wvGetSignalSetScope -win $_nWave1 "/top_tb/TOP/DM1"
wvGetSignalSetScope -win $_nWave1 "/top_tb/TOP/HazardCtrl"
wvGetSignalSetScope -win $_nWave1 "/top_tb/TOP/Forwarding_Unit"
wvGetSignalSetScope -win $_nWave1 "/top_tb/TOP/IFE"
wvGetSignalSetScope -win $_nWave1 "/top_tb/TOP/ID"
wvGetSignalSetScope -win $_nWave1 "/top_tb/TOP/ID/ImmGenernator"
wvGetSignalSetScope -win $_nWave1 "/top_tb/TOP/WB"
wvSetPosition -win $_nWave1 {("G3" 3)}
wvSetPosition -win $_nWave1 {("G3" 3)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/top_tb/TOP/clk} \
{/top_tb/TOP/rst} \
{/top_tb/TOP/ID_PC_out\[31:0\]} \
{/top_tb/TOP/EXE/wire_PC_4\[31:0\]} \
{/top_tb/TOP/EXE/wire_PC_imm\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
{/top_tb/TOP/ID/ImmGenernator/Imm_Type\[2:0\]} \
{/top_tb/TOP/ID/ImmGenernator/Instraction_out\[31:0\]} \
{/top_tb/TOP/ID/ImmGenernator/imm\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G3" \
{/top_tb/TOP/WB/WB_RegWrite} \
{/top_tb/TOP/WB/WB_rd_addr\[4:0\]} \
{/top_tb/TOP/WB/WB_rd_data\[31:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G4" \
}
wvSelectSignal -win $_nWave1 {( "G3" 3 )} 
wvSetPosition -win $_nWave1 {("G3" 3)}
wvGetSignalClose -win $_nWave1
wvSetCursor -win $_nWave1 676958.156219 -snap {("G4" 0)}
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 4 )} 
wvSelectSignal -win $_nWave1 {( "G1" 3 )} 
wvSelectSignal -win $_nWave1 {( "G1" 4 )} 
wvSelectSignal -win $_nWave1 {( "G1" 5 )} 
wvSelectSignal -win $_nWave1 {( "G1" 4 )} 
wvSelectSignal -win $_nWave1 {( "G1" 3 )} 
wvSelectSignal -win $_nWave1 {( "G1" 4 )} 
wvSelectSignal -win $_nWave1 {( "G1" 5 )} 
wvSelectSignal -win $_nWave1 {( "G1" 4 )} 
wvSelectSignal -win $_nWave1 {( "G1" 3 )} 
wvSelectSignal -win $_nWave1 {( "G1" 4 )} 
wvSelectSignal -win $_nWave1 {( "G1" 5 )} 
wvSelectSignal -win $_nWave1 {( "G1" 4 )} 
wvSelectSignal -win $_nWave1 {( "G1" 3 )} 
wvSearchNext -win $_nWave1
wvSearchNext -win $_nWave1
wvSearchNext -win $_nWave1
wvSearchNext -win $_nWave1
wvSearchNext -win $_nWave1
wvSearchNext -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 3 )} 
wvSetSearchMode -win $_nWave1 -value "bb4" -case off -skipGlitch off -X2Y off
wvSelectSignal -win $_nWave1 {( "G1" 3 )} 
wvSearchNext -win $_nWave1
wvSetSearchMode -win $_nWave1 -value "bb4" -case off -skipGlitch off -X2Y off
wvSelectSignal -win $_nWave1 {( "G1" 3 )} 
wvSearchPrev -win $_nWave1
wvSetCursor -win $_nWave1 10264507.127771 -snap {("G4" 0)}
wvSetCursor -win $_nWave1 10260305.118668 -snap {("G3" 1)}
wvSetCursor -win $_nWave1 10258030.237877 -snap {("G3" 1)}
wvZoomOut -win $_nWave1
wvExit
