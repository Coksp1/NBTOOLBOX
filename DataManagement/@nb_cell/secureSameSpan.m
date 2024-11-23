function [obj,another] = secureSameSpan(obj,another)

    if ~isa(another,class(obj))% DOC inherited from nb_dataSource!
        error('The two input objects must be of same class')
    end
    r1 = size(obj,1);
    r2 = size(another,1);
    c1 = size(obj,2);
    c2 = size(another,2);
    p1 = size(obj,3);
    p2 = size(another,3);
    if r1 ~= r2 || c1 ~= c2 || p1 ~= p2
        error(['To expand objects to secure same time span is not yet ',...
            'developed for the nb_cell class. Please ask NB Toolbox ',...
            'development team, if needed.'])
    end
    
end
