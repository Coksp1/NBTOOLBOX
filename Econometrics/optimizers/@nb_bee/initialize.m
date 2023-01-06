function [obj,funEvals] = initialize(obj,objective,lowerBound,upperBound,objectiveLimit,maxTrials,constrFunc)
% Syntax:
%
% [obj,funEvals] = initialize(obj,objective,lowerBound,upperBound,...
%                     objectiveLimit,maxTrials,constrFunc)
%
% Description:
%
% Initialize the bees that are going to be employed.
% 
% Input:
% 
% - obj             : A vector of nb_bee objects.
% 
% - objective       : See the property with the same name in the nb_abc
%                     class.
%
% - objectiveInputs : See the property with the same name in the nb_abc
%                     class.
%
% - lowerBound      : See the property with the same name in the nb_abc
%                     class.
%
% - upperBound      : See the property with the same name in the nb_abc
%                     class.
%
% - objectiveLimit  : See the property with the same name in the nb_abc
%                     class.
%
% - maxTrials       : See the property with the same name in the nb_abc
%                     class.
%
% - constrFunc      : See the output from nb_abc.getConstraints.
%
% Output:
% 
% - obj      : A vector of nb_bee objects. The type property has been set to
%              'employed'.
%
% - funEvals : Number of function evaluations during initialization.
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    funEvals   = 0;
    nBees      = size(obj,1);
    numPar     = size(lowerBound,1);
    tested     = ones(numPar,nBees);
    failed     = true(nBees,1);
    beeNum     = 1:nBees;
    beeNumIter = beeNum;
    trial      = 1;
    fVal       = nan(nBees,1);
    while any(failed)

        tested(:,failed) = nb_bee.drawCandidates(lowerBound,upperBound,numPar,size(beeNumIter,2));
        for ii = beeNumIter

            fVal(ii) = objective(tested(:,ii));
            funEvals = funEvals + 1;
            if fVal(ii) < objectiveLimit
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
        obj(ii).current      = tested(:,ii);
        obj(ii).currentValue = fVal(ii);
        obj(ii).type         = 'employed';
    end
    
    % Check if the starting point violates the constraints
    if ~isempty(constrFunc)
        for ii = 1:nBees
            obj(ii).currentViolation = constrFunc(obj(ii).current);
            obj(ii).currentFeasible  = all(obj(ii).currentViolation > 0); 
        end
    end
    
end
