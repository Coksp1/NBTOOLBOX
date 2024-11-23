function notifyWaitbar(h,kk,iter,note)
% Syntax:
%
% nb_estimator.notifyWaitbar(h,kk,iter,note)
%
% Description:
%
% Notify waitbar for recursive estimation.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if iter ~= 1
        if h.canceling
            error([mfilename ':: User terminated'])
        end
        if rem(kk,note) == 0
            h.status3 = kk;
            h.text3   = ['Finished with ' int2str(kk) ' of ' int2str(iter) ' iterations...'];
        end
    end
    
end
