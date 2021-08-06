function saveTemplate(obj)
% Syntax:
%
% saveTemplate(gui)
%
% Description:
%
% Save the current template
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    cTemplate                = obj.currentTemplate;
    template                 = getCurrentTemplate(obj);
    obj.template.(cTemplate) = template;

end
