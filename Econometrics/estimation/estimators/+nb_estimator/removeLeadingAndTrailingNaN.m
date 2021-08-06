function [X,keep] = removeLeadingAndTrailingNaN(X)
% Syntax:
%
% [X,keep] = nb_estimator.removeLeadingAndTrailingNaN(X)
%
% Description:
%
% Remove leading and trailing nans from dataset.
%
% Written by Kenneth S. Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Remove all rows with all nan values.
    isNaN  = isnan(X);
    keep   = ~all(isNaN,2);
    start  = find(keep,1,'first');
    finish = find(keep,1,'last');
    X      = X(start:finish,:);
    if nargout > 1
        keep(start:finish) = true;
    end
    
end
