function obj = today()
% Syntax:
%
% obj = nb_month.today()
%
% Description:
%
% Get the current month as a nb_month object. 
%
% Output:
% 
% obj : An object of class nb_month.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    try
        c   = datetime('now');
        obj = nb_month(month(c),year(c));
    catch
        c   = clock;
        y   = str2double(sprintf('%.0f',c(1)));
        m   = sprintf('%.0f',c(2)+100);
        m   = str2double(m(2:3));
        obj = nb_month(m,y);
    end
    
end

