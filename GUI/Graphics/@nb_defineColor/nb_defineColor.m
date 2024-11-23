classdef nb_defineColor < handle
% Description:
%
% This class makes a GUI for setting colors interacivly.
%
% Constructor:
%
%   gui = nb_defineColor()
% 
%   Output:
% 
%   - gui    : The handle to the object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    properties
        
        % The selected color as an 1x3 double
        color               = [0 0 0];
        
    end
    
    properties(Access=protected,Hidden=true)
        
        % Handle to the axes to plot the selected color
        axesHandle          = [];
        
        % Edit box handles
        editbox1            = [];
        editbox2            = [];
        editbox3            = [];
        
        % Handle to the figure. A MATLAB figure handle. 
        figureHandle        = [];
        
        % Handle to the patch object plotted on the axes.
        patchHandle         = [];
        
        % Slider handles
        slider1             = [];
        slider2             = [];
        slider3             = [];
        
    end
    
    methods
        
        function gui = nb_defineColor()
        % Constructor
            
            % Make GUI
            gui.makeGUI();
            
        end
       
        
        
    end
    
    methods(Access=protected)
        
        varargout = makeGUI(varargin);
        
        varargout = setColor(varargin);
        
    end
    
end
