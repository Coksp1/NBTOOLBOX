function obj = sgp(obj)
% Syntax:
%
% obj = sgp(obj)
%
% Description:
%
% Stochastic growth path operator.
% 
% Input:
% 
% - obj : An object of class nb_bgrowth.
% 
% Output:
% 
% - obj : An object of class nb_bgrowth.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    for ii = 1:numel(obj)
        obj(ii).constant    = true; % Turn it into a parameter
        obj(ii).uniaryMinus = false;
    end

end
