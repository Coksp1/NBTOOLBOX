function obj = egrowth(obj,lag)
% Syntax:
%
% obj = egrowth(obj,lag)
%
% Description:
%
% Calculate exact growth, using the formula: (x(t) - x(t-1))/x(t-1)
% of all the timeseries of the nb_data object.
% 
% Input:
% 
% - obj  : An object of class nb_data
% 
% - lag  : The number of lags in the growth formula, default is 1.
% 
% Output:
% 
% - obj  : An nb_data object with the calculated series stored.
% 
% Examples:
%
% obj = egrowth(obj);
% obj = egrowth(obj,4);
% 
% See also:
% growth
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        lag = 1; 
    end

    din      = obj.data;
    [~,c,p]  = size(din); 
    dout     = cat(1,nan(lag,c,p),(din(lag + 1:end,:,:)-din(1:end - lag,:,:))./din(1:end - lag,:,:));
    obj.data = dout;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@egrowth,{lag});
        
    end

end
