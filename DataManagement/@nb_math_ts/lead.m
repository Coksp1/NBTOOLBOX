function obj = lead(obj,periods)
% Syntax:
%
% obj = lead(obj,periods)
%
% Description:
%
% Lead the data of the object. The input periods decides for how 
% many periods.
% 
% Input:
% 
% - obj     : An object of class nb_math_ts
% 
% - periods : Lead the data with this number of periods. Default is
%             1 period.
% 
% Output:
% 
% - obj     : An nb_math_ts object where the data leaded by number 
%             of periods given by the input periods.
% 
% Examples:
%
% obj = lead(obj,1);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        periods = 1;
    end

    newData  = obj.data(1 + periods:end,:,:);
    newData  = [newData ; nan(periods,obj.dim2,obj.dim3)];
    obj.data = newData;

end
