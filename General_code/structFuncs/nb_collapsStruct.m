function cs = nb_collapsStruct(s)
% Syntax:
%
% cs = nb_collapsStruct(s)
%
% Description:
%
% Collaps a 1 x N or N x 1 struct into a 1 x 1. If a field differe across
% N the field will be stored as a 1 x N array of same type as the original
% field. One exception is if a field is a double and not a scalar, then
% the it will be a double with size N in the dimension of the double + 1.
% 
% Caution : This function assums that a field has the same size and 
%           is of the same type in the array dimension of the struct.
%
% Caution : The extra fields N and collapse are added to store original 
%           size and collapsing of fields.
%
% Input:
% 
% - s  : A 1 x N or N x 1 struct.
% 
% Output:
% 
% - cs : A 1 x 1 struct.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [P,M]  = size(s);
    N      = max(P,M);
    if P*M > N 
        error([mfielname ':: The input s must either be of size 1 x N or N x 1'])
    end
    
    fields   = fieldnames(s);
    collapse = false(1,length(fields));
    for ii = 1:length(fields)
        
        field = s(1).(fields{ii});
        if isnumeric(field) || islogical(field)
            
            if isscalar(field) || isempty(field)
                
                fieldValues  = [s.(fields{ii})];
                uniqueValues = unique(fieldValues);
                if isscalar(uniqueValues) || isempty(uniqueValues)
                    collapse(ii) = true;
                end

                if collapse(ii)
                    cs.(fields{ii}) = field;
                else
                    cs.(fields{ii}) = fieldValues;
                end
                
            else
               
                collapse(ii)    = false;
                sizes           = size(field);
                fieldValues     = [s.(fields{ii})];
                fieldValues     = reshape(fieldValues,[sizes,N]);
                cs.(fields{ii}) = fieldValues;
                
            end
            
        elseif ischar(field)
            
            fieldValues  = {s.(fields{ii})};
            uniqueValues = unique(fieldValues);
            if isscalar(uniqueValues)
                collapse(ii) = true;
            end
            
            if collapse(ii)
                cs.(fields{ii}) = field;
            else
                cs.(fields{ii}) = fieldValues;
            end
            
        elseif iscellstr(field)
            
            collapse(ii) = true;
            for jj = 2:N
                ind = ismember(s(jj).(fields{ii}),field);
                if any(~ind)
                    collapse(ii) = false;
                    break
                end
            end
            
            if collapse(ii)
                cs.(fields{ii}) = field;
            else
                cs.(fields{ii}) = {s.(fields{ii})};
            end
            
        elseif isstruct(field)
            cs.(fields{ii}) = [s.(fields{ii})];
        else
            cs.(fields{ii}) = {s.(fields{ii})};
        end
        
    end
    
    cs.collapse = collapse;
    cs.N        = N;

end
