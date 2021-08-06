classdef nb_loadDataGUI < handle
% Description:
%
% A class for loading data from the data property of the main
% GUI (nb_GUI object)-
%
% Constructor:
%
%   gui = nb_loadDataGUI(parent)
% 
%   Input:
%
%   - parent : An object of class nb_GUI
%
%   Output:
% 
%   - gui    : The handle to the GUI object. As an  
%              nb_loadDataGUI object.
%
% Written by Kenneth Sæterhagen Paulsen    
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % The property storing the loaded data. Either a nb_data, nb_ts
        % or nb_cs object
        data        = [];
        
        % Handle to the figure of the GUI
        fig         = [];
        
        % Handle to the list box to select the datasets from
        listBox     = [];
        
        % The property storing the loaded objects name
        name        = '';
        
        % The main GUI window handle, as an nb_GUI object.
        parent      = [];
        
    end
    
    %==============================================================
    % Events
    %==============================================================
    events
        
        sendLoadedData
        
    end
    
    %==============================================================
    % Methods
    %==============================================================
    
    methods
       
        function gui = nb_loadDataGUI(parent)
        % Constructor

            % Assign properties
            gui.parent = nb_getParentRecursively(parent); % Secure that nb_GUI is stored in parent!
            
            % Make GUI
            makeGUI(gui);

        end
        
    end
    
    %==============================================================
    % Protected methods
    %==============================================================
    
    methods(Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = selectDataset(varargin)
        
    end
    
end
