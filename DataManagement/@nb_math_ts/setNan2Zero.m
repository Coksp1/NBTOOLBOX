function obj = setNan2Zero(obj)
% Syntax:
%
% obj = setNan2Zero(obj)
%
% Description:
%
% Set all nan values of the data of the object to 0.
% 
% Input:
% 
% - obj : An object of class nb_math_ts.
% 
% Output:
% 
% - obj : An object of class nb_math_ts.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    obj.data(isnan(obj.data)) = 0;

end
