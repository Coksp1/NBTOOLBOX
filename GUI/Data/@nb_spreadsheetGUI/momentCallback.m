function momentCallback(gui,~,~,type)
% Syntax:
%
% momentCallback(gui,hObject,event,type)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    sel = gui.selectedCellsU;
    if isempty(sel)
        nb_errorWindow(['No selected data to calculate the ' type ' over.'])
        return 
    end
    
    dataObj = getDataObject(gui);
    num     = size(sel,1);
    dataSel = nan(num,1);
    for ii = 1:num
       dataSel(ii) = dataObj.data(sel(ii,1),sel(ii,2),gui.page);
    end 
    func    = str2func(type);
    dataOut = func(dataSel);
    
    % Open up window
    f        = nb_guiFigure([],'',[0,0,25,4],'normal','off');
    strValue = num2str(dataOut,4);
    uicontrol(f,nb_constant.LABEL,...
        'String',   type,...
        'position', [0.04,0.3,0.44,0.4]);
    uicontrol(f,nb_constant.EDIT,...
        'String',      strValue,...
        'position',    [0.52,0.3,0.44,0.4],...
        'keypressfcn', {@nb_lockEditBox,strValue});
    set(f,'visible','on');

end
