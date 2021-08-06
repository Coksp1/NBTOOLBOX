function obj = egrowth(obj,lag)
% Syntax:
%
% obj = egrowth(obj)
% obj = egrowth(obj,lag)
%
% Description:
%
% Calculate exact growth, using the formula: (x(t) - x(t-1))/x(t-1)
% of all the timeseries of the nb_bd object.
% 
% Input:
% 
% - obj      : An object of class nb_bd
% 
% - lag      : The number of lags in the growth formula, default is 1.
% 
% Caution : The <ignorenan> property of nb_bd obj controls of NaNs 
%           will be stripped before calculation of growth or not.
% 
% Output:
% 
% - obj  : An nb_bd object with the calculated timeseries stored.
% 
% Examples:
%
% obj = egrowth(obj);
% obj = egrowth(obj,4);
% 
% See also:
% growth, aegrowth, agrowth
%
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        lag = 1; 
    end
    
    fullData = getFullRep(obj);
    
    if obj.ignorenan
        % Strip nan values before calculating the growth
        isNaN = isnan(fullData);
        for vv = 1:obj.numberOfVariables
            for pp = 1:obj.numberOfDatasets
                din     = fullData(~isNaN(:,vv,pp),vv,pp);
                din     = log(din);
                [~,c,p] = size(din); 
                dout     = cat(1,nan(lag,c,p),(din(lag + 1:end,:,:)-din(1:end - lag,:,:))./din(1:end - lag,:,:));
                fullData(~isNaN(:,vv,pp),vv,pp) = dout;
            end
        end
    else
        din      = fullData;
        [~,c,p]  = size(din); 
        dout     = cat(1,nan(lag,c,p),(din(lag + 1:end,:,:)-din(1:end - lag,:,:))./din(1:end - lag,:,:));
        fullData = dout;
    end
    
    [loc,ind,dataOut] = nb_bd.getLocInd(fullData);
    obj.locations     = loc;
    obj.indicator     = ind;
    obj.data          = dataOut;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@egrowth,{lag});
        
    end

end
