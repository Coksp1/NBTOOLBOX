function [obj,funEvals] = initialize(obj,F,meritFunction,initialXValue,...
    lowerBound,upperBound,objectiveLimit,maxTrials,local,newtonShare)
% Syntax:
%
% [obj,funEvals] = initialize(obj,F,meritFunction,initialXValue,...
%                     lowerBound,upperBound,objectiveLimit,maxTrials,...
%                     local,newtonShare)
%
% Description:
%
% Initialize the bees that are going to be employed.
% 
% Input:
% 
% - obj : A vector of nb_beeSolver objects.
% 
% - See the properties with the same name in the nb_abcSolve class for
%   help on the rest of the inputs.
%
% Output:
% 
% - obj      : A vector of nb_beeSolver objects. The type property has 
%              been set to 'employed'.
%
% - funEvals : Number of function evaluations during initialization.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    nBees  = size(obj,1);
    numPar = size(initialXValue,1);
    if local
        fVal     = F(initialXValue);
        cVal     = meritFunction(fVal);
        testFunc = @(x)nb_beeSolver.drawCandidatesLocal(fVal,cVal,initialXValue,x);
        funEvals = 1;
    else
        testFunc = @(x)nb_beeSolver.drawCandidates(lowerBound,upperBound,numPar,x); 
        funEvals = 0;
    end
    tested     = ones(numPar,nBees);
    failed     = true(nBees,1);
    beeNum     = 1:nBees;
    beeNumIter = beeNum;
    trial      = 1;
    cVal       = nan(nBees,1);
    fVal       = nan(numPar,nBees);
    while any(failed)

        tested(:,failed) = testFunc(size(beeNumIter,2));
        for ii = beeNumIter

            fVal(:,ii) = F(tested(:,ii));
            cVal(ii)   = meritFunction(fVal(:,ii));
            funEvals   = funEvals + 1;
            if isnan(fVal(:,ii))
                cVal(ii) = objectiveLimit;
            end
            if cVal(ii) <= objectiveLimit
                failed(ii) = false;
            else
                disp(['Failed to find a good initial value for bee nr. ' int2str(ii) ' at trail ' int2str(trial)])
            end

        end

        trial = trial + 1;
        if trial == maxTrials
            error(['Failed to find a good initial value for bee nr. ' int2str(ii) ' in the allowed nr. of trials (' int2str(trial) ').'])
        end
        beeNumIter = beeNum(failed);

    end 
    
    % Assing back to the bees
    for ii = 1:nBees
        obj(ii).current       = tested(:,ii);
        obj(ii).currentValue  = cVal(ii);
        obj(ii).currentFValue = fVal(:,ii);
        obj(ii).type          = 'employed';
    end
    
    numN = ceil(newtonShare*nBees);
    for ii = 1:numN
        obj(ii).method = 2;
    end
    
end
