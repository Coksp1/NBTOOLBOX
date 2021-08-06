function obj = detrend(obj)
% Syntax:
%
% obj = detrend(obj)
%
% Description:
%
% Detrend operator.
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

    % Set to constant
    obj.constant = true;
    for ii = 1:numel(obj)
        obj(ii).uniaryMinus = false;
    end

end
