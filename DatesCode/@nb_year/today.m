function obj = today()
% Syntax:
%
% obj = nb_year.today()
%
% Description:
%
% Get the current year as a nb_year object. 
%
% Output:
% 
% obj : An object of class nb_year.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    try
        c  = datetime('now');
        y = year(c);
    catch
        c   = clock;
        y   = str2double(sprintf('%.0f',c(1)));
    end
    obj = nb_year(y);

end

