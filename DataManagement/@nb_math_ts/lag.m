function obj = lag(obj,periods)
% Syntax:
%
% obj = lag(obj,periods)
%
% Description:
%
% Lag the data of the object. The input periods decides for how 
% many periods.
% 
% Input:
% 
% - obj     : An object of class nb_math_ts
% 
% - periods : Lag the data with this number of periods. Default is
%             1 period.
% 
% Output:
% 
% - obj     : An nb_math_ts object where the data laged by number 
%             of periods given by the input periods.
% 
% Examples:
%
% obj = lag(obj,1);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        periods = 1;
    end

    newData  = obj.data(1:end-periods,:,:);
    newData  = [nan(periods,obj.dim2,obj.dim3); newData];
    obj.data = newData;

end
