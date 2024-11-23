classdef nb_listSourcesGUI < handle
% Description:
%
% This class makes a GUI for listing the source information of graphs.
%
% Constructor:
%
%   gui = nb_listSourcesGUI(plotter)
% 
%   Input:
%
%   - plotter  : Parent as a nb_GUI object.
%
%   - browseBy : A string with the choice of how you want the list to 
%                be constructed. Either by 'graphs' or 'dataset'.  
% 
%   Output:
% 
%   - gui     : The handle to the object.
%
% Written by Per Bjarne Bye
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties
        
        % Handle to the GUI object. If empty, user can import the
        % information.
        parent       = [];
        
        % Struct with sources
        sources      = struct();
        
        % List of nb_graphs/dataset objects to operate on.
        listNames    = [];
        
        % Handle to the GUI figure
        figureHandle = [];
        
        % The property storing the loaded objects name.
        name         = '';
        
        % The property storing the current source name.
        currSource   = '';
        
        % Indicator. Browsing by graph or dataset.
        browseBy     = '';
        
        % GUI ELEMENTS
        editBox1     = [];
        editBox2     = [];
        editBox3     = [];
        editBox4     = [];
        editBox5     = [];
        editBox6     = [];
    end
    
    methods
        
        function gui = nb_listSourcesGUI(obj,browseBy)
        % Constructor
        
            if nargin < 2
                gui.browseBy = 'graphs';
            else
                gui.browseBy = browseBy;
            end
        
            gui.parent = obj;
            
            if strcmpi(gui.browseBy,'graphs')
                names       = fieldnames(obj.graphs);
                gui.sources = nb_listSourcesGUI.createStructGraphs(obj,names);
            else
                names       = fieldnames(obj.data);
                gui.sources = nb_listSourcesGUI.createStructData(obj,names);
            end
            
            gui.listNames  = names;
            gui.name       = names{1};
            gui.currSource = 'Source_1';
           
            makeGUI(gui);
            
        end
        
    end
    
    methods(Static=true)
        
        varargout = createStructData(varargin)
        
        varargout = createStructGraphs(varargin)
        
    end    
    
    methods(Access=protected)
        
        varargout = makeGUI(varargin)
        
        varargout = fillPanelGUI(varargin)
        
        varargout = fillDBGUI(varargin)
        
        varargout = fillNoSourceGUI(varargin)
        
        varargout = fillPrivateGUI(varargin)
        
        varargout = fillXLSGUI(varargin)
        
        varargout = addSourcesGUI(varargin)
        
        varargout = changeObj(varargin)
        
        varargout = changeSource(varargin)
        
    end
        
    
end
