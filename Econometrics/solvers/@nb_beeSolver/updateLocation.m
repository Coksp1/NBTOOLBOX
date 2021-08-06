function obj = updateLocation(obj)
% Syntax:
%
% obj = updateLocation(obj)
%
% Description:
%
% Update the location based on their last evaluation.
%
% Input:
% 
% - obj : A vector of nb_beeSolver objects. 
% 
% Output:
% 
% - obj : A vector of nb_beeSolver objects.
%
% See also:
% nb_abcSolve.doSolving
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [employed,onlookers] = separate(obj);
    
    % Test if the employed bees has found better points during dancing
    % (scouts are now employed)
    for ii = 1:size(employed,1)
        if tournamentSelection(employed(ii),employed(ii))
            employed(ii).currentValue  = employed(ii).testedValue;
            employed(ii).currentFValue = employed(ii).testedFValue;
            employed(ii).current       = employed(ii).tested;
            employed(ii).trials        = 0;
        end
    end
    
    % Test if the onlooker bees has found better points during dancing with
    % a given employed bee
    for ii = 1:size(onlookers,1)
        empInd = onlookers(ii).index;
        if tournamentSelection(onlookers(ii),employed(empInd))
            employed(empInd).currentValue  = onlookers(ii).testedValue;
            employed(empInd).currentFValue = onlookers(ii).testedFValue;
            employed(empInd).current       = onlookers(ii).tested;
            employed(empInd).trials        = 0;
        end
    end
    obj = [employed;onlookers];

end
