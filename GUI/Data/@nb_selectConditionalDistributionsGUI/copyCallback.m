function copyCallback(gui,~,~)
% Syntax:
%
% copyCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Copy selected content of table
% 
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    sel = gui.selectedCells;
    if isempty(sel)
        return 
    end

    c = gui.distributions(sel(:,1),sel(:,2));
    if numel(c) == 1
        gui.copied = copy(c);
    else
        nb_errorWindow('Cannot copy more then one distribution.')
    end

end
