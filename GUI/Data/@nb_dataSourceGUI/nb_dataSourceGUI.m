classdef nb_dataSourceGUI < handle
% Description:
%
% A class making it possible to view the source of a nb_ts, nb_cs or
% nb_data object in the GUI.
%
% Constructor:
%   
%   gui = nb_dataSourceGUI(parent,data,page)
% 
%   Input:
%
%   - parent: An object of class nb_GUI  
%
%   - data  : The data that you want to see the source of
%
%   - page  : The page in the data that you want to see the source of 
%
%   Output:
%   
%   - gui   : The handle of the gui object, as a nb_dataSourceGUI object.
% 
% Written by Eyo I. Herstad

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
        
        % Handle of window
        sourceWindow = [];
        
        % Name of figure
        figureName = 'Source';
        
        % Handle of parent
        parent = '';
        
        % Handle of data
        data   = [];
        
    end 
    
    properties (Access=protected,Hidden=true)
        
        % Vector with names of the sources
        sourceLinks = [];
        
        % Type of source for the currently viewed data (db,xls or mat)
        currentSource = '';
        
        linkInfo = [];
        
        % Handle of box to select source (if multiple)
        sourceSelect = [];
        
        % Handles to elements on the fame panel
        fameSource      = [];
        fameVar         = [];
        fameStDate      = [];
        fameEndDate     = [];
        fameFreq        = [];
        fameVintage     = [];
        fameHost        = [];
        famePort        = [];
        
        % Handles to elements on the ts panel that will be changed by the
        % callback
        tsSource        = [];
        tsVar           = [];
        tsStDate        = [];
        tsEndDate       = [];
        tsSheet         = [];
        tsSheetText     = [];
        tsRange         = [];
        tsRangeText     = [];
        tsTranspose     = [];
        tsTransposeText = [];
        
        % Handles to elements on the ts panel that will be changed by the
        % callback
        dataSource        = [];
        dataVar           = [];
        dataStDate        = [];
        dataEndDate       = [];
        dataSheet         = [];
        dataSheetText     = [];
        dataRange         = [];
        dataRangeText     = [];
        dataTranspose     = [];
        dataTransposeText = [];
        
        % Handles to elements on the cs panel that will be changed by the
        % callback
        csSource        = [];
        csVar           = [];
        csType          = [];
        csSheet         = [];
        csSheetText     = [];
        csRange         = [];
        csRangeText     = [];
        csTranspose     = [];
        csTransposeText = [];
        
        % Handles to elements on the SMART panel that will be changed by 
        % the callback
        smartVar        = [];
        smartVint       = [];
        smartFreq       = [];
        
        % Handles to the panels
        famePanel       = [];
        nb_tsPanel      = [];
        nb_csPanel      = [];
        nb_dataPanel    = [];
        smartPanel      = [];
        
        % Use by the source list callback
        table            = [];
        sourceListWindow = [];
        
    end
    
    events
       
        methodFinished
        
    end
    
    methods 
        
        function gui = nb_dataSourceGUI(parent,data)
        % Constructor
        
            gui.parent = parent;
            gui.data = data;
            makeGUI(gui);
        
        end
        
    end
    
    methods(Access=protected)
        
        varargout = makeGUI(varargin);
        varargout = sourceCallback(varargin);
        varargout = vintageCallback(varargin);
        
    end
    
end
       
