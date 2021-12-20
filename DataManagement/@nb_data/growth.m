function obj = growth(obj,lag)
% Syntax:
%
% obj = growth(obj,lag)
%
% Description:
%
% Calculate approx growth, using the formula: log(x(t))-log(x(t-1)
% of all the series of the nb_data object.
% 
% Input:
% 
% - obj  : An object of class nb_data
% 
% - lag  : The number of lags in the approx. growth formula, 
%          default is 1.
% 
% Output:
% 
% - obj  : An nb_data object with the calculated series stored.
% 
% Examples:
%
% obj = growth(obj);
% obj = growth(obj,4);
%
% See also:
% egrowth
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen


    if nargin < 2
        lag = 1; 
    end

    din      = obj.data;
    din      = log(din);
    [~,c,p]  = size(din); 
    dout     = cat(1,nan(lag,c,p),din(lag+1:end,:,:)-din(1:end-lag,:,:));
    obj.data = dout;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@growth,{lag});
        
    end

end
