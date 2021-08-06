function template = getCurrentTemplate(obj)
% Syntax:
%
% template = getCurrentTemplate(obj)
%
% Description:
% 
% Get template from current object.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    props    = nb_graph.getTemplateProps();
    template = struct();
    for ii = 1:length(props)
        if isprop(obj,props{ii})
            template.(props{ii}) = obj.(props{ii});
        end
    end
    
end
