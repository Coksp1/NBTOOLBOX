classdef nb_importPackageGUI < handle
% Description:
%
% A class for the importing graph package objects stored in a .mat  
% file to main GUI.
%
% Constructor:
%
%   gui = nb_importPackageGUI(parent)
% 
%   Input:
%
%   - parent : An object of class nb_GUI
% 
%   Output:
% 
%   - gui    : The handle to the GUI object. As an  
%              nb_importPackageGUI object.
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties
        
        % The imported object as an nb_graph_package object
        package     = [];
        
        % The main GUI window handle, as an nb_GUI object.
        parent      = [];
        
        % Save name of the imported graph package object. As a 
        % string
        name        = '';
        
    end
    
    events
        
        importingDone
        
    end
    
    %==============================================================
    % Methods
    %==============================================================
    
    methods
        
        function gui = nb_importPackageGUI(parent)
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
    
end

