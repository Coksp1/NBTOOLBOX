classdef nb_graph_subplot < matlab.mixin.Copyable
% Syntax:
%     
% obj = nb_graph_subplot(varargin)
% 
% Superclasses:
% 
% handle
%     
% Description:
%     
% This is a class for making subplots of nb_graph_ts and 
% nb_graph_cs objects (graphs).
% 
% Constructor:
%     
%     obj = nb_graph_subplot(varargin)
%     
%     Input:
% 
%     - varargin : Arbitary number of objects of class nb_graph_ts 
%                  or nb_graph_cs. 
%
%     Output:
% 
%     - obj      : An object of class nb_graph_subplot
%     
% See also:
% nb_graph_ts, nb_graph_cs
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    %======================================================================
    % Properties of the class 
    %======================================================================
    properties
        
        % Save PDF to A4 portrait format. 0 or 1
        a4Portrait              = 0;
        
        % Scale line width to axes height. true or false (default).
        axesScaleLineWidth      = false;
        
        % Sets the how the figure is saved to .pdf and other figure 
        % formats. If 1 is given the output file will be cropped. 
        % Default is not to crop (i.e. set to 0).         
        crop                    = 0;
        
        % Sets the english name of the figure. This name will be 
        % used on the englisg index page of the excel spreadsheet.
        figureNameEng           = '';
        
        % Sets the norwegian name of the figure. This name will be 
        % used on the norwegian index page of the excel 
        % spreadsheet.
        figureNameNor           = '';
        
        % Position of the figure as a 1x4 double. Default is
        % []. I.e. use the MATLAB default. In characters.
        figurePosition          = [];
        
        % Sets the save file format. Either  'eps', 'jpg', 'pdf' or 
        % 'png'. 'pdf' is default.        
        fileFormat              = 'pdf'; 
        
        % For some reason the graph is sometimes flipped and sometimes not.
        % If the graph is flipped use this property to flip it back.
        flip                    = 0;
        
        % The graphs to include in the figure as subplots. As 
        % nb_graph_ts, nb_graph_data, nb_graph_cs or nb_graph_adv 
        % objects.
        graphObjects            = {};
        
        % Will if set to 'presentation' or 'presentation_white'
        % only decide the some figure option. Use the graphStyle
        % property of the added graph objects to set the graph 
        % style.
        graphStyle              = 'normal'; 
        
        % Sets the language styles of the graphs. Must be a string  
        % with either 'norsk' or 'english'. 'english' is default. 
        % I.e. axis settings differs between norwegian and english 
        % graphs.        
        language                = 'english';    
        
        % Set it to 1 if you want store all the created graphs produced 
        % in one pdf file. Must be use in combination with the saveName 
        % property.
        pdfBook                 = 0; 
        
        % Sets the plot aspect ratio. Either [] or '[4,3]'. Default
        % is [].
        %
        % When set to '[4,3]' the aspect ratio of the figure is
        % 4 to 3. 
        plotAspectRatio         = [];
        
        % Set the axes postion to manual. Default i false
        manualAxesPosition      = false;
        
        % Number of graph produced by the graph methods. Not 
        % settable 
        numberOfGraphs          = [];   
        
        % Sets the saved file name. If not given, no file(s) is/are 
        % produced. Must be a string. 
        % 
        % Default is to save each graph produced in separate files. Set 
        % the pdfBook property to 1 if you want to save all the produced 
        % graphs in one pdf file. (To save all figures in one file is 
        % only possible for pdf files. I.e. the fileFormat property
        % must be 'pdf'.)         
        saveName                = ''; 
        
        % Scale all the font sizes of the plotted graphs of the
        % subplot. (Except nb_annotation objects). Default is 0.7.
        scale                   = 0.7; 
        
        % Sets the shading of the background. Either 'grey' or 'none'. 
        % 'none' will give a white colored background.
        shading                 = 'none';
        
        % Sets the number of subplots per figure. Must be a 1 x 2 double 
        % with the number of subplot rows as the first element and the 
        % number of subplot columns as the second element. Only an 
        % option of the graphSubPlots() method.
        % 
        % Default is [2, 2].
        subPlotSize             = [2,2];
        
        % Set it to 1 if you want the 1x2 and 2x1 subplots to better
        % fit for usage in presentations. Default is 0, i.e. use MATLAB
        % default positions. 
        % 
        % When set to 1 this class uses the nb_subplotSpecial instead 
        % of nb_subplot to find the positions of the subplots.
        subPlotSpecial          = 0;
        
        % User data, can be set to anything you want.
        userData                = '';
                      
    end
    
    properties(Access=public,Hidden=true)
        
        % The parent of the graph when included in a GUI. As an
        % nb_GUI object or empty. Empty is default.
        parent                  = [];
        
    end
    
    properties (Access=protected)
    
        figureHandle            = [];       % The figure handle(s) of the graphs produced
        axesHandles             = [];       % The axes handles of the subplots
        graphMethod             = 'graph';  % The graph method used. Has only graph!
        manuallySetFigureHandle = 0;        % Indicator if the figureHandle has been set manually
        
    end
    
    events
        
        updatedGraph
        
    end
        
    %======================================================================
    % Methods of the class 
    %======================================================================
    methods
        
        function obj = nb_graph_subplot(varargin)
        % Syntax:
        %     
        % obj = nb_graph_subplot(varargin)
        %     
        % Description:
        %
        % Constructor of the nb_graph_subplot class.
        %
        % Input:
        % 
        % - varargin : Arbitary number of objects of class 
        %              nb_graph_ts or nb_graph_cs. 
        %
        % Output:
        % 
        % - obj      : An object of class nb_graph_subplot 
        
            if nargin ~= 0 % Makes it possible to initilize an empty object
           
                for ii = 1:size(varargin,2)
                    obj.add(varargin{ii});
                end
                
            end
                
        end
        
        varargout = get(varargin)
        varargout = getCode(varargin)
        varargout = graph(varargin)
        varargout = saveData(varargin)
        varargout = saveFigure(varargin)
        varargout = set(varargin)
        varargout = update(varargin)
        
    end
    
    methods(Access=public,Hidden=true)
        
        function s = saveobj(obj)
        % Overload how the object is saved to a .mat file
        
            s = struct(obj);
            
        end
        
        function s = struct(obj)
        % Converts the object to a struct   
            
            s       = struct();
            s.class = 'nb_graph_subplot';
            props   = properties(obj);
            for ii = 1:length(props)
                
                switch props{ii}
                    case 'graphObjects'
                        graphObjTemp = obj.graphObjects;
                        for jj = 1:length(graphObjTemp)
                            graphObjTemp{jj} = struct(graphObjTemp{jj});
                        end
                        s.graphObjects = graphObjTemp;
                    otherwise
                        s.(props{ii}) = obj.(props{ii});
                end
            
            end
        
        end
        
        function updateGraph(obj,~,~)
        
            graph(obj);
            
            % Notify listeners
            notify(obj,'updatedGraph');
            
        end
            
        function generalGUI(obj,~,~)
            
            gui = nb_general_subplotGUI(obj);
            addlistener(gui,'changedGraph',@obj.updateGraph);
            
        end
        
    end
    
    %{
    =======================================================================
    Protected methods
    =======================================================================
    %}
    methods (Access=protected)
        
        function copyObj = copyElement(obj)
        % Overide the copyElement mehtod of the 
        % matlab.mixin.Copyable class to make deep copy of all the
        % graph objects
        
            % Copy main object
            copyObj = copyElement@matlab.mixin.Copyable(obj);
            
            % Make a deep copy of the graph objects
            for ii = 1:length(copyObj.graphObjects)
                copyObj.graphObjects{ii} = copy(obj.graphObjects{ii});
            end
            
        end
         
        %{
        -------------------------------------------------------------------
        Clears the handles of the object
        -------------------------------------------------------------------
        %}
        function obj = clearHandles(obj)
            
            if obj.manuallySetFigureHandle == 0
                obj.figureHandle = [];
            end
            
            for ii = 1:length(obj.axesHandles)
                ax = obj.axesHandles(ii);
                if ~isempty(ax)
                    if isvalid(ax)
                        ax.deleteOption = 'all';
                        delete(ax);
                    end
                end
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Set the default settings given the graphing style
        -------------------------------------------------------------------
        %}
        function setDefaultSettings(obj)
            
            if ~isempty(obj.graphStyle)
                
                switch obj.graphStyle

                    case {'mpr','presentation'}

                        obj.crop    = 1;
                        obj.shading = 'grey';
                        
                    case {'mpr_white','presentation_white'}
                        
                        obj.crop    = 1;
                        
                    otherwise

                        if ~isempty(obj.graphStyle)
                            eval(obj.graphStyle)
                        end

                end
                
            end
            
        end
        
    end
    
    %----------------------------------------------------------------------
    % Subfunctions
    %----------------------------------------------------------------------
    methods (Static=true,Hidden=true)

        function obj = loadobj(s)
        % Overload how an nb_graph_subplot object is loaded form a
        % .mat file
        
            obj = nb_graph_subplot.unstruct(s);
            
        end
        
        function obj = unstruct(s)
        % Convert a struct to an nb_graph_subplot object
        
            obj    = nb_graph_subplot();
            s      = rmfield(s,'class');
            fields = fieldnames(s);
            for ii = 1:length(fields)
        
                switch lower(fields{ii})     
                    case 'graphobjects'
                        
                        graphObjTemp = s.graphObjects;
                        for jj = 1:length(graphObjTemp)
                            graphObjTemp{jj} = nb_graph_obj.fromStruct(graphObjTemp{jj});
                        end
                        obj.graphObjects = graphObjTemp;
                        
                    otherwise
                        obj.(fields{ii}) = s.(fields{ii});
                end
                
            end
        
        end
        
    end
    
end
