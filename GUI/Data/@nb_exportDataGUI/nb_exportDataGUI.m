classdef nb_exportDataGUI < handle
% Description:
%
% A class for the export data from main GUI.
%
% Constructor:
%
%   gui = nb_exportDataGUI(parent,data)
% 
%   Input:
%
%   - parent : An object of class nb_GUI
%
%   - data   : Th data object to export. Either nb_data, nb_ts or nb_cs.
% 
%   Output:
% 
%   - gui    : The handle to the GUI object. As an nb_export 
%              object.
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % The exported data as either a nb_data, nb_ts or nb_cs object
        data        = [];
        
        % The main GUI window handle, as an nb_GUI object.
        parent      = [];
        
    end
    
    %==============================================================
    % Methods
    %==============================================================
    
    methods
        
        function gui = nb_exportDataGUI(parent,data)
        % Constructor 
        
            gui.parent = parent;
            gui.data   = data;
            exportDialog(gui)
            
        end
        
    end
    
    %==============================================================
    % Protected methods
    %==============================================================
    
    methods (Access=protected,Hidden=true)
        
        function exportDialog(gui)
        
            % Get the file name
            [filename, pathname,index] = uiputfile({'*.xlsx;*.xls;*.mat', 'Output files (*.xlsx,*.xls,*.mat)';...
                                                    '*.mat',              'MAT (*.mat)';...
                                                    '*.xlsx',             'Excel (*.xlsx)';...
                                                    '*.xls',              'Excel (*.xls)';...
                                                    '*.txt',              'Text (*.txt)';...
                                                    '*.*',                'All files (*.*)'},...
                                                    '',                   nb_getLastFolder(gui));
            
            % Read input file
            %------------------------------------------------------
            if isscalar(filename) || isempty(filename) || isscalar(pathname)
                nb_errorWindow('Invalid save name selected.')
                return
            end
            nb_setLastFolder(gui,pathname);

            % Find name and extension
            [~,saveN,ext] = fileparts(filename);
            if isempty(ext)
                switch index
                    case 1
                        ext = '.xlsx';
                    case 2
                        ext = '.mat';
                    case 3
                        ext = '.xlsx';
                    case 4
                        ext = '.xls';
                    case 5
                        ext = '.txt';
                    case 6
                        ext = '.xlsx';
                end
            end
            
            if isa(gui.data,'nb_modelDataSource')
                try
                    dataObj = fetch(gui.data);
                catch
                    nb_errorWindow('Could not fetch from the SMART database.')
                    return
                end
            else
                dataObj = gui.data;
            end

            % Save to files
            switch lower(ext)

                case {'.xlsx','.xls'}

                    if dataObj.numberOfDatasets > 1
                        append = true;
                    else
                        append = false;
                    end
                    try
                        dataObj.saveDataBase('ext',ext(2:end),'saveName',[pathname, saveN],'append',append);
                    catch Err
                        nb_errorWindow('Error while exporting dataset. MATLAB error: ', Err)
                        return
                    end
                    
                case '.txt'

                    if dataObj.numberOfDatasets > 1
                        nb_errorWindow('Cannot save data to .txt file when dealing with multiple paged dataset.')
                        return
                    end
                    try
                        dataObj.saveDataBase('ext',ext(2:end),'saveName',[pathname, saveN]);
                    catch Err
                        nb_errorWindow('Error while exporting dataset. MATLAB error: ', Err)
                        return
                    end
                    
                case '.mat'
                    
                    try
                        s = struct(gui.data); %#ok<NASGU>
                        save([pathname, saveN],'-struct','s')
                    catch Err
                        nb_errorWindow('Error while exporting dataset. MATLAB error: ', Err)
                        return
                    end
                    
                otherwise

                    nb_errorWindow(['Unsupported extension ' ext 'provided.']);
                    return

            end
                
        end
        
    end
    
end
