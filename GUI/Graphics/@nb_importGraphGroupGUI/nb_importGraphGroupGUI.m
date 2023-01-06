classdef nb_importGraphGroupGUI < handle
% Description:
%
% A class for the import graph groups stored in a .mat file to 
% the main GUI.
%
% Constructor:
%
%   gui = nb_importGraphGroupGUI(parent)
% 
%   Input:
%
%   - parent : An object of class nb_GUI
% 
%   Output:
% 
%   - gui    : The handle to the GUI object. As an  
%              nb_importGraphGUI object.
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
        
        % One of the imported graph (used for syncing of local variables)
        plotter      = [];
        
        % Properti to store all the loaded graphs
        graphs       = struct();
        
        % The main GUI window handle, as an nb_GUI object.
        parent       = [];
        
        % Handle to the figure of the gui
        figureHandle = [];
        
    end
    
    events
        
        importingDone
        
    end
    
    %==============================================================
    % Methods
    %==============================================================
    
    methods
        
        function gui = nb_importGraphGroupGUI(parent)
        % Constructor 
        
            gui.parent = parent;
            importDialog(gui)
            
        end
        
    end
    
    %==============================================================
    % Protected methods
    %==============================================================
    
    methods (Access=protected,Hidden=true)
        
        varargout = importDialog(varargin)
        
        varargout = loadOptionsWhenExist(varargin)
        
        varargout = exit(varargin)
        
        varargout = overwrite(varargin)
        
        varargout = finishUp(varargin)
        
    end
    
    
end

