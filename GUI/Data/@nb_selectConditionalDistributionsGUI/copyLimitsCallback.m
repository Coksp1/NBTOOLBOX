function copyLimitsCallback(gui,~,~)
% Syntax:
%
% copyLimitsCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Copy limits from selected content of table.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    sel = gui.selectedCells;
    if isempty(sel)
        return 
    end

    c = gui.distributions(sel(:,1),sel(:,2));
    if numel(c) == 1
        gui.copiedLimits = {'lower',c.lowerBound,'upper',c.upperBound};
    else
        nb_errorWindow('Cannot copy limits from more then one distribution.')
    end

end
