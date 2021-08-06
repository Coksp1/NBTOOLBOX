function updateRegressPanel(gui,hObject,~)

    if ~isempty(hObject)
        gui.index = get(hObject,'value');
    end

    obj = gui.parent;
    
    % Update ui controls
    set(gui.string,   'string',obj.string{gui.index});
    set(gui.colorpop2,'value', gui.valueColor(gui.index));
    set(gui.positionX,'string',num2str(obj.positionX(gui.index)));
    set(gui.positionY,'string',num2str(obj.positionY(gui.index)));
       
end
