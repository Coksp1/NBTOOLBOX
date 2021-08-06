function obj = steady_state_first(obj)
% Syntax:
%
% obj = steady_state_first(obj)
%
% Description:
%
% Steady-state (first regime) operator.
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Do nothing!
    for ii = 1:numel(obj)
        obj(ii).uniaryMinus = false;
    end

end
