function [x,indZR,restrictions] = removeZR(x,constant,timeTrend,numDep,nLags,restrictions)
% Syntax:
%
% [x,indZR,restrictions] = nb_bVarEstimator.removeZR(x,constant,...
%   timeTrend,numDep,nLags,restrictions)
%
% Description:
%
% Remove zero regressors.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 6
        restrictions = [];
    end

    indZR = ~all(abs(x) < eps,1);
    x     = x(:,indZR);
    indZR = [true(1,constant + timeTrend), indZR, true(1,numDep*nLags)];
    if ~isempty(restrictions)
        % Correct block exogenous restrictions, if any
        restrictions = cellfun(@(x)x(indZR),restrictions,'UniformOutput',false);
    end

end
