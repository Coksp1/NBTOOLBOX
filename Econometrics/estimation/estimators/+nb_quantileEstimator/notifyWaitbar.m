function notifyWaitbar(h,ii,tt,note)
% Syntax:
%
% nb_quantileEstimator.notifyWaitbar(h,ii,tt,note)
%
% Description:
%
% Notify waitbar for producing bootstrapped draws.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if rem(ii,note) == 0
        h.status5 = ii;
        h.text5   = ['Finished with ' int2str(ii) ' draws in ' int2str(tt) ' tries...'];
    end
    if h.canceling
        error('User terminated')
    end
    
end
