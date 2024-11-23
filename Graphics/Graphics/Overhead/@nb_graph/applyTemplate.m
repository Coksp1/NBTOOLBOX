function applyTemplate(obj,chosen)
% Syntax:
%
% applyTemplate(obj,chosen)
%
% Description:
%
% Apply template to nb_graph object.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    try
        t = obj.template.(chosen);
    catch
        error([mfilename ':: The provided template does not exits; ' chosen])
    end
    
    fields = fieldnames(t);
    for ii = 1:length(fields)
        if isprop(obj,fields{ii})
           obj.(fields{ii}) = t.(fields{ii}); 
        end
    end
    obj.currentTemplate = chosen;
    
end
