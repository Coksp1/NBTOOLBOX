classdef (Abstract) nb_plotHandle < handle
% Description:
%
% A abstract class, i.e. no properties and no (dynamic) methods.
%
% The class has some static functions utilized by some of its 
% subclasses
% 
% Subclasses:
%
% nb_area, nb_bar, nb_fanChart, nb_highlight, nb_horizontalLine,
% nb_line, nb_patch, nb_pie, nb_plot, nb_plotComb, nb_radar, 
% nb_scatter, nb_verticalLine, nb_hbar, nb_candle 
%
% Constructor:
%
%   obj = nb_plotHandle
% 
%   Input:
%
%   No inputs
% 
%   Output:
% 
%   - obj : An object of class nb_plotHandle. (Totally meaningless object 
%           to initialize)
% 
%   Examples:
% 
% Properties:
%
% See also:
% nb_area, nb_bar, nb_fanChart, nb_highlight, nb_horizontalLine,
% nb_line, nb_patch, nb_pie, nb_plot, nb_plotComb, nb_radar, 
% nb_scatter, nb_verticalLine, nb_hbar, nb_candle
%
% Written by Kenneth Sæterhagen Paulsen     

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % The parent axes you wan to plot on, if not given it will 
        % be plotted in a new nb_axes handle. Either a axes or a 
        % nb_axes handle (recommended). 
        parent              = []; 
        
    end
    
    methods
        
        function set.parent(obj,value)
            if ~nb_isAxes(value) && ~isa(value,'nb_axes') && ~isempty(value)
                error([mfilename ':: The parent property must be '...
                      'given as an matlab.graphics.axis.Axes object'...
                      ' or an object of class nb_axes.'])
            end
            obj.parent = value;
        end
        
    end
    
    %======================================================================
    % Static methods
    %======================================================================
    methods (Static=true)
        
        varargout = interpretColor(varargin)

        varargout = findLimitsAlgo(varargin)
       
        varargout = findClosestNiceNumber(varargin)
        
        varargout = getDefaultColors(varargin)
 
    end
    
end
