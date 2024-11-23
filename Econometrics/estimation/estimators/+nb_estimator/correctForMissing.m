function y = correctForMissing(y,missing)
% Syntax:
%
% y = nb_estimator.correctForMissing(y,missing)
%
% Description:
%
% Set observations to nan so each recursion uses the same ragged edge!
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    for ii = 1:size(y,2)
        y(end-missing(ii)+1:end,ii) = nan; 
    end
    
end
