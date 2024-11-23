function secureTemplate(gui,plotter)
% Syntax:
%
% secureTemplate(gui,plotter)
%
% Description:
%
% Secure that graph has current template. Robustify due to paste errors.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isfield(plotter(1).template,plotter(1).currentTemplate)
        return
    end
    if strcmpi(plotter(1).currentTemplate,'current')
        plotter(1).template.current = getCurrentTemplate(plotter(1));
    else
        templateAll     = gui.parent.settings.graphSettings.(plotter(1).currentTemplate);
        tempProps       = nb_graph.getTemplateProps();
        templateDefault = nb_keepFields(templateAll,tempProps);
        plotter(1).template.(plotter(1).currentTemplate) = templateDefault;
    end
    if size(plotter,2) > 1
        plotter(1).template.(plotter(1).currentTemplate) = templateDefault;
    end
    
end
