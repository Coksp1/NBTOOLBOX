function obj = today()
% Syntax:
%
% obj = nb_quarter.today()
%
% Description:
%
% Get the current quarter as a nb_quarter object. 
%
% Output:
% 
% obj : An object of class nb_quarter.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    c   = clock;
    y   = str2double(sprintf('%.0f',c(1)));
    m   = sprintf('%.0f',c(2)+100);
    m   = str2double(m(2:3));
    q   = ceil(m/3);
    obj = nb_quarter(q,y);
    
end

