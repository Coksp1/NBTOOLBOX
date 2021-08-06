function updateTemplates(gui)
% Syntax:
%
% updateTemplates(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    gui.templates = getSupportedTemplates(gui.package);
    if isempty(gui.templates)
        gui.template = 'current';
    elseif ~any(strcmp(gui.template,gui.templates))
        gui.template = 'current';
    end

end
