function nextPage(gui,~,~)
% Syntax:
%
% nextPage(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if isa(gui.data,'nb_modelDataSource')
        temp = fetch(gui.data);
        max  = temp.numberOfDatasets;
    else
        max = gui.data.numberOfDatasets;
    end

    if gui.page ~= max
        gui.page = gui.page + 1;
        updateTable(gui);
    end
    
end
