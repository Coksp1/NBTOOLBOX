classdef nb_exportPackageGUI < handle
% Description:
%
% A class for the export graph package from main GUI.
%
% Constructor:
%
%   gui = nb_exportPackageGUI(parent,package)
% 
%   Input:
%
%   - parent  : An object of class nb_GUI
%
%   - package : The graph package object to export. As an 
%               nb_graph_package object.
% 
%   Output:
% 
%   - gui    : The handle to the GUI object. As an 
%              nb_exportPackageGUI object.
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % The graph package object to export. As an 
        % nb_graph_package object.
        package     = [];
        
        % The main GUI window handle, as an nb_GUI object.
        parent      = [];
        
    end
    
    %==============================================================
    % Methods
    %==============================================================
    
    methods
        
        function gui = nb_exportPackageGUI(parent,package)
        % Constructor 
        
            gui.parent  = parent;
            gui.package = package;
            exportDialog(gui)
            
        end
        
    end
    
    %==============================================================
    % Protected methods
    %==============================================================
    
    methods (Access=protected,Hidden=true)
        
        function exportDialog(gui)
        
            % Get the file name
            [filename, pathname,index] = uiputfile({'*.mat', 'MAT (*.mat)';...
                                                    '*.*',   'All files (*.*)'},...
                                                    '',      nb_getLastFolder(gui));
            
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
                        ext = '.mat';
                    case 2
                        ext = '.mat';
                end
            end

            % Save to files
            switch lower(ext)

                case '.mat'

                    savedObj = gui.package; %#ok<NASGU>
                    save([pathname, saveN, ext],'savedObj');

                otherwise
% 
                    nb_errorWindow(['Unsupported extension ' ext 'provided.']);
                    return

            end
             
        end
        
    end
    
end
