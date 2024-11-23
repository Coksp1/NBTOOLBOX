function ret = nb_structEqual(s1,s2)
% Syntax:
%
% ret = nb_structEqual(s1,s2)
%
% Description:
%
% Test for equality of two structs.
% 
% Input:
% 
% - t    : A struct or a nb_struct
%
% - r    : A struct or a nb_struct
% 
% Output:
% 
% - ret : true or false. They are false if they have different fields
%         and the same fields contains different values. Cell arrays
%         are not tested, and if a field of the struct is a cell false is
%         returned.
%
% See also:
% struct, nb_struct
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    ret = true;
    if ~isstruct(s1)
        if isstruct(s2)
            ret = false;
            return
        else
            error('None of the two inputs are struct.')
        end
    else
        if ~isstruct(s2)
            ret = false;
            return
        end
    end
    fields1 = fieldnames(s1);
    fields2 = fieldnames(s2);
    test    = setdiff(fields1,fields2);
    if ~isempty(test)
        ret = false;
        return
    end

    for ii = 1:length(fields1)
        
        value1 = s1.(fields1{ii});
        value2 = s2.(fields1{ii});
        if isempty(value1)
            if ~isempty(value2)
                ret = false;
                return
            end
        elseif nb_isOneLineChar(value1)
            if ~nb_isOneLineChar(value2)
                ret = false;
                return
            end
            if ~strcmp(value1,value2)
                ret = false;
                return
            end
        elseif nb_isScalarNumber(value1)
            if ~nb_isScalarNumber(value2)
                ret = false;
                return
            end
            if value1 ~= value2
                ret = false;
                return
            end
        elseif nb_isScalarLogical(value1)   
            if ~nb_isScalarLogical(value2)
                ret = false;
                return
            end
            if value1 ~= value2
                ret = false;
                return
            end
        elseif isstruct(value1) && isscalar(value1)
            if not(isstruct(value1) && isscalar(value1))
                ret = false;
                return
            end
            ret = nb_structEqual(value1,value2);
            if ~ret
                return
            end
        else
            ret = false;
            return
        end
        
    end

end
