function obj = cov(obj,varargin) 
% Syntax:
%
% obj = cov(obj,varargin)
%
% Description:
%
% Calculate the covariances of the timeseries of the nb_data object
% 
% Caution: Calculates the covariance matrix of the variables of 
% the nb_data object, if no optional inputs are given. If 'lags' is
% given this function calculates the covariance with the number 
% of wanted lags for each variable with itself. (And only with 
% itself)
%
% Input:
% 
% - obj    : An object of class nb_data
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
% covMatrix = cov(obj,'lags',2);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    lags   = [];
    robust = false;
    type   = 'default';
    for ii = 1:2:size(varargin,2)
        propertyName  = varargin{ii};
        propertyValue = varargin{ii+1};
        switch lower(propertyName)
            case 'lags'
                lags = propertyValue;
            case 'robust'
                robust = propertyValue;
            case 'type'
                type = propertyValue;
            otherwise
                error([mfilename ':: Unsupported input ' propertyName])
        end
    end
    
    oldObj = obj;

    if isempty(lags)

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
                covValues(:,:,ii) = cov(obj.data(:,:,ii),'rows','pairwise');  
            end
        end

        % Assign th output
        obj           = nb_cs(covValues,obj.dataNames,obj.variables,obj.variables,obj.sorted);
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
                        data1 = obj.data(lags + 1:end,ll,ii);
                        data2 = obj.data(1:end - lags,jj,ii);
                        if robust
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
            temp           = nb_cs(temp,'',vars,obj.variables,obj.sorted);
            temp.dataNames = obj.dataNames;
            obj            = temp;
            
        else
        
            % The covariance with the lags
            temp = nan(lags,obj.numberOfVariables,obj.numberOfDatasets);
            for ii = 1:obj.numberOfDatasets

                for ll = 1:size(obj.variables,2)

                    covValues = nan(lags,1);
                    for jj = 1:lags
                        data1         = obj.data(jj + 1:end,ll,ii);
                        data2         = obj.data(1:end - jj,ll,ii);
                        if robust
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
            temp           = nb_cs(temp,'',lagNames,obj.variables,obj.sorted);
            temp.dataNames = obj.dataNames;
            obj            = temp;
            
        end

    end
    
    if oldObj.isUpdateable()
        
        oldObj = oldObj.addOperation(@cov,varargin);
        linksT = oldObj.links;
        obj    = obj.setLinks(linksT);
       
    end

end
