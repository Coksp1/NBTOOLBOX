 function obj = corr(obj,varargin)
% Syntax:
%
% obj = corr(obj,varargin)
%
% Description:
%
% Calculate the correlation of the timeseries of the nb_ts object
% 
% Caution: Calculates the correlation matrix of the variables of 
% the nb_ts object, if no optional inputs are given. If 'lags' is
% given this function calculates the correlation with the number 
% of wanted lags for each variable with itself. (And only with 
% itself)
%
% Input:
% 
% - obj    : An object of class nb_ts
%
% Optional input ('propertyName',propertyValue):
%
% - 'lags'   : An integer with the number of lags you want
%              to calculate the correlation for. (Here for 
%              each variable)
%
% - 'robust' : true or false. Give true if you want to remove missing 
%              observations during calculations. (Also inf)
%
% - 'type'   : 'pairwise' or 'default'. 'pairwise' calculate the 
%              correlation matrix for the selected lag or lead, while  
%              'default' calculates the correlation with itself for lags 
%              from 1 to lags and the same for lead.
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

        corrValues = nan(obj.numberOfVariables,obj.numberOfVariables,obj.numberOfDatasets);
        if robust
            for ii = 1:obj.numberOfDatasets
                for jj = 1:obj.numberOfVariables
                    for kk = 1:obj.numberOfVariables
                        x1                   = obj.data(:,jj,ii);
                        x2                   = obj.data(:,kk,ii);
                        isFin                = isfinite(x1) & isfinite(x2);
                        corrValues(jj,kk,ii) = corr(x1(isFin,:),x2(isFin,:)); 
                    end
                end
            end
        else
            for ii = 1:obj.numberOfDatasets
                corrValues(:,:,ii) = corr(obj.data(:,:,ii),'rows','pairwise');  
            end
        end

        % Assign th output
        obj           = nb_cs(corrValues,obj.dataNames,obj.variables,obj.variables,obj.sorted);
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

                    corrValues = nan(lags,1);
                    for jj = 1:lags
                        data1 = obj.data(jj + 1:end,ll,ii);
                        data2 = obj.data(1:end - jj,ll,ii);
                        if robust
                            isFin          = isfinite(data1) & isfinite(data2);
                            corrValues(jj) = corr(data1(isFin,:),data2(isFin,:));
                        else
                            corrValues(jj) = corr(data1,data2);
                        end
                    end
                    temp(:,ll,ii) = corrValues;

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
