function [h,note,isWaitbar] = openWaitbar(waitbar,iter)
% Syntax:
%
% [h,note,isWaitbar] = nb_bVarEstimator.openWaitbar(waitbar,iter)
%
% Description:
%
% Open up waitbar for producing posterior draws.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    isWaitbar = true;
    note      = nb_when2Notify(iter);
    if isa(waitbar,'nb_waitbar5')
        h                = waitbar;
        h.maxIterations4 = iter;
        h.text4          = 'Working...';
    elseif ismember(waitbar,[0,1])
        if waitbar
            h                = nb_waitbar5([],'Posterior draws',false,false);
            h.maxIterations4 = iter;
            h.text4          = 'Working...';
        else
            h         = [];
            isWaitbar = false;
        end
    elseif isempty(waitbar)
        h         = [];
        isWaitbar = false;
    else
        error([mfilename ':: Wrong input given to the waitbar option.']) 
    end
    
end

