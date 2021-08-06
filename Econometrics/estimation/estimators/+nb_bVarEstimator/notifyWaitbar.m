function notifyWaitbar(h,kk,note)
% Syntax:
%
% nb_bVarEstimator.notifyWaitbar(h,kk,note)
%
% Description:
%
% Notify waitbar for producing posterior draws.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if rem(kk,note) == 0
        h.status4 = kk;
    end
    if h.canceling
        error('User terminated')
    end
    
end
