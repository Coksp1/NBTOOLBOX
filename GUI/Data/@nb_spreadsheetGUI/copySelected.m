function copySelected(gui,~,~)
% Syntax:
%
% copySelected(gui,hObject,event)
%
% Description:
%
% Part of DAG. Copy selected content of table.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    sel   = gui.selectedCells;
    if isempty(sel)
        return 
    end

    dataT = get(gui.table,'data');
    dataT = dataT(sel(1,1):sel(1,2),sel(2,1):sel(2,2));
    nb_copyToClipboard(dataT);

end
