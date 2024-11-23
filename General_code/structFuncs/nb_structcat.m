function s = nb_structcat(t,r,type)
% Syntax:
%
% s = nb_structcat(t,r)
%
% Description:
%
% Concatenated structs. If they have conflicting fields with same fieldname
% it will give an error (if type is not set to 'first' or 'last').
% 
% Input:
% 
% - t    : A struct or a nb_struct
%
% - r    : A struct or a nb_struct
% 
% - type : Set to 'first' to use the conflicting fields of the first input,
%          and set to 'last' to use the second input.
% 
% Output:
% 
% - s : A struct or a nb_struct. If one of the inputs is a nb_struct the
%       the output will be a nb_struct.
%
% See also:
% struct, nb_struct
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        type = '';
    end

    if nb_isempty(t)
        s = r;
        return
    elseif nb_isempty(r)
        s = t;
        return
    end

    if not(isstruct(t) && isstruct(r))
        error([mfilename ':: Both inputs must be of class struct or nb_struct'])
    end

    if isa(r,'nb_struct') 
        s = r;
        m = t;
        if ~isempty(type)
            if strcmpi(type,'first')
                type = 'last';
            elseif strcmpi(type,'last')
                type = 'first';
            end
        end
    else
        s = t;
        m = r;
    end
        
    fieldsS = fieldnames(s);
    fieldsM = fieldnames(m);
    ind     = ismember(fieldsM,fieldsS);
    
    same = fieldsM(ind);
    if strcmpi(type,'last')
        
        for ii = 1:length(same)
            s.(same{ii}) = m.(same{ii});
        end
        
    elseif ~strcmpi(type,'first')
    
        for ii = 1:length(same)
            field1 = s.(same{ii});
            field2 = m.(same{ii});
            if ~isequal(field1,field2)
                error([mfilename ':: Conflicting field ' same{ii}])
            end
        end
        
    end
    
    added   = fieldsM(~ind);
    if numel(s) > 1
        for ii = 1:length(added)
            [s.(added{ii})] = deal(m.(added{ii}));
        end
    else
        for ii = 1:length(added)
            s.(added{ii}) = m.(added{ii});
        end
    end
    
end
