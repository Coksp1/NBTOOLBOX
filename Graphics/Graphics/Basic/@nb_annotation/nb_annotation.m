classdef (Abstract) nb_annotation < matlab.mixin.Copyable  
% Superclasses:
%
% handle
%
% Subclasses:
% 
% nb_textAnnotation ans see "see also" section.
%     
% Description:
%     
% A abstract superclass for all classes which are intended to plot 
% annotations on graphs represented by the nb_graph_ts, nb_graph_data or 
% nb_graph_cs classes.
%
% All subclasses of this class should include the methods set and
% plot.
%     
% Constructor:
%     
%     No constructor
%
% See also:
% nb_barAnnotation, nb_arrow, nb_textarrow, nb_textBox, nb_drawLine, 
% nb_drawPatch, nb_legend, nb_regressLine, nb_curlyBrace, nb_plotLabels
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    %==============================================================
    % Properties of the class 
    %==============================================================
    properties
        
        % The children of the handle. 
        children            = [];
        
        % Set to true if a copy option should be added to the context menu 
        % of annotation object. Default is false.
        copyOption          = false;
        
        % The listeners of the handle. 
        listeners           = [];
        
        % {'all'} | 'only'. If 'all' is given the object will be 
        % delete and all that is plotted by this object are 
        % removed from the figure it is plotted on. If on the other 
        % hand 'only' is given, it will just delete the object
        deleteOption        = 'only';
        
        % The parent as an nb_axes object
        parent              = [];
        
        % The pointer selected when the mouse is above the object.
        % When not above the object '' is selected.
        pointer             = '';
        
        % Indicates if the object is being selected.
        selected            = 0;
            
    end
    
    properties (Access=protected,Hidden=true,Constant=true)
        
        tolerance           = 0.01;
        
    end
    
    events
       
        annotationEdited
        
    end
    
    %======================================================================
    % Methods of the class 
    %======================================================================
    methods
        
        varargout = set(varargin)
        
        varargin  = update(varargin)
        
        function delete(obj)
            if strcmpi(obj.deleteOption,'all')         
                obj.deleteChildren();
            end   
        end
        
        function deleteChildren(obj)
            delete(obj.children(ishandle(obj.children)));
            if ~isempty(obj.listeners)
                delete(obj.listeners);
            end
        end
        
        function copyCallback(obj,~,~)
        % Callback function called when user click on the copy 
        % option of the uicontextmenu handle attached to the text
        % handle
            
            cObj = copy(obj);
            set(obj.parent.parent,'userData',cObj);
        
        end
            
    end        
    
    methods (Access = protected,Hidden=true)
        
        function copyObj = copyElement(obj)
        % Overide the copyElement mehtod of the 
        % matlab.mixin.Copyable class to make deep copy of all the
        % graph objects
        
            % Copy main object
            copyObj = copyElement@matlab.mixin.Copyable(obj);
            
            % Remove the plot handle, which we don't want 
            % keep
            copyObj.children = [];
            copyObj.parent   = [];
            
        end
        
    end
    
    methods(Access=public,Hidden=true,Static=true)
        
        function obj = fromStruct(s)
        % Convert a struct representing an object which is of a 
        % subclass of the nb_annotation class to an object.    
        
            if ~isfield(s,'class')
                error([mfilename ':: The input must be a struct with the field ''class''.'])
            end
            func = str2func([s.class '.unstruct']);
            obj  = func(s);
            
        end
        
    end
    
end
