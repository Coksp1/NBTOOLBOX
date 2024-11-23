function saveTemplate(obj)
% Syntax:
%
% saveTemplate(gui)
%
% Description:
%
% Save the current template
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    cTemplate                = obj.currentTemplate;
    template                 = getCurrentTemplate(obj);
    obj.template.(cTemplate) = template;

end
