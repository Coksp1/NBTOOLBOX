function obj = rlag(obj,~,periods)
% Syntax:
%
% obj = rlag(obj,lags)
% obj = rlag(obj,lags,periods)
%
% Description:
%
% Roll a pattern in the data forward with a given lag. 
% 
% Input:
% 
% - obj      : An object of class nb_objectInExpr
%
% - lags     : Any
% 
% - periods  : The extrapolated periods. The end date of the object will
%              be the current end date plus these number of periods. Be
%              aware that trailing nan values in the data will be filled in
%              for even if periods == 0, which is the default.
%  
% Output:
% 
% - obj      : An object of class nb_objectInExpr
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        periods = 0;
    end
    obj.date = obj.date + periods;

end
