function [extra,betaD,sigmaD,yD] = drawMoreFromPosterior(inputs,coeffDraws)
% Syntax:
%
% [extra,betaD,sigmaD,yD] = nb_forecast.drawMoreFromPosterior(inputs,...
%                               coeffDraws)
%
% Description:
%
% Check if there has been done enough posterior draws. If there isn't 
% we draw more.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    yD = [];
    if isfield(coeffDraws,'yD')
        yD        = coeffDraws.yD;
        ySampling = true;
    else
        ySampling = false;
    end
    
    betaD = coeffDraws.betaD;
    if isfield(coeffDraws,'h') % Time-varying parameter model
        sigmaD = coeffDraws.h;
    else
        sigmaD = coeffDraws.sigmaD;
    end
    nDraws         = size(betaD,3); 
    extra          = 0;
    parameterDraws = inputs.parameterDraws;
    if parameterDraws > nDraws

        if inputs.parallel
            h = false;
        else
            h                = inputs.waitbar;
            h.maxIterations2 = parameterDraws + 1;
            h.text2          = 'Make more posterior draws...'; 
            extra            = 1;
        end
        
        ind  = 1:nDraws;
        indE = nDraws + 1:parameterDraws;
        
        % Out of posterior draws, so we need more!
        [s1,s2,~]            = size(betaD);
        [ss1,ss2,~]          = size(sigmaD);
        betaDFull            = nan(s1,s2,parameterDraws);
        sigmaDFull           = nan(ss1,ss2,parameterDraws);
        betaDFull(:,:,ind)   = betaD;
        sigmaDFull(:,:,ind)  = sigmaD;
        [betaDT,sigmaDT,yDT] = nb_drawFromPosterior(coeffDraws,parameterDraws - nDraws,h);
        betaDFull(:,:,indE)  = betaDT;
        sigmaDFull(:,:,indE) = sigmaDT;
        betaD                = betaDFull;
        sigmaD               = sigmaDFull;
        
        if ySampling
            [s1,s2,~]        = size(yD);
            yDFull           = nan(s1,s2,parameterDraws);
            yDFull(:,:,ind)  = yD;
            yDFull(:,:,indE) = yDT;
            yD               = yDFull;
        end
        
    end

end
