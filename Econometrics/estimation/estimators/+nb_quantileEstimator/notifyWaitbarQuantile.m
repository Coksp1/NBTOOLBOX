function notifyWaitbarQuantile(h,qq,note,numQ)
% Syntax:
%
% nb_quantileEstimator.notifyWaitbarQuantile(h,qq,note,numQ)
%
% Description:
%
% Notify waitbar for producing bootstrapped draws.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numQ == 1
        return
    end

    h.status4 = qq;
    if qq == numQ
        h.text4 = 'Finished';
    else
        h.text4 = ['Working on quantile number ' int2str(qq) '...'];
    end
    if h.canceling
        error('User terminated')
    end
    
end
