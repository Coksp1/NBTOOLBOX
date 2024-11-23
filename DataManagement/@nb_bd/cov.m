function obj = cov(obj,varargin) 
% Syntax:
%
% obj = cov(obj,varargin)
%
% Description:
%
% Calculate the covariances of the timeseries of the nb_bd object
% 
% Caution: Calculates the covariance matrix of the variables of 
% the nb_bd object, if no optional inputs are given. If 'lags' is
% given this function calculates the covariance with the number 
% of wanted lags for each variable with itself. (And only with 
% itself)
%
% If the <ignorenan> property of the nb_bd object is set to true,
% the dataset any row with a NaN will be removed and calculations 
% will be done on that data for the whole vcv-matrix. If <ignorenan>
% is false, NaNs will be trimmed to make data vectors conform when 
% calculating covariances, but for variances, max number of rows 
% is kept.
%
% Input:
% 
% - obj    : An object of class nb_bd
%
% Optional input ('propertyName',propertyValue):
%
% - 'lags'   : An integer with the number of lags you want
%              to calculate the covariance for. (Here for 
%              each variable)
%
% - 'type'   : 'pairwise' or 'default'. 'pairwise' calculate the covariance
%              matrix fro the selected lag or lead, while 'default' 
%              calculates the covariance with itself for lags from 1 to
%              lags and the same for lead.
% 
% Output:
% 
% - obj : An nb_cs object with the wanted covariances
% 
% Examples:
% 
% corrMatrix = cov(obj);
% corrMatrix = cov(obj,'lags',2);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    lags   = [];
    type   = 'default';
    for ii = 1:2:size(varargin,2)
        propertyName  = varargin{ii};
        propertyValue = varargin{ii+1};
        switch lower(propertyName)
            case 'lags'
                lags = propertyValue;
            case 'type'
                type = propertyValue;
            otherwise
                error([mfilename ':: Unsupported input ' propertyName])
        end
    end
    
    oldObj = obj;
    data   = getFullRep(obj);
    
    if isempty(lags)

        covValues = nan(obj.numberOfVariables,obj.numberOfVariables,obj.numberOfDatasets);
        if obj.ignorenan
            for ii = 1:obj.numberOfDatasets
                for jj = 1:obj.numberOfVariables
                    for kk = 1:obj.numberOfVariables
                        x1                  = data(:,jj,ii);
                        x2                  = data(:,kk,ii);
                        isFin               = isfinite(x1) & isfinite(x2);
                        covmatrix           = cov(x1(isFin,:),x2(isFin,:)); 
                        covValues(jj,kk,ii) = covmatrix(1,2);
                    end
                end
            end
        else
            for ii = 1:obj.numberOfDatasets
                covValues(:,:,ii) = cov(data(:,:,ii),'omitrows');  
            end
        end

        % Assign the output
        obj           = nb_cs(covValues,obj.dataNames,obj.variables,obj.variables);
        obj.dataNames = oldObj.dataNames;

    else

        if strcmpi(type,'pairwise')
        
            % The covariance with the lags
            if ~isscalar(lags)
                error([mfilename ':: If ''type'' is set to ''pairwise'' the lags input must be a scalar'])
            end

            temp = nan(obj.numberOfVariables,obj.numberOfVariables,obj.numberOfDatasets);
            for ii = 1:obj.numberOfDatasets

                for ll = 1:obj.numberOfVariables

                    for jj = 1:obj.numberOfVariables
                        data1 = data(lags + 1:end,ll,ii);
                        data2 = data(1:end - lags,jj,ii);
                        if obj.ignorenan
                            isFin          = isfinite(data1) & isfinite(data2);
                            temp(ll,jj,ii) = cov(data1(isFin,:),data2(isFin,:));
                        else
                            temp(ll,jj,ii) = cov(data1,data2);
                        end
                    end

                end

            end
            vars = strcat(obj.variables,'(-',int2str(lags),')');
            
            % Assign the output
            temp           = nb_cs(temp,'',vars,obj.variables);
            temp.dataNames = obj.dataNames;
            obj            = temp;
            
        else
            
            % The covariance with the lags
            temp = nan(lags,obj.numberOfVariables,obj.numberOfDatasets);
            for ii = 1:obj.numberOfDatasets

                for ll = 1:size(obj.variables,2)

                    covValues = nan(lags,1);
                    for jj = 1:lags
                        data1 = data(jj + 1:end,ll,ii);
                        data2 = data(1:end - jj,ll,ii);
                        if obj.ignorenan
                            isFin         = isfinite(data1) & isfinite(data2);
                            covValues(jj) = cov(data1(isFin,:),data2(isFin,:));
                        else
                            covValues(jj) = cov(data1,data2);
                        end
                    end
                    temp(:,ll,ii) = covValues;

                end

            end

            lagNames = cell(1,lags);
            for jj = 1:lags
                lagNames{jj}  = ['Cov(-' int2str(jj) ')']; 
            end
            
            % Assign the output
            temp           = nb_cs(temp,'',lagNames,obj.variables);
            temp.dataNames = obj.dataNames;
            obj            = temp;
            
        end

    end
    
    if oldObj.isUpdateable()
        
        oldObj = oldObj.addOperation(@cov,varargin{:}); 
        linksT = oldObj.links;
        obj    = obj.setLinks(linksT);
       
    end

end
