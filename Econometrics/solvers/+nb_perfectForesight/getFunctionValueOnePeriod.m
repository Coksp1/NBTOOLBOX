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
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % For the first period
    FY = funcs.F(Y);
       
end
