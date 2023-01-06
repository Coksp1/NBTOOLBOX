function cs = nb_uncollapsStruct(s)
% Syntax:
%
% cs = nb_uncollapsStruct(s)
%
% Description:
%
% Reverse the operation of nb_collapsStruct.
%
% Input:
% 
% - s  : A 1 x 1 struct.
% 
% Output:
% 
% - cs : A 1 x N or N x 1 struct.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isscalar(s)
        error([mfilename ':: The input s must be a scalar struct'])
    end
    
    
    N        = s.N;
    collapse = s.collapse;
    s        = rmfield(s,{'N','collapse'});
    fields   = fieldnames(s);
    cfields  = fields(collapse);
    cnfields = fields(~collapse);
    sc       = nb_keepFields(s,cfields);
    cs       = nb_addFields(sc,cnfields);
    cs       = cs(1,ones(1,N));
    snc      = rmfield(s,cfields);
    for ii = 1:length(cnfields)
        
        field = snc.(cnfields{ii});
        if isstruct(field)
            for jj = 1:N
                cs(jj).(cnfields{ii}) = field(jj);
            end
        elseif isnumeric(field) || islogical(field)
            sizes = size(field);
            nDim  = size(sizes,2);
            inp   = {':'};
            inp   = inp(1,ones(1,nDim-1));
            for jj = 1:N
                cs(jj).(cnfields{ii}) = field(inp{:},jj);
            end
        elseif iscell(field)
            for jj = 1:N
                cs(jj).(cnfields{ii}) = field{jj};
            end
        end
        
    end

end
