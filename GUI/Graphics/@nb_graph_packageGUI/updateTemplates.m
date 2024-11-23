function updateTemplates(gui)
% Syntax:
%
% updateTemplates(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    gui.templates = getSupportedTemplates(gui.package);
    if isempty(gui.templates)
        gui.template = 'current';
    elseif ~any(strcmp(gui.template,gui.templates))
        gui.template = 'current';
    end

end
