classdef nb_plotLabels < nb_annotation
% Superclasses:
% 
% nb_annotation, handle
%     
% Description:
%     
% A class for plotting labels different types of plots.
%     
% Constructor:
%     
%     obj = nb_plotLabels(varargin)
%     
%     Input:
% 
%     Optional input ('propertyName', propertyValue):
%
%     > You can set some properties of the class. See the list 
%       below. 
%     
%     Output
% 
%     - obj : An object of class nb_plotLabels
%     
% See also:
% nb_annotation, handle, nb_axes
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    %======================================================================
    % Properties of the class 
    %======================================================================
    properties
                    
        % Name of the font to use. Must be a string. Default is
        % 'arial'.
        fontName            = 'arial';
        
        % {'points'} | 'normalized' | 'inches' | 'centimeters' |
        %  'pixels'
        % 
        % Font size units. MATLAB uses this property to determine  
        % the units used by the fontSize property.
        % 
        % normalized - Interpret FontSize as a fraction of the 
        % height of the parent axes. When you resize the axes,
        % MATLAB modifies the screen fontSize accordingly.
        % 
        % pixels, inches, centimeters, and points: 
        % Absolute units. 1 point = 1/72 inch.
        fontUnits           = 'points';
        
        % Format of all the labels of this object. As 1 x 1 struct. Will
        % be overwritten by formatColumns, formatRows  and formatCells.
        formatAll       = struct();
         
        % Format of selected columns. As a cell array of structs. Will
        % be overwritten by formatRows and formatCells.
        formatColumns   = {};
        
        % Format of selected rows. As a cell array of structs. Will
        % be overwritten by formatCells.
        formatRows      = {};
        
        % Internal cell representation of each label. As a cell array of 
        % structs. Highest presedence.
        formatCells     = {};
        
        % Sets the language of the text. I.e. how decimal sign 
        % should be plotted. {'english'} | 'norwegian'.
        language        = 'english'; 
        
        % Indicate if the font when fontUnits is set to 'normalized'
        % should be normalized to the axes ('axes') or to the
        % figure ('figure'), i.e. the default axes position 
        % [0.1 0.1 0.8 0.8].
        normalized      = 'figure';
        
    end
    
    events
       
        updated
        
    end
    
    %======================================================================
    % Methods of the class 
    %======================================================================
    methods
        
        function obj = nb_plotLabels(varargin)
        % Constructor

            obj.formatAll = nb_plotLabels.getDefaultFormat();
            if nargin > 0 
                set(obj,varargin);
            end
                 
        end
        
        varargout = set(varargin)
        
        function update(obj)
            plot(obj);
        end
        
    end
    
    methods(Access=public,Hidden=true)
       
        function s = struct(obj)
            
            s     = struct();
            props = properties(obj);
            for ii = 1:length(props)
                switch lower(props{ii})
                    otherwise
                        s.(props{ii}) = obj.(props{ii});
                end
            end
            s.class = 'nb_plotLabels';

        end
            
    end
    
    methods (Access=protected)
        
        varargout = getCoordinatesAndString(varargin)
        varargout = getFormat(varargin)
        varargout = plot(varargin)
        varargout = plotLabel(varargin)
        varargout = setFontSize(varargin)
        
        function editCallback(obj,hObject,~)
        % Callback function called when user click on the edit 
        % option of the uicontextmenu handle attached to the bar
        % annotation handle
            
            type = get(hObject,'label');
            if strcmpi(type,'element')
                type = 'cell';
            end
            t   = get(get(hObject,'parent'),'userData');
            gui = nb_editPlotLabels(obj,get(t,'tag'),get(t,'userData'),type);
            addlistener(gui,'finished',@obj.notifyListeners);
            
        end
        
        function notifyListeners(obj,~,~)
           
            notify(obj,'updated')
            
        end
        
        function deleteCallback(obj,~,~)
        % Callback function called when user click on the delete 
        % option of the uicontextmenu handle attached to the text
        % handle 
        
            nb_confirmWindow('Are you sure you want to delete all the plot labels?',@notDelete,{@deleteAnnotation,obj},'Delete Annotation');
            
            function deleteAnnotation(hObject,~,obj)
        
                obj.deleteOption = 'all';
                delete(obj);
                
                % Close question window
                close(get(hObject,'parent'));
                
            end

            function notDelete(hObject,~)

                % Close question window
                close(get(hObject,'parent'));

            end
  
        end
          
    end
    
    methods (Static=true,Hidden=true)
        
        function s = getDefaultFormat()

            s = struct;
            s.backgroundColor     = 'none';
            s.color               = [0,0,0]; 
            s.decimals            = 2;
            s.displayed           = true;
            s.edited              = false;
            s.edgeColor           = 'none';
            s.fontAngle           = 'normal';
            s.fontSize            = 12;
            s.fontWeight          = 'normal';
            s.horizontalAlignment = 'center';
            s.index               = [];
            s.interpreter         = 'none';
            s.lineStyle           = 'none';
            s.lineWidth           = 1;
            s.location            = 'default';
            s.margin              = 1/40;
            s.position            = [];
            s.rotation            = 0;  
            s.space               = 1/20;
            s.string              = '';
            s.textFormat          = 'normal';
            s.valueType           = 'normal'; % share, cumsum
            s.verticalAlignment   = 'middle';

        end
        
        function s = getEmptyFormat()

            s = struct;
            s.backgroundColor     = [];
            s.color               = []; 
            s.decimals            = [];
            s.displayed           = [];
            s.edited              = [];
            s.edgeColor           = '';
            s.fontAngle           = '';
            s.fontSize            = [];
            s.fontWeight          = '';
            s.horizontalAlignment = '';
            s.index               = [];
            s.interpreter         = '';
            s.lineStyle           = '';
            s.lineWidth           = [];
            s.location            = '';
            s.margin              = [];
            s.position            = [];
            s.rotation            = [];  
            s.space               = [];
            s.string              = '';
            s.textFormat          = '';
            s.verticalAlignment   = '';

        end
        
        function obj = unstruct(s)
            
            default = nb_plotLabels.getDefaultFormat();
            obj     = nb_plotLabels();
            s       = rmfield(s,'class');
            fields  = fieldnames(s);
            for ii = 1:length(fields)
                switch lower(fields{ii})
                    case 'formatall'
                        % Be robust to new format options being added
                        obj.(fields{ii}) = nb_structcat(s.(fields{ii}),default,'first');
                    case 'position'
                        % Discard field
                    otherwise    
                        obj.(fields{ii}) = s.(fields{ii});
                end
            end
            
        end
        
    end
    
end
