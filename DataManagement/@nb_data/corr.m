function obj = corr(obj,varargin)
% Syntax:
%
% obj = corr(obj,varargin)
%
% Description:
%
% Calculate the correlation of the series of the nb_data object
% 
% Caution: Calculates the correlation matrix of the variables of 
% the nb_data object, if no optional inputs are given. If 'lags' is
% given this function calculates the correlation with the number 
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
%            to calculate the correlation for. (Here for 
%            each variable)
% 
% Output:
% 
% - obj : An nb_cs object with the wanted correlation
% 
% Examples:
% 
% corrMatrix = corr(obj);
% corrMatrix = corr(obj,'lags',2);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

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

    else

        if strcmpi(type,'pairwise')
        
            % The correlation with the lags
            if ~isscalar(lags)
                error([mfilename ':: If ''type'' is set to ''pairwise'' the lags input must be a scalar'])
            end

            temp = nan(obj.numberOfVariables,obj.numberOfVariables,obj.numberOfDatasets);
            for ii = 1:obj.numberOfDatasets

                for ll = 1:obj.numberOfVariables

                    for jj = 1:obj.numberOfVariables
                        data1 = obj.data(lags + 1:end,ll,ii);
                        data2 = obj.data(1:end - lags,jj,ii); % lagged
                        if robust
                            isFin          = isfinite(data1) & isfinite(data2);
                            temp(jj,ll,ii) = corr(data1(isFin,:),data2(isFin,:));
                        else
                            temp(jj,ll,ii) = corr(data1,data2);
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
        
            % The correlation with the lags
            temp = nan(lags,obj.numberOfVariables,obj.numberOfDatasets);
            for ii = 1:obj.numberOfDatasets

                for ll = 1:size(obj.variables,2)

                    covValues = nan(lags,1);
                    for jj = 1:lags
                        data1         = obj.data(jj + 1:end,ll,ii);
                        data2         = obj.data(1:end - jj,ll,ii);
                        if robust
                            isFin         = isfinite(data1) & isfinite(data2);
                            covValues(jj) = corr(data1(isFin,:),data2(isFin,:));
                        else
                            covValues(jj) = corr(data1,data2);
                        end
                    end
                    temp(:,ll,ii) = covValues;

                end

            end

            lagNames = cell(1,lags);
            for jj = 1:lags
                lagNames{jj}  = ['Corr(-' int2str(jj) ')']; 
            end

            % Assign the output
            temp           = nb_cs(temp,'',lagNames,obj.variables,obj.sorted);
            temp.dataNames = obj.dataNames;
            obj            = temp;
            
        end

    end
    
    if oldObj.isUpdateable()
        
        oldObj = oldObj.addOperation(@corr,varargin);
        linksT = oldObj.links;
        obj    = obj.setLinks(linksT);
       
    end

end
