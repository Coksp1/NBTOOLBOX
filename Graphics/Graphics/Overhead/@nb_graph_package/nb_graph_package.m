classdef nb_graph_package < matlab.mixin.Copyable
% Syntax:
%     
% obj = nb_graph_package(start,chapter)
% 
% Superclasses:
% 
% handle
%     
% Description:
%     
% Class for creating a graph package (MPR styled graphs)
%     
% Constructor:
%     
%     obj = nb_graph_package(start,chapter)
%     
%     Input:
% 
%     - start    : The start number of the package. As a scalar.
%  
%     - chapter  : The chapter of the package. As a scalar.
% 
%     Output:
% 
%     - obj      : An object of class nb_graph_package
%     
%     Examples:
% 
%     Start with the first graph of the chapter 1.
%     obj = nb_graph_package(1,1); 
%     
% See also:
% nb_graph_adv, nb_graph_ts, nb_graph_cs
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    %======================================================================
    % Properties of the class
    %======================================================================
    properties
        
        % Save PDF to A4 portrait format. 0 or 1
        a4Portrait          = 0;
        
        % Set the window size to fit the advanced graphs (i.e. 
        % nb_graph_adv objects). Default is true. When set to false
        % the normally produced graphs will be on the correct scale (i.e.
        % nb_graph_ts, nb_graph_cs, nb_graph_data and nb_graph_subplot)
        advanced            = true;
        
        % Give 1 the numbering should be don with a big letter 
        % instead of an number. I.e. 'Figur 1.A' or 'Chart 1.A', instead 
        % of 'Figure 1.1' or 'Chart 1.1'.
        bigLetter           = 0;
        
        % The chapter of the graph package. As an integer.
        chapter             = [];
        
        % Sets the heading on the index page of the excel 
        % spreadsheet. When the language input to the method 
        % saveData is 'norwegian' or 'both' this will be the  
        % heading of the norwegian index page. Must be given as a 
        % string or as an cellstr. A cellstr will give a multilined 
        % heading. E.g. 'Index page' or 
        % {'Index page','second line'}. Default is empty.
        firstPageNameNor    = '';
        
        % Sets the heading on the index page of the excel 
        % spreadsheet. When the language input to the method 
        % saveData is 'english' or 'both' this will be the heading  
        % of the english index page (Or else this property does 
        % nothing). Must be given as a string or as an cellstr. A 
        % cellstr will give a multilined heading. E.g. 'Index page' 
        % or {'Index page','second line'}. Default is empty.
        firstPageNameEng    = '';
        
        % For some reason the graph is sometimes flipped and sometimes not.
        % If the graph is flipped use this property to flip it back.
        flip                = 0;
        
        % All the graphs of the package, as a cell of nb_graph_adv and
        % nb_graph_subplot objects.
        graphs              = {};
        
        % A cellstr with the graph objects identifiers
        identifiers         = {};
        
        % A cell matrix on how to translate the mnemonics to 
        % variable description in the excel output spreadsheet.
        % Both in english and norwegian. Use the set method of this 
        % class for setting this property. 
        % 
        % Must be cell array on the form:
        % 
        % {'mnemonics1','englishDescription1','norwegianDescription1';
        % 'mnemonics2','englishDescription2','norwegianDescription2'};
        % 
        % Or a .m file name, as a string. The .m file must include
        % (and only include) what follows:
        % 
        % obj.lookUpMatrix = {
        % 
        % 'mnemonics1','englishDescription1','norwegianDescription1';
        % 'mnemonics2','englishDescription2','norwegianDescription2'}; 
        lookUpMatrix        = {'','',''};
        
        % Give the number of decimals of the excel output produced by the
        % saveData method. Default is 2. Must be an integer greater or
        % equal to 0, or empty (no round-off).
        roundoff            = 2;                  
        
        % The starting number of the figure package. As an integer.
        start               = [];    
        
        % User data, can be set to anything you want.
        userData            = '';
        
        % Zero lower bound QUA_RNFOLIO and QUA_RNFOLIO_LATESTMPR
        zeroLowerBound      = 1;
        
        % Sets the style of the Excel sheet the data is being exported into
        % using saveData.
        % Options are MPR (Monetary Policy Rapport) and FSR (Financial
        % Stability Rapport). Default is MPR.
        excelStyle = 'MPR'
        
    end
    
    %======================================================================
    % Accessible methods
    %======================================================================
    methods
        
        function obj = nb_graph_package(start,chapter)
        % Constructor
        
            if nargin < 1
                start = 1;
                if nargin < 2
                    chapter = 1;
                end
            end
            
            obj.start   = start;
            obj.chapter = chapter;
            
        end
        
        function set.excelStyle(obj,propertValue)
            
            if ~nb_isOneLineChar(propertValue)
                error([mfilename, ':: Excel style must be set to either ''FSR'' or ''MPR''.'])
            end
            
            if any(strcmpi(propertValue,{'mpr','fsr'}))
                obj.excelStyle = propertValue;
            else
                error([mfilename, ':: Excel style must be set to either ''FSR'' or ''MPR''.'])
            end
            
        end
          
    end
    
    methods(Access=public,Hidden=true)
        
        function s = saveobj(obj)
        % Overload how an object is saved to a .mat file
        
            s = struct(obj);
        
        end
        
        function s = struct(obj)
        % Convert an nb_graph_package object to a struct
        
            sGraphs = size(obj.graphs,2);
            graphsT = cell(1,sGraphs);
            for ii = 1:sGraphs
                graphsT{ii} = struct(obj.graphs{ii});
            end
            graphsT = {graphsT};
        
            firstPageNameE = obj.firstPageNameEng;
            if iscell(firstPageNameE)
                firstPageNameE = {firstPageNameE};
            end
        
            firstPageNameN = obj.firstPageNameNor;
            if iscell(firstPageNameN)
                firstPageNameN = {firstPageNameN};
            end
        
            s = struct(...
                'a4Portrait',       obj.a4Portrait,...
                'advanced',         obj.advanced,...
                'bigLetter',        obj.bigLetter,...
                'chapter',          obj.chapter,...     
                'firstPageNameNor', firstPageNameN,...
                'firstPageNameEng', firstPageNameE,...
                'flip',             obj.flip,...
                'graphs',           graphsT,...
                'identifiers',      {obj.identifiers},...
                'lookUpMatrix',     {obj.lookUpMatrix},...
                'roundoff',         obj.roundoff,...
                'start',            obj.start,...
                'userData',         obj.userData,...
                'zeroLowerBound',   obj.zeroLowerBound,...
                'excelStyle',       obj.excelStyle);
            
        end
        
    end
    
    %======================================================================
    % Protected methods
    %======================================================================
    methods (Access=protected)
        
        varargout = assignTemplate(varargin)
        
        function copyObj = copyElement(obj)
        % Overide the copyElement mehtod of the 
        % matlab.mixin.Copyable class to make deep copy of all the
        % graph objects
        
            % Copy main object
            copyObj = copyElement@matlab.mixin.Copyable(obj);
            
            % Make a deep copy of the graph objects
            for ii = 1:size(copyObj.graphs,2)
                copyObj.graphs{ii} = copy(obj.graphs{ii});
            end
            
        end
        
    end
    
    %======================================================================
    % Static methods of the class
    %======================================================================
    methods(Static=true,Hidden=true)
        
        varargout = getExtendedTemplate(varargin)
        
        function changeGraphEng(hObject,~,plotter,f,gui)

            if gui
                % If it is called in the GUI we scale the line width
                for ii = 1:size(plotter.plotter,2)
                    plotter.plotter(ii).axesScaleLineWidth = true;
                    plotter.plotter(ii).axesScaleFactor    = 0.8;
                end
            end
            
            plotter.graphEng(f,gui);

            % Update the checked menu
            par = get(hObject,'parent');
            old = findobj(par,'checked','on');
            set(old,'checked','off');
            set(hObject,'checked','on');

        end

        function changeGraphNor(hObject,~,plotter,f,gui)

            if gui
                % If it is called in the GUI we scale the line width
                for ii = 1:size(plotter.plotter,2)
                    plotter.plotter(ii).axesScaleLineWidth = true;
                    plotter.plotter(ii).axesScaleFactor    = 0.8;
                end
            end
            
            plotter.graphNor(f,gui);

            % Update the checked menu
            par = get(hObject,'parent');
            old = findobj(par,'checked','on');
            set(old,'checked','off');
            set(hObject,'checked','on');

        end

        function previousGraphCallback(~,~,language,graphsToPrint,graphsMenu,f,gui)

            selected = findobj(graphsMenu,'checked','on');
            children = get(graphsMenu,'children');
            name     = get(selected,'label');

            num   = size(graphsToPrint,2);
            names = cell(num,1);
            if strcmpi(language,'english')
                for ii = 1:num
                    names{ii} = graphsToPrint{ii}.figureNameEng;
                end
            else
                for ii = 1:num
                    names{ii} = graphsToPrint{ii}.figureNameNor;
                end
            end

            ind = find(strcmp(name,names),1);
            if ind < 2
                ind = 2;
            end

            plotter = graphsToPrint{ind - 1};
            if strcmpi(language,'english')
                plotter.graphEng(f,gui);
            else
                plotter.graphNor(f,gui);
            end

            % Update the checked menu
            set(selected,'checked','off');
            set(children(end - ind + 2),'checked','on');

        end

        function nextGraphCallback(~,~,language,graphsToPrint,graphsMenu,f,gui)

            selected = findobj(graphsMenu,'checked','on');
            children = get(graphsMenu,'children');
            name     = get(selected,'label');

            num   = size(graphsToPrint,2);
            names = cell(num,1);
            if strcmpi(language,'english')
                for ii = 1:num
                    names{ii} = graphsToPrint{ii}.figureNameEng;
                end
            else
                for ii = 1:num
                    names{ii} = graphsToPrint{ii}.figureNameNor;
                end
            end

            ind = find(strcmp(name,names),1);
            if ind > length(names) - 1
                ind = length(names) - 1;
            end

            plotter = graphsToPrint{ind + 1};
            if strcmpi(language,'english')
                plotter.graphEng(f,gui);
            else
                plotter.graphNor(f,gui);
            end

            % Update the checked menu
            set(selected,'checked','off');
            set(children(end - ind),'checked','on');

        end
        
        function variableName = findVariableName(lookUpMatrix,mnemonics,language)
        % Look up mnemonics, and find variable name. If not found  
        % return the mnemonics.    
            
            if isempty(lookUpMatrix) 
                stringInd = [];
            else
                stringInd = find(strcmp(mnemonics,lookUpMatrix(:,1)));
            end
            
            if ~isempty(stringInd)
                switch lower(language)

                    case {'norsk','norwegian'}
                        variableName = lookUpMatrix{stringInd,3};
                    case {'english','engelsk'}
                        variableName = lookUpMatrix{stringInd,2};
                    otherwise

                        error([mfilename, ':: Language ' language ' is not supported by this function'])
                end
               
            else
                variableName = mnemonics;
            end
            
        end
        
        function obj = loadobj(s)
        % Overload how an nb_graph_package object is loaded from a
        % .mat file
        
            obj = nb_graph_package.unstruct(s);
        
        end
        
        function obj = unstruct(s)
        % Convert a struct to an object of class nb_graph_package
        
            sGraphs = size(s.graphs,2);
            if sGraphs == 0
                graphsT = [];
            else
                graphsT = cell(1,sGraphs);
                for ii = 1:sGraphs
                    if strcmpi(s.graphs{ii}.class,'nb_graph_adv')
                        graphsT{ii} = nb_graph_adv.unstruct(s.graphs{ii});
                    else
                        graphsT{ii} = nb_graph_subplot.unstruct(s.graphs{ii});
                    end
                end
            end
        
            obj = nb_graph_package();
            obj.chapter          = s.chapter;     
            obj.firstPageNameNor = s.firstPageNameNor;
            obj.firstPageNameEng = s.firstPageNameEng;
            obj.graphs           = graphsT;
            obj.identifiers      = s.identifiers;
            obj.lookUpMatrix     = s.lookUpMatrix;
            obj.roundoff         = s.roundoff;
            obj.start            = s.start;
            obj.userData         = s.userData;
            if isfield(s,'zeroLowerBound')
                obj.zeroLowerBound = s.zeroLowerBound;
            end
            if isfield(s,'a4Portrait')
                obj.a4Portrait = s.a4Portrait;
            end
            if isfield(s,'flip')
                obj.flip = s.flip;
            end
            if isfield(s,'advanced')
                obj.a4Portrait = s.a4Portrait;
            end
            if isfield(s,'bigLetter')
                obj.bigLetter = s.bigLetter;
            end
            if isfield(s,'excelStyle')
                obj.excelStyle = s.excelStyle;
            end
        
        end

    end
    
end
