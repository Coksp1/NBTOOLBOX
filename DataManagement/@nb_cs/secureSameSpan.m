function [obj,another] = secureSameSpan(obj,another)

    if ~isa(another,class(obj))% DOC inherited from nb_dataSource!
        error('The two input objects must be of same class')
    end
    typesNew       = unique([obj.types,another.types]);
    numTypes       = length(typesNew);
    [indO,locO]    = ismember(typesNew,obj.types);
    dat            = nan(numTypes,obj.numberOfVariables,obj.numberOfDatasets);
    dat(indO,:,:)  = obj.data(locO(indO),:,:);
    [indA,locA]    = ismember(typesNew,another.types);
    datA           = nan(numTypes,another.numberOfVariables,another.numberOfDatasets);
    datA(indA,:,:) = another.data(locA(indA),:,:);
    obj.types      = typesNew;
    obj.data       = dat;
    another.types  = typesNew;
    another.data   = datA;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@secureSameSpan,{another});
        
    end
    
end
