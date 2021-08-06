function closeWaitbar(h)
% Syntax:
%
% nb_quantileEstimator.closeWaitbar(h)
%
% Description:
%
% Close waitbar for producing posterior draws.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    deleteFourth(h);
    deleteFifth(h);
    
end

