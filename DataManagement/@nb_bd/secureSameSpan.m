function [obj,another] = secureSameSpan(obj,another)

    if ~isa(another,class(obj))% DOC inherited from nb_dataSource!
        error('The two input objects must be of same class')
    end
    isOK = checkConformity(obj,another);
    if ~isOK
        error(['To expand objects to secure same time span is not yet ',...
            'developed for the nb_bd class. Please ask NB Toolbox ',...
            'development team, if needed.'])
    end
    
end
