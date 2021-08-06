function calculateCallback(gui,~,~)
% Syntax:
%
% calculateCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the periods selected
    value      = get(gui.pop1,'value');
    estimators = get(gui.pop1,'userData');
    estimator  = estimators{value};
    value      = get(gui.pop2,'value');
    dists      = get(gui.pop2,'userData');
    dist       = dists{value};
    dim        = get(gui.pop3,'value');
    if not(get(gui.rball,'value') || dim == 2)
        vars     = nb_getUIControlValue(gui.list1,'value');
        gui.data = window(gui.data,'','',vars);
    end
    
    % Evaluate the expression
    gui.data = estimateDist(gui.data,dist,estimator,dim,'nb_dataSource');
        
    % Notify listeners
    notify(gui,'methodFinished');
    
    % Close window
    close(gui.figureHandle);

end
