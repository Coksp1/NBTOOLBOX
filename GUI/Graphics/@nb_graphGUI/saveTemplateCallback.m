function saveTemplateCallback(gui,~,~)
% Syntax:
%
% setTemplateCallback(gui,~,~)
%
% Description:
%
% Add new template.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    nb_confirmWindow('Are you sure you want to save the local template?',...
        @no,@(h,e)yes(h,e,gui),[gui.parent.guiName ': Save local template'])

end

function yes(hObject,~,gui)

    % Close question window
    close(get(hObject,'parent'));
    if strcmpi(gui.type,'advanced')
        saveTemplate(gui.plotterAdv);
    else
        saveTemplate(gui.plotter);
    end
end

function no(hObject,~)
    % Close question window
    close(get(hObject,'parent'));
end
