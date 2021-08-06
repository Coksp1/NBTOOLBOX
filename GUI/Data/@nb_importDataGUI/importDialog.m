function importDialog(gui)
% Syntax:
%
% importDialog(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Kenneth Sæterhagen Paulsen
        
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get the file name
    [gui.filename, gui.pathname] = uigetfile({'*.*',  'All Files (*.*)'},'',nb_getLastFolder(gui));
    
    % Read input file
    %------------------------------------------------------
    if not(~isscalar(gui.filename) && ~isscalar(gui.pathname))
        return
    end
    nb_setLastFolder(gui,gui.pathname);
        
    % Find name and extension
    [~,gui.name,ext] = fileparts(gui.filename);

    switch lower(ext)

        case {'.xlsm','.xlsx','.xls','.csv'}

            % Load the file
            try
                [gui.dataC,gui.sheetList,gui.excel] = nb_xlsread([gui.pathname gui.filename]);
            catch Err
                nb_errorWindow(['Cannot read the selected file. It may be due to the file beeing open,'...
                               'if this is the case please close the excel file and try again.'],Err)
                return
            end

            % Go to import window
            gui.makeGUI();

        case '.mat'

            % Load the file
            try
                gui.data = nb_readMat([gui.pathname gui.filename]);
            catch Err
                nb_errorWindow(['Could not read ' gui.filename ' file. The .MAT file is not on the correct format.'], Err);
                return
            end

            % Save the file
            %-------------------------------------------------------------------------
            % Check if there is some local variables that need to be 
            % syncked.
            if isa(gui.data,'nb_dataSource')
                nb_syncLocalVariablesGUI(gui.parent,gui.data,@gui.saveCallback);
            else
                gui.saveCallback([],[]);
            end
            
        otherwise

            nb_errorWindow(['Could not read ' gui.filename ' file. The extension .' ext ' is not supported.']);
            return

    end

end
