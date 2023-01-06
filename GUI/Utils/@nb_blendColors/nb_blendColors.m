classdef nb_blendColors < handle
% Description:
%
% This class makes a GUI for blending colors interacivly.
%
% Constructor:
%
%   gui = nb_blendColors()
% 
%   Output:
% 
%   - gui    : The handle to the object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    properties
        
        % The blended color as an 1x3 double
        color               = [0 0 0];
        
        % The colors to choose from. As a Nx3 double.
        colors              = [];
        
        % The parent of this gui. Either an object of class nb_GUI or
        % empty.
        parent              = [];
         
    end
    
    properties(Access=protected,Hidden=true)
        
        % A struct containing ui components
        components          = struct();
        
    end
    
    events
        
        % Event triggered when color has been selected
        colorSelected
        
    end
    
    methods
        
        function gui = nb_blendColors(parent)
        % Constructor
            if nargin < 1
                parent = [];
            end
            if isa(parent,'nb_GUI')
                gui.parent = parent;
            end
            gui.makeGUI();
        end

    end
    
    methods(Access=protected)
        varargout = add2Colors(varargin);
        varargout = close(varargin);
        varargout = defineCallback(varargin);
        varargout = finishCallback(varargin);
        varargout = makeGUI(varargin);
    end
    
end
