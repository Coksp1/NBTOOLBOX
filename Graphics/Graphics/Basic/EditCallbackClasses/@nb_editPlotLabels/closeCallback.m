function closeCallback(gui,~,~)

    % Notify the parent
    notify(gui,'finished')

    % Close window
    delete(gui.figureHandle);

end
