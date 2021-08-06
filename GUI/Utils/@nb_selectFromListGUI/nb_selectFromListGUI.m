classdef nb_selectFromListGUI < handle
% Description:
%
% A class for reordering a cellstr.
%
% Constructor:
%
%   gui = nb_selectFromListGUI(c,name)
% 
%   Input:
%
%   - c    : To be selected from. As a cellstr
% 
%   - name : Name of figure, as a string.
%
%   Output:
% 
%   - gui  : A handle to the nb_selectFromListGUI object.
% 
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    properties
        
        % Handle to the MATLAB figure
        figureHandle    = [];
        
        % To be selected from. As a cellstr
        cstr            = {};
        
        % Name of figure, as a string.
        name            = ''; 
        
        % Selected from the list box. As a cellstr
        selcstr         = {};
        
    end
    
    properties(Access=protected)
       
        listbox         = [];
        
    end
    
    events
        
        selectionFinished
        
    end
    
    methods
        
        function gui = nb_selectFromListGUI(c,name)
        % Constructor
        
            gui.cstr  = c;
            gui.name  = name;
            makeGUI(gui);
            
        end
        
    end
    
    methods(Access=protected,Hidden=true)
        varargout = makeGUI(varargin)
        varargout = finishCallback(varargin)
    end
    
end

