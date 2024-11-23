function obj = empty(obj)
% Syntax:
%
% obj = empty(obj)
%
% Description: 
%
% Empty the existing nb_math_ts object.
% 
% Input:
%
% - obj : An object of class nb_math_ts
%
% Output:
%
% - obj : An empty nb_math_ts object
%
% Examples:
% 
% obj = empty(obj)
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.startDate = nb_date();
    obj.endDate   = nb_date();
    obj.data      = [];

end
