function obj = bgp(obj)
% Syntax:
%
% obj = bgp(obj)
%
% Description:
%
% Balanced growth path operator.
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

    for ii = 1:numel(obj)
        obj(ii).constant    = true; % Turn it into a parameter
        obj(ii).uniaryMinus = false;
    end

end
