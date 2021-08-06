classdef nb_loadPackageGUI < handle
% Description:
%
% A class for loading a graph package object from the graphPackages 
% property of the main GUI
%
% Constructor:
%
%   gui = nb_loadPackageGUI(parent)
% 
%   Input:
%
%   - parent : An object of class nb_GUI
% 
%   Output:
% 
%   - gui    : The handle to the GUI object. As an  
%              nb_loadPackageGUI object.
%
% Written by Kenneth Sæterhagen Paulsen    
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % Handle to the figure of the GUI
        fig         = [];
        
        % Handle to the list box to select the graph objects from
        listBox     = [];
        
        % The main GUI window handle, as an nb_GUI object.
        parent      = [];
        
        % The loaded graph package object as an nb_graph_package
        % object
        package     = [];
        
        % Name of the loaded graph object
        packageName = '';
        
    end
    
    events
        
        loadObjectFinished
        
    end
    
    %==============================================================
    % Methods
    %==============================================================
    
    methods
       
        function gui = nb_loadPackageGUI(parent)
        % Constructor

            % Assign properties
            gui.parent = parent;
            
            % Make GUI
            makeGUI(gui);

        end
        
    end
    
    %==============================================================
    % Protected methods
    %==============================================================
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = selectPackage(varargin)
        
    end
    
end
