function obj = today()
% Syntax:
%
% obj = nb_day.today()
%
% Description:
%
% Get the current day as a nb_day object. 
%
% Output:
% 
% obj : An object of class nb_day.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    try
        c   = datetime('now');
        obj = nb_day(day(c),month(c),year(c));
    catch
        c   = clock;
        y   = str2double(sprintf('%.0f',c(1)));
        m   = sprintf('%.0f',c(2)+100);
        m   = str2double(m(2:3));
        d   = sprintf('%.0f',c(3)+100);
        d   = str2double(d(2:3));
        obj = nb_day(d,m,y);
    end
    
end

