function saveTemplate(obj)
% Syntax:
%
% saveTemplate(obj)
%
% Description:
%
% Save the current template
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    cTemplate = obj.plotter(1).currentTemplate;
    template  = getCurrentTemplate(obj.plotter(1));
    numG      = size(obj.plotter,2);
    if numG > 1
        template.position1 = template.position;
        template.position2 = obj.plotter(2).position;
        if strcmpi(obj.plotter(1).currentTemplate,'current')
            temp = obj.plotter(1).parent.settings.defaultAdvancedTemplate;
        else
            temp = obj.plotter(1).currentTemplate;
        end
        template.position  = obj.plotter(1).parent.settings.graphSettings.(temp);
    end
    for ii = 1:size(obj.plotter,2) 
        obj.plotter(ii).template.(cTemplate) = template;
        obj.plotter(ii).currentTemplate      = cTemplate;
    end

end
