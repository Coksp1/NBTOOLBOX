function differentObjectsMerge(gui)
% Syntax:
%
% differentObjectsMerge(gui,hObject,event)
%
% Description:
%
% Part of DAG. Open up dialog box for merging one nb_ts/nb_data and one 
% nb_cs object 
% 
% Written by Kenneth Sæterhagen Paulsen 

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isa(gui.data1,'nb_ts') || isa(gui.data2,'nb_ts')
        text = 'time-series';
    else
        text = 'dimensionless';
    end

    message = ['You are trying to merge ' text ' data with cross-sectional data. '...
              'To do that the ' text ' data will be converted to cross-sectional data. '...
              'Do you want to proceed?']; 
    nb_confirmWindow(message,@callbackCancel,...
                             {@gui.callbackMergeOnResponse},...
                             'Merge Option');
                       
end

function callbackCancel(hObject,~)
            
    close(get(hObject,'parent'));

end
