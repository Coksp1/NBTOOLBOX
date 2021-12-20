function obj = cov(obj,varargin) 
% Syntax:
%
% obj = cov(obj,varargin)
%
% Description:
%
% Calculate the covariances of the timeseries of the nb_cs object
% 
% Caution: Calculates the covariance matrix of the variables of 
% the nb_cs object, if no optional inputs are given. If 'lags' is
% given this function calculates the covariance with the number 
% of wanted lags for each variable with itself. (And only with 
% itself)
%
% Input:
% 
% - obj    : An object of class nb_cs
%
% Optional input ('propertyName',propertyValue):
%
% - 'lags' : An integer with the number of lags you want
%            to calculate the covariance for. (Here for 
%            each variable)
% 
% Output:
% 
% - obj : An nb_cs object with the wanted covariances
% 
% Examples:
% 
% covMatrix = cov(obj);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    robust = false;
    for ii = 1:2:size(varargin,2)
        propertyName  = varargin{ii};
        propertyValue = varargin{ii+1};
        switch lower(propertyName)
            case 'robust'
                robust = propertyValue;
            otherwise
                error([mfilename ':: Unsupported input ' propertyName])
        end
    end

    oldObj = obj;
    
    covValues = nan(obj.numberOfVariables,obj.numberOfVariables,obj.numberOfDatasets);
    if robust
        for ii = 1:obj.numberOfDatasets
            for jj = 1:obj.numberOfVariables
                for kk = 1:obj.numberOfVariables
                    x1                  = obj.data(:,jj,ii);
                    x2                  = obj.data(:,kk,ii);
                    isFin               = isfinite(x1) & isfinite(x2);
                    covValues(jj,kk,ii) = cov(x1(isFin,:),x2(isFin,:)); 
                end
            end
        end
    else
        for ii = 1:obj.numberOfDatasets
            covValues(:,:,ii) = cov(obj.data(:,:,ii),0);  
        end
    end

    % Assign th output
    obj           = nb_cs(covValues,obj.dataNames,obj.variables,obj.variables,obj.sorted);
    obj.dataNames = oldObj.dataNames;

    if oldObj.isUpdateable()
        
        oldObj = oldObj.addOperation(@cov,varargin);
        linksT = oldObj.links;
        obj    = obj.setLinks(linksT);
       
    end

end
