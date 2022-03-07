function value = getTemplateProperty(obj,template,property)
% Syntax:
% 
% alue = getTemplateProperty(obj,template,property)
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(template)
        template = obj.currentTemplate;
    end
    value = obj.template.(template).(property);

end
