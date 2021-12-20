function status = check(obj)
% Syntax:
%
% status = check(obj)
%
% Description:
%
% Check if some limits has been breached
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    status = true;
    if obj.maxFunEvals <= obj.funEvals
        obj.exitFlag = 0;
        status       = false;
    end
    if obj.maxIter <= obj.iterations
        obj.exitFlag = -1;
        status       = false;
    end
    if obj.maxTime <= toc(obj.timer)
        obj.exitFlag = -2;
        status       = false;
    end
    if obj.maxTimeSinceUpdate <= (toc(obj.timer) - obj.timeOfLastUpdate)
        obj.exitFlag = -3;
        status       = false;
    end
    if obj.options.displayer.stopped
        obj.exitFlag = -4;
        status       = false;
    end
    if obj.saveTime <= (toc(obj.timer) - obj.timeOfLastSave)
        obj.timeOfLastSave = toc(obj.timer);
        if ~isempty(obj.saveName)
            save(obj.saveName,'obj');
        end
    end

end
