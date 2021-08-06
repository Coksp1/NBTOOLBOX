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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        stripNaN = false;
        if nargin < 2
            lag = 1; 
        end
    end

    if stripNaN
        % Strip nan values before calculating the growth
        isNaN = isnan(obj.data);
        for vv = 1:obj.numberOfVariables
            for pp = 1:obj.numberOfDatasets
                din     = obj.data(~isNaN(:,vv,pp),vv,pp);
                din     = log(din);
                [~,c,p] = size(din); 
                dout    = cat(1,nan(lag,c,p),din(lag+1:end,:,:)-din(1:end-lag,:,:));
                obj.data(~isNaN(:,vv,pp),vv,pp) = dout;
            end
        end
    else
        din      = obj.data;
        din      = log(din);
        [~,c,p]  = size(din); 
        dout     = cat(1,nan(lag,c,p),din(lag+1:end,:,:)-din(1:end-lag,:,:));
        obj.data = dout;
    end
    obj.data = obj.data*100;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@pcn,{lag,stripNaN});
        
    end

end
