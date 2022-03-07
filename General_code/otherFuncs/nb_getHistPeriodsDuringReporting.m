function value = nb_getHistPeriodsDuringReporting(freq)
% Syntax:
%
% value = nb_getHistPeriodsDuringReporting()
% value = nb_getHistPeriodsDuringReporting(freq)
%
% Description:
%
% Get number of historical observations to use during reporting.
% 
% Output:
% 
% - value : The number of observations.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 1
        value = 20;
    else
        if freq == 365
            value = 100;
        elseif freq == 52
            value = 50;
        else
            value = 20;
        end
    end
    
end
