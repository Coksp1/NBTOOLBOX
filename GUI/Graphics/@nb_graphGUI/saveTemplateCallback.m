function saveTemplateCallback(gui,~,~)
% Syntax:
%
% setTemplateCallback(gui,~,~)
%
% Description:
%
% Add new template.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

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
