function [h,note,isWaitbar] = openWaitbar(waitbar,iter,numQ)
% Syntax:
%
% [h,note,isWaitbar] = nb_quantileEstimator.openWaitbar(waitbar,iter)
%
% Description:
%
% Open up waitbar for producing bootstrapped draws.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    isWaitbar = true;
    note      = nb_when2Notify(iter);
    if isa(waitbar,'nb_waitbar5')
        h = waitbar;
    elseif ismember(waitbar,[0,1])
        if waitbar
            h = nb_waitbar5([],'Bootstrapping',false,false);
        else
            h         = [];
            isWaitbar = false;
        end
    else
        error([mfilename ':: Wrong input given to the waitbar option.']) 
    end
    
    if isWaitbar
        if numQ ~= 1    
            h.maxIterations4 = numQ;
            h.text4          = 'Working on quantile number 1...';
        end
        h.maxIterations5 = iter;
        h.text5          = 'Working...';
    end
    
end

