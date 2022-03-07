function assignTemplates(gui,plotter)
% Syntax:
%
% assignTemplates(gui,plotter)
%
% Description:
%
% Part of DAG. 
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    templateAll     = gui.parent.settings.graphSettings.(gui.template);
    tempProps       = nb_graph.getTemplateProps();
    templateDefault = nb_keepFields(templateAll,tempProps);
    if isempty(plotter.template)
        template.(gui.template) = templateDefault;
        template.current        = getCurrentTemplate(plotter);
        plotter.template        = template;
        plotter.currentTemplate = gui.template;
    else
        % Secure that the template has all needed fields
        fields = fieldnames(plotter.template);
        for ii = 1:length(fields)
            plotter.template.(fields{ii}) = nb_structcat(plotter.template.(fields{ii}),...
                templateDefault,'first');
        end
    end  

end
