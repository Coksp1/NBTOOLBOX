function obj = steady_state(obj)
% Syntax:
%
% obj = steady_state(obj)
%
% Description:
%
% Steady-state operator.
% 
% Input:
% 
% - obj : A vector of nb_term objects.
%
% Output:
% 
% - obj : A vector of nb_term objects.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin == 1
        obj = generalFunc(obj,'steady_state');
    end
    
end
