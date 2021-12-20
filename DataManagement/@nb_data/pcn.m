function obj = pcn(obj,lag)
% Syntax:
%
% obj = pcn(obj,lag)
%
% Description:
%
% Calculate log approximated percentage growth. Using the formula
% (log(t+lag) - log(t))*100
% 
% Input:
% 
% - obj       : An object of class nb_data
%
% - lag       : The number of lags. Default is 1.
% 
% Output:
% 
% - obj       : An nb_data object with the log approximated 
%               percentage growth data stored.
% 
% Examples:
% 
% obj = pcn(obj);   % period-on-period log approx. growth
% obj = pcn(obj,4); % 4-periods log approx. growth
%
% See also:
% growth, egrowth, ipcn
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
    obj.data = dout*100;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@pcn,{lag});
        
    end

end
