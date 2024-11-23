function copy(gui,~,~,subPlotter)
% Syntax:
%
% copy(gui,hObject,event)
%
% Description:
%
% Part of DAG. Copy graph object locally
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    gui.parent.copiedObject = copy(subPlotter);
    
end
