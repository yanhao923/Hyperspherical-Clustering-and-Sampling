# Source code of paper: Hyperspherical Clustering and Sampling for Rare Event Analysis with Multiple Failure Region Coverage
## algorithms
the package implements algorithms outlines in ["Hyperspherical Clustering and Sampling for Rare Event Analysis with Multiple Failure Region Coverage"](http://eda.ee.ucla.edu/pub/C164.pdf)
1. Importance Sampling: 
Different from traditional monte carlo, IS constructs a new “proposed” sampling distribution under which a rare event becomes less rare so more failures can be captured.
2. Hyperspherical K-means: 
A way to partition failure areas from aspect of angles.
## Components
HSCS(folder name)
-   ---circuits (store circuit netlist named as "xxx.sp")
-   ---HspictToolbox (connect MATLAB and HSPICE)
-   ---utility (store function)
-    getMeanSigma.m (provide process variation)
-    HSCS.m (algorithm)
-    runSimulation.m (select the corresponding circuit and run it)
    
## How to run HSCS?
- Step1. Install HSPICE and MATLAB.
- Step2. Open HSCS.m and Configure software location according to the notes in HSCS.m
- Step3. Choose the netlist file with ".sp" as suffix in folder named "circuit" and config it in HSCS.m according to notes.
- Step4. Running HSCS.m and wait for final results named "pfail" and "p_fail_total".
## see also
http://eda.ee.ucla.edu/wei/pub/ispd16_spkmeans_slides.pdf
