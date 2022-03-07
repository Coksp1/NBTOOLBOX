classdef nb_exportGraphGroupGUI < handle
% Description:
%
% A class for the export graph a group from the main GUI.
%
% Constructor:
%
%   gui = nb_exportGraphGroupGUI(parent)
% 
%   Input:
%
%   - parent  : An object nb_GUI.
% 
%   Output:
% 
%   - gui      : The handle to the GUI object. As a 
%                nb_exportGraphGroupGUI object.
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % Handle to the MATLAB figure.
        figureHandle    = [];
        
        % An object of class nb_GUI
        parent         = [];
        
        
    end
    
    properties(Access=protected)
        
        edit1       = [];    
        list1       = [];
        
    end
    
    %==============================================================
    % Methods
    %==============================================================
    
    methods
        
        function gui = nb_exportGraphGroupGUI(parent)
        % Constructor 
        
            gui.parent = parent;
            makeGUI(gui)
            
        end
        
    end
    
    %==============================================================
    % Protected methods
    %==============================================================
    
    methods (Access=protected,Hidden=true)
        
        varargout = makeGUI(varargin)
        
        varargout = browse(varargin)
        
        varargout = cancel(varargin)
        
        varargout = saveToFile(varargin)

    end
    
end
