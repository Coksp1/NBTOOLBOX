function obj = growth(obj,lag)
% Syntax:
%
% obj = growth(obj)
% obj = growth(obj,lag,stripNaN)
%
% Description:
%
% Calculate approx growth, using the formula: log(x(t))-log(x(t-1))
% of all the timeseries of the nb_ts object.
% 
% Input:
% 
% - obj      : An object of class nb_bd
% 
% - lag      : The number of lags in the approx. growth formula, 
%              default is 1.
% 
% Output:
% 
% - obj  : An nb_bd object with the calculated timeseries stored.
% 
% Examples:
%
% obj = growth(obj);
% obj = growth(obj,4);
%
% See also:
% egrowth, aegrowth, agrowth
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        lag = 1; 
    end
    
    data = getFullRep(obj);
    
    if obj.ignorenan
        % Strip nan values before calculating the growth. Still need to
        % operate on the full representation (but affects the growth rates)
        isNaN = isnan(data);
        for ii = 1:obj.numberOfVariables
            for pp = 1:obj.numberOfDatasets
                din     = data(~isNaN(:,ii,pp),ii,pp);
                din     = log(din);
                [~,c,p] = size(din); 
                dout    = cat(1,nan(lag,c,p),din(lag+1:end,:,:)-din(1:end-lag,:,:));
                data(~isNaN(:,ii,pp),ii,pp) = dout;
            end
        end
        growthdata = data;
    else
        din      = data;
        din      = log(din);
        [~,c,p]  = size(din); 
        dout     = cat(1,nan(lag,c,p),din(lag+1:end,:,:)-din(1:end-lag,:,:));
        
        growthdata = dout;
    end
    
    % Saving properties in object
    [loc,ind,dataOut,~] = nb_bd.getLocInd(growthdata);
    obj.locations = loc;
    obj.indicator = ind;
    obj.data      = dataOut;
 
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@growth,{lag});
        
    end
