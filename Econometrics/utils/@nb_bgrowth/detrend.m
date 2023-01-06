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
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Set to constant
    obj.constant = true;
    for ii = 1:numel(obj)
        obj(ii).uniaryMinus = false;
    end

end
