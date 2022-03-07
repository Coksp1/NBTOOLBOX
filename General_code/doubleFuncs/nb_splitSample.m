function splitted = nb_splitSample(data,nSteps)
% Syntax:
%
% splitted = nb_splitSample(data,nSteps)
%
% Description:
%
% Split a sample into a matrix with size nSteps x nvar x nobs. Will append
% nan values for the last observations. 
% 
% Input:
% 
% - data   : A nobs x nvar double.
% 
% - nSteps : The number of period of the splitted data.
%
% Output:
% 
% - splitted : A nSteps x nvar x nobs double.
%
% Examples:
%
% splitted = nb_splitSample(rand(20,2),4)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [nObs,nVar] = size(data);
    data        = [data;nan(nSteps,nVar)];
    splitted    = nan(nSteps,nVar,nObs); % Just for preallocation
    for ii = 1:nObs
    
        start            = ii;
        finish           = start + nSteps - 1;
        splitted(:,:,ii) = data(start:finish,:);

    end

end
