function updateStatus(obj)
% Syntax:
%
% updateStatus(obj)
%
% Description:
%
% Update the global min found until now.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    [fMinBees,ind] = min([obj.bees.currentValue]);
    if fMinBees < obj.minFunctionValue
        obj.minFunctionValue = fMinBees;
        obj.minXValue        = obj.bees(ind).current;
        if ~isempty(obj.timer)
            obj.timeOfLastUpdate = toc(obj.timer);
        end
    end

end
