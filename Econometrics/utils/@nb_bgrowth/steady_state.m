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
% - obj : An object of class nb_bgrowth.
% 
% Output:
% 
% - obj : An object of class nb_bgrowth.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    % Do nothing!
    for ii = 1:numel(obj)
        obj(ii).uniaryMinus = false;
    end

end
