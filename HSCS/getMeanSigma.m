function [mean_vals, sigma_vals] = getMeanSigma(analysis)

    circuitName = analysis.circuitName;
    circuitPath = analysis.circuitPath;
    if(strcmp(circuitName,'TwoStageAmplifier'))
        cd(circuitPath);
        getMeanSigma;
        cd(analysis.path);
    elseif(strcmp(circuitName,'sram6Tcell'))
        cd(circuitPath);
        getMeanSigma;
        cd(analysis.path);
    elseif(strcmp(circuitName,'sa'))
        cd(circuitPath);
        getMeanSigma;
        cd(analysis.path);
    elseif(strcmp(circuitName,'Copy_of_TwoStageAmplifier'))
        cd(circuitPath);
        getMeanSigma;
        cd(analysis.path);
    elseif(strcmp(circuitName,'vco'))
        cd(circuitPath);
        getMeanSigma;
        cd(analysis.path);
    elseif(strcmp(circuitName,'cp22nm70d'))
        cd(circuitPath);
        getMeanSigma;
    cd(analysis.path);   
    else
        disp('Illegal input parameter: circuitName');
    end

end