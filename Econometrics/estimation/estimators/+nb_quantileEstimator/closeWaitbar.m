function closeWaitbar(h)
% Syntax:
%
% nb_quantileEstimator.closeWaitbar(h)
%
% Description:
%
% Close waitbar for producing posterior draws.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    deleteFourth(h);
    deleteFifth(h);
    
end

