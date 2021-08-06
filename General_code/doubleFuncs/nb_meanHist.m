function meanVector = nb_meanHist(var,periods)
% Syntax:
% 
% meanVector = nb_meanHist(var,periods)
% 
% Description:
% 
% Calculates the mean and return a M X periods vector of the mean
% value. Where M is the size of the second dimension of the
% input
% 
% Input:
% 
% - var        : The data series. As a double
% 
% - periods    : Size of the first dimsioon of the output double
% 
% Output:
% 
% - meanVector : An M X periods vector of the mean value. Where M 
%                is the size of the second dimension of the input
% 
% Examples:
% 
% meanVector = nb_meanHist(x,10)
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    isNaN      = isnan(var);
    meanVector = repmat(mean(var(~isNaN)),periods,1);

end
