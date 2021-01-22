function [output] = runSimulation(sample, num, analysis)

global simulationNum;
simulationNum = simulationNum + num;
circuitName = analysis.circuitName;
circuitPath = analysis.circuitPath;
hspicepath  = analysis.hspicepath;

if(strcmp(circuitName,'TwoStageAmplifier'))
    cd(circuitPath);
    output = run(sample, num, hspicepath);
    cd(analysis.path);
elseif(strcmp(circuitName,'Copy_of_TwoStageAmplifier'))
    cd(circuitPath);
    output = run(sample, num, hspicepath);
    cd(analysis.path);
elseif(strcmp(circuitName,'vco'))
    cd(circuitPath);
    output = run_hspice(sample, num, hspicepath);
    cd(analysis.path);
elseif(strcmp(circuitName,'cp22nm70d'))
    cd(circuitPath);
    output = run(sample, num, hspicepath);
    cd(analysis.path); 
elseif(strcmp(circuitName,'sram6Tcell'))
    cd(circuitPath);
    output = run(sample, num, hspicepath);
    cd(analysis.path);
else
    disp('Illegal input parameter: circuitName');
end

end