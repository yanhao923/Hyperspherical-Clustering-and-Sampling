
*.pplus_opt hslvl=conservative
.param SUPPLY=0.8
.param VPLUS=0.8
*.param voff_pd1=-1.788711e-001 vth0_pd1=3.587042e-001 
*+ub_pd1=+1.956014e-018 voff_pd2=-1.489100e-001 vth0_pd2=3.574214e-001 
*+ub_pd2=+1.937519e-018
*+voff_wl1= -1.795349e-001 vth0_wl1=3.338367e-001 ub_wl1= 1.093842e-018 *+voff_wl2=-1.896948e-001  vth0_wl2=3.165394e-001  ub_wl2=1.107512e-018
*+voff_pu1=-1.421330e-001 vth0_pu1=-2.984468e-001 ub_pu1=4.572198e-020 *+voff_pu2=-1.419418e-001 vth0_pu2=-2.938549e-001 ub_pu2=-9.696841e-021




***********************SETTING*******************************
*.param tsim=5n
*.tran 10p tsim SWEEP DATA=data
.OPTIONS accurate post=1 converge=1
*.op
*.protect
*.include "./l0040ll_242_sram_v1p4.lib" TT
*.lib './l0040ll_242_sram_v1p4.lib' TT
.include "./sweep_data_mc"
*.include "./l0040ll_242_sram_v1p4.mdl"
*.unprotect
************************END**********************************

.SUBCKT B6T BL VDDA BLB WL VSS Q QB
x1 VSS QB Q VSS dslnfetpd_ckt1 w=0.142u l=0.055u 
x2 VSS Q QB VSS dslnfetpd_ckt2 w=0.142u l=0.055u 
x3 BL WL Q VSS dslnfetwl_ckt1 w=0.110u l=0.059u 
x4 BLB WL QB VSS dslnfetwl_ckt2 w=0.110u l=0.059u 
x5 VDDA QB Q VDDA dslpfetpu_ckt1 w=0.060u l=0.055u 
x6 QB Q VDDA VDDA dslpfetpu_ckt2 w=0.060u l=0.055u 
.ENDS B6T

*.SUBCKT NOR2 VDD VSS VOUT A B
*Xp1 N B VDD VDD plvt11ll_ckt w=500n l=40n
*Xp2 OUT A N VDD plvt11ll_ckt w=500n l=40n
*Xn1 OUT A VSS VSS nlvt11ll_ckt w=120n l=40n
*Xn2 OUT B VSS VSS nlvt11ll_ckt w=120n l=40n
*.ENDS NOR2

*.SUBCKT ReadPath VDD VSS BL WL Q RB GBL BLB QB VDDH
XT1 BL VDDH BLB WL VSS Q QB B6T
*XT2 VDD VSS RB BL VSS NOR2
*Xn1 GBL RB VSS VSS nlvt11ll_ckt w=1u l=40n
*.ENDS ReadPath


*x1 VDD VSS BL WL Q RB GBL BLB QB VDDH ReadPath
*vVDD VDD 0 SUPPLY
vVDDH VDDH 0 VPLUS
vVSS VSS 0 0

*Crb RB 0 3.4f
Clbl BL 0 50f
Clblb BLB 0 50f
*Cgbl GBL 0 31f

*Vwl wl 0 pwl(0 0 300p 0.814 3.77n 0.814 4.07n 0)

Vwl WL 0 pwl(0 0 20p SUPPLY)
*.tran 10p 50n sweep SUPPLY 0.5 1.1 0.1

.lib './smic40ll/l0040ll_242_sram_v1p4.lib' tt

.ic v(BL)=SUPPLY v(BLB)=SUPPLY v(Q)=0 v(QB)=VPLUS
.probe v(*) 
.temp 25

.tran 10p 100n SWEEP DATA=data

*.tran 10p 3000n

*.probe v(*) 
  
*.lib l0040ll_v1p4_1r.lib' tt
*.lib './l0040ll_242_sram_v1p4.lib' tt

*.meas Tread trig v(wl) val='SUPPLY/2' rise=1 targ v(BL) val=1 fall=1
.meas Tread trig v(wl) val='SUPPLY/2' rise=1 targ v(BL) val='SUPPLY-0.15' fall=1
.meas tran ratio param='1/ Tread'
.option post=2
.end


  



