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
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    c   = clock;
    y   = str2double(sprintf('%.0f',c(1)));
    obj = nb_year(y);
    
end

