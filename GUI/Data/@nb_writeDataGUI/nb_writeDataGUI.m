classdef nb_writeDataGUI < handle
% Description:
%
% A class for the export data object to a (local) FAME database.
%
% Constructor:
%
%   gui = nb_writeDataGUI(parent,data)
% 
%   Input:
%
%   - parent : An object of class nb_GUI
%
%   - data   : Th data object to export. Only nb_ts.
% 
%   Output:
% 
%   - gui    : The handle to the GUI object. As an nb_write 
%              object.
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties
        
        % The exported data as either an nb_ts or nb_cs object
        data        = [];
        
        % The main GUI window handle, as an nb_GUI object.
        parent      = [];
        
    end
    
    %==============================================================
    % Methods
    %==============================================================
    
    methods
        
        function gui = nb_writeDataGUI(parent,data)
        % Constructor 
        
            if ~isa(data,'nb_ts')
                nb_errorWindow('Only time-series can be written to a FAME database!')
                return
            end
                
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
            [filename, pathname] = uiputfile({'*.db',  'FAME database (*.db)';...
                                              '*.*',   'All Files (*.*)'},...
                                              '',      nb_getLastFolder(gui));
            
            % Read input file
            %------------------------------------------------------
            if isscalar(filename) || isempty(filename) || isscalar(pathname)
                nb_errorWindow('Invalid save name selected.')
                return
            end
            nb_setLastFolder(gui,pathname);

            % Find name and extension
            c   = strfind(filename,'.');
            ext = filename(c(end) + 1:end);

            % Save to files
            switch lower(ext)

                case {'db'}

                    if gui.data.numberOfDatasets > 1
                        nb_errorWindow('Cannot save down multi-paged time-series object to a local FAME database.')
                        return
                    end

                    try
                        nb_write2FAME(gui.data,'saveName',[pathname, filename]);
                    catch Err
                        if strcmpi(Err.identifier,'nb_ts:WriteToDataWarehouseNotAllowed')
                            nb_errorWindow('It is not possible to write time-series data to a FAME database stored in the data warehouse.')
                        else
                            nb_errorWindow('Your version of the DAG does not support writing data to a FAME database.')
                        end
                        return
                    end

                otherwise

                    nb_errorWindow(['Could not read ' filename ' file. The extension .' ext ' is not supported.']);
                    return

            end
             
        end
        
    end
    
end
