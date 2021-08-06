function FY = getFunctionValueOnePeriod(Y,funcs)
% Syntax:
%
% FY = nb_perfectForesight.getFunctionValueOnePeriod(Y,exoVal,funcs)
%
% Description:
%
% Get function evaluation of one period of the system of equations.
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % For the first period
    FY = funcs.F(Y);
       
end
