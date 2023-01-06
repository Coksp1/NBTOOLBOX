function obj = log10(obj)
% Syntax:
%
% obj = log10(obj)
%
% Description:
%
% Take the common (base 10) log of the data stored in the nb_math_ts object
% 
% Input:
% 
% - obj : An object of class nb_math_ts
% 
% Output:
% 
% - obj : An object of class nb_math_ts
% 
% Examples:
% 
% obj = log10(obj);
%
% Written by Andreas Haga Raavand

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj.data = log10(obj.data);

    
end
