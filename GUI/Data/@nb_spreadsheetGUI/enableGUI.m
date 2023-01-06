function enableGUI(gui)
% Syntax:
%
% enableGUI(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isempty(gui.data) && isa(gui.data,'nb_dataSource')
        set(gui.dataMenu,'enable','off');      
        set(gui.datasetMenu,'enable','off');    
    else
        set(gui.dataMenu,'enable','on');      
        set(gui.datasetMenu,'enable','on');    
    end

end
