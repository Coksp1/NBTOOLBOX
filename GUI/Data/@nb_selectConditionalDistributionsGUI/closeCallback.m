function closeCallback(gui,~,~)
% Syntax:
%
% closeCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    message = 'Do you want to export the densities to a .mat file?';
    nb_confirmWindow(message,@gui.finishUp,{@gui.exportCallback,true},'Export?')

end

