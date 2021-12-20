function [obj,data,newContexts] = update(obj,store2)
% Syntax:
%
% [obj,data,newContexts] = update(obj,store2)
%
% Description:
%
% Update the data given potential updates of the data source.
% 
% Input:
% 
% - obj         : An object of class nb_modelDataSource.
% 
% Output:
% 
% - obj         : The updated nb_modelDataSource object.
%
% - data        : An object of class nb_ts storing the data fetched from  
%                 the data source (Includes both new and old contexts/
%                 vintages).
%
% - newContexts : A cellstr with the added context dates/vintage tags.
%
% Written by Kenneth Sæterhagen Paulsen    

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin == 1
        store2 = [];
    end
    
    if ~isempty(obj.data) && (isa(store2,'nb_writeFcst2Database') || isa(store2,'nb_store2Database'))
        % To fix problem with some models not saved correctly! 
        obj.data      = [];
        obj.storeData = false;
    end

    if isempty(obj.data)
        if isa(store2,'nb_writeFcst2Database') || isa(store2,'nb_store2Database')
            % If the model results are written to a database we don't 
            % want the following contexts
            oldContexts   = getRunDatesAsString(store2,'vintage');
            obj.storeData = false;
        else
            oldContexts   = '';
            obj.storeData = true;
        end
        [newData,newVints] = getTS(obj.source,oldContexts,obj.variables,obj.calendar);
        obj.data           = newData;
        newContexts        = newData.dataNames;
        obj.vintages       = newVints;
    else
        [newData,newVints] = getTS(obj.source,obj.data.dataNames,obj.variables,obj.calendar);
        obj.data           = addPages(obj.data,newData);
        for ii = 1:length(newVints)
            obj.vintages{ii} = [nb_rowVector(obj.vintages{ii}),newVints{ii}];
        end
        newContexts   = newData.dataNames;
        obj.storeData = true;
        if hasConditionalInfo(obj)
            obj.data.userData = [obj.data.userData; newData.userData];
        end
    end
    if nargout > 1
        data = obj.data;
    end
    
end
