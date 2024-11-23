function callbackMergeOnResponse(gui,hObject,~)
% Syntax:
%
% callbackMergeOnResponse(gui,hObject,event)
%
% Description:
%
% Part of DAG. Callback function when answering yes to merging a 
% nb_ts/nb_data object with an nb_cs object
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Convert
    if isa(gui.data1,'nb_ts') || isa(gui.data1,'nb_data') 
        gui.data1 = gui.data1.tonb_cs(); 
    else
        gui.data2 = gui.data2.tonb_cs(); 
    end
    originalCSMerge(gui);

    close(get(hObject,'parent'));

end
