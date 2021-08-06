function obj = addLags(obj,nLags,type)
% Syntax:
%
% obj = addLags(obj,nLags)
%
% Description:
%
% Add the wanted number of lags to the object
% 
% Input:
% 
% - obj       : An object of class nb_ts
%
% - nLags     : The number of added lags
% 
% - type      : Either 'lagFast' (defautl) or 'varFast'
%
% Output: 
% 
% - obj       : An object of class nb_ts
% 
% Examples:
%
% obj = addLags(obj,2)
% 
% Written by Kenneth S. Paulsen  

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        type = 'legFast';
    end

    newData = nb_mlag(obj.data,nLags,type);
    newVars = nb_cellstrlag(obj.variables,nLags,type);
    
    if strcmpi(type,'varfast') || ~obj.sorted
        
        obj.data      = [obj.data,newData];
        obj.variables = [obj.variables, newVars];
        
    else
       
        % Merge the lags and the existing data
        nvar                    = obj.numberOfVariables*(nLags + 1);
        temp                    = nan(obj.numberOfObservations,nvar,obj.numberOfDatasets);
        temp(:,1:nLags+1:end,:) = obj.data;
        ind                     = true(1,nvar);
        ind(1:nLags+1:end)      = false;
        temp(:,ind,:)           = newData;
        obj.data                = temp;
        
        % Merge the lags and the existing variables
        tempVars                = cell(1,nvar);
        tempVars(1:nLags+1:end) = obj.variables;
        tempVars(ind)           = newVars;
        obj.variables           = tempVars;
        
    end
        
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@addLags,{nLags});
        
    end
    
end
