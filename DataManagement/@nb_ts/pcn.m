function obj = pcn(obj,lag,stripNaN)
% Syntax:
%
% obj = pcn(obj);
% obj = pcn(obj,lag,stripNaN)
%
% Description:
%
% Calculate log approximated percentage growth. Using the formula
% (log(t+lag) - log(t))*100
% 
% Input:
% 
% - obj       : An object of class nb_ts
%
% - lag       : The number of lags. Default is 1.
% 
% - stripNaN  : Stip nan before calculating the growth rates.
% 
% Output:
% 
% - obj       : An nb_ts object with the log approximated 
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        stripNaN = false;
        if nargin < 2
            lag = 1; 
        end
    end

    obj.data = pcn(obj.data,lag,stripNaN);
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@pcn,{lag,stripNaN});
        
    end

end
