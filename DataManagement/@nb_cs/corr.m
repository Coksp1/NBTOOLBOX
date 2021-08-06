function obj = corr(obj,varargin)
% Syntax:
%
% obj = corr(obj,varargin)
%
% Description:
%
% Calculate the correlation of the series of the nb_cs object
% 
% Caution: Calculates the correlation matrix of the variables of 
%          the nb_cs object, if no optional inputs are given.
%
% Input:
% 
% - obj : An object of class nb_cs
% 
% Output:
% 
% - obj : An nb_cs object with the wanted correlation
% 
% Examples:
% 
% corrMatrix = corr(obj);
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
                    covValues(jj,kk,ii) = corr(x1(isFin,:),x2(isFin,:)); 
                end
            end
        end
    else
        for ii = 1:obj.numberOfDatasets
            covValues(:,:,ii) = corr(obj.data(:,:,ii),'rows','pairwise');  
        end
    end

    % Assign th output
    obj           = nb_cs(covValues,obj.dataNames,obj.variables,obj.variables,obj.sorted);
    obj.dataNames = oldObj.dataNames;

    if oldObj.isUpdateable()
        
        oldObj = oldObj.addOperation(@corr,varargin);
        linksT = oldObj.links;
        obj    = obj.setLinks(linksT);
       
    end
    

end
