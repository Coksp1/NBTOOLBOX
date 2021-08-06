function resetCallback(gui,~,~,loadedData)
% Syntax:
%
% resetCallback(gui,hObject,event,loadedData)
%
% Description:
%
% Part of DAG. Reset loaded data
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    %close(get(hObject,'parent'));
    
    % Here the data will be reset and all the dependent properties will
    % be updated accordingly. (variables/dates/obs/types to plot etc)
    h.data = loadedData;
    resetDataCallback(gui.plotter,h,[])
   
end
