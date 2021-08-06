function obj = steady_state_first(obj)
% Syntax:
%
% obj = steady_state_first(obj)
%
% Description:
%
% Derivative of the steady_state_first operator. Used by nb_DSGE.
% 
% Input:
% 
% - obj : An object of class nb_mySD.
%
% Output:
% 
% - obj : An object of class nb_param.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    obj = nb_param(obj.values);
    
end
