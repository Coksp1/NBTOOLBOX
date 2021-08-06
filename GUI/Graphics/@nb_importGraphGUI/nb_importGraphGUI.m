classdef nb_importGraphGUI < handle
% Description:
%
% A class for the import graph objects stored in a .mat file to 
% main GUI.
%
% Constructor:
%
%   gui = nb_importGraphGUI(parent)
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
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % The imported data as either a  nb_graph_adv, nb_graph_ts,
        % nb_graph_data or nb_graph_cs object
        plotter     = [];
        
        % The main GUI window handle, as an nb_GUI object.
        parent      = [];
        
        % Save name of the loaded graph object. As a string
        name        = '';
        
    end
    
    events
        
        importingDone
        
    end
    
    %==============================================================
    % Methods
    %==============================================================
    
    methods
        
        function gui = nb_importGraphGUI(parent)
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
        
        varargout = rename(varargin)
        
    end
    
    methods(Static=true,Hidden=true,Access=public)
    
        varargout = checkObject(varargin)
        
    end
    
end

