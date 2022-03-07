function exportDistributionCallback(gui,~,~)
% Syntax:
%
% exportDistributionCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the file name
    [filename,pathname] = uiputfile({'*.mat','MAT (*.mat)'},...
                                     '',     nb_getLastFolder(gui));

    % Read input file
    %------------------------------------------------------
    if isscalar(filename) || isempty(filename) || isscalar(pathname)
        nb_errorWindow('Invalid save name selected.')
        return
    end
    nb_setLastFolder(gui,pathname);

    % Find name and extension
    [~,saveN] = fileparts(filename);

    % Write to .mat file
    date     = nb_getSelectedFromPop(gui.datePopMenu);
    variable = nb_getSelectedFromPop(gui.variablePopMenu);
    dateInd  = strcmp(date,gui.dates);
    varInd   = strcmp(variable,gui.variables);
    distr    = gui.distributions(dateInd,varInd); %#ok<NASGU>
    save([pathname,saveN],'distr');
    
    % Close figure
    close(gui.figureHandle2);
     
end
