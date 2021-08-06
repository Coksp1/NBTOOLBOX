function options = nb_parseOptions(varargin)
% Syntax:
%
% options = nb_parseOptions(varargin)
%
% Description:
%
% Takes structs and key/value-pairs as inputs and returns a struct 
% with lowercase keys
% 
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    options = struct();
    i = 1;
    while (i <= length(varargin))
        vararg = varargin{i};
        if isstruct(vararg)
            options = mergeStructs(options, vararg);
            i = i + 1;
        else
            if length(varargin) < i + 1
                error([mfilename ':: The option options must be given as ',...
                    'option name/option value pairs'])
            end
            options.(lower(vararg)) = varargin{i + 1};
            i = i + 2;
        end
    end
    
end

function a = mergeStructs(a, b)
    fields = fieldnames(b);
    for i = 1:length(fields)
        field = fields{i};
        a.(lower(field)) = b.(field);
    end
end
