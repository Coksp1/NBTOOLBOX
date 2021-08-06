function updateStatus(obj)
% Syntax:
%
% updateStatus(obj)
%
% Description:
%
% Update the global min found until now.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    [fMinBees,ind] = min([obj.bees.currentValue]);
    if fMinBees < obj.minFunctionValue
        obj.minFunctionValue = fMinBees;
        obj.minXValue        = obj.bees(ind).current;
        if ~isempty(obj.timer)
            obj.timeOfLastUpdate = toc(obj.timer);
        end
    end

end
