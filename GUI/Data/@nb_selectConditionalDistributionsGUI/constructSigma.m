function [sigmaObj,retcode] = constructSigma(model,nSteps,initPeriods,vars,method)
% Syntax:
%
% [sigmaObj,retcode] = ...
% nb_selectConditionalDistributionsGUI.constructSigma(...
%                               model,nSteps,initPeriods,vars,method)
%
% Desciption:
%
% Here we need to construct the auto-covariance matrix to be able to
% initialize the distributions
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    sigmaObj = [];
    retcode  = false;
    tSteps   = nSteps + initPeriods - 1;
    if initPeriods < 1
        
        if strcmpi(method,'empirical')
            retcode = true;
            nb_errorWindow('Calculation of empirical correlation matrix is only supported when not assuming that historical conditions are taken into account.')
            return
        end
        
        % Calculate the conditional correlation matrix
        try
            sigmaObj = conditionalTheoreticalMoments(model,...
                'vars',     'full',...
                'nSteps',   tSteps+1,...
                'vars',     vars,...
                'output',   'nb_cs',...
                'type',     'correlation');
        catch Err
            retcode = true;
            nb_errorWindow('Calculations of theoretical correlation failed.',Err)
            return
        end
        
    else
    
        % Calculate the unconditional correlation matrix.
        if strcmpi(method,'theoretical')

            try
                sigmaObj = theoreticalMoments(model,...
                    'vars',     'full',...
                    'nLags',    tSteps,...
                    'stacked',  true,...
                    'vars',     vars,...
                    'output',   'nb_cs',...
                    'type',     'correlation');
            catch Err
                retcode = true;
                nb_errorWindow('Calculations of theoretical correlation failed.',Err)
                return
            end

        elseif strcmpi(method,'empirical')

            try
                sigmaObj = empiricalMoments(model,...
                    'vars',     vars,...
                    'output',   'nb_cs',...
                    'nLags',    tSteps,...
                    'stacked',  true,...
                    'type',     'correlation');
            catch Err
                retcode = true;
                nb_errorWindow('Calculations of empirical correlation failed.',Err)
                return
            end

        end
        
    end
    
end
