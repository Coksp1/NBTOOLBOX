function calculateMomentCallback(gui,~,~)
% Syntax:
%
% calculateMomentCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    type = nb_getUIControlValue(gui.momentTypeBox,'userdata');
    sel  = gui.selectedCellsU;
    if isempty(sel) || strcmpi(gui.tableType,'unfreeze')
        value = [];
    else
        
        if isempty(gui.transData)
            dataObj = gui.data;
        else
            dataObj = gui.transData;
        end
        if isa(dataObj,'nb_bd')
            data = double(dataObj,'stripped');
        else
            data = dataObj.data;
        end
        if isempty(dataObj)
            value = [];
        else
            num     = size(sel,1);
            dataSel = nan(num,1);
            for ii = 1:num
               dataSel(ii) = data(sel(ii,1),sel(ii,2),gui.page);
            end 
            func  = str2func(type);
            value = func(dataSel);
        end
        
    end
    strValue = num2str(value,4);
    set(gui.momentBox,'String',strValue)
    
end
