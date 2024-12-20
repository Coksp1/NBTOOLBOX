function obj = today()
% Syntax:
%
% obj = nb_semiAnnual.today()
%
% Description:
%
% Get the current half year as a nb_semiAnnual object. 
%
% Output:
% 
% obj : An object of class nb_semiAnnual.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    try
        c   = datetime('now');
        obj = nb_semiAnnual(ceil(month(c)/6),year(c));
    catch
        c   = clock;
        y   = str2double(sprintf('%.0f',c(1)));
        m   = sprintf('%.0f',c(2)+100);
        m   = str2double(m(2:3));
        h   = ceil(m/6);
        obj = nb_semiAnnual(h,y);
    end

end

