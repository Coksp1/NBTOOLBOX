classdef nb_barAnnotation < nb_textAnnotation
% Superclasses:
% 
% nb_textAnnotation, nb_annotation, handle
%     
% Description:
%     
% A class for plotting annotation on bar plots.
%     
% Constructor:
%     
%     obj = nb_barAnnotation(varargin)
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
%     - obj      : An object of class nb_barAnnotation
%     
%     Examples:
%
% See also:
% nb_textAnnotation, nb_annotation, handle, nb_graph_ts, 
% nb_graph_cs
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    %======================================================================
    % Properties of the class 
    %======================================================================
    properties
                    
        % Color of the text of the annotation. Either a string with 
        % the color name or a 1x3 double with the RGB colors.
        color           = [0 0 0];       
        
        % The number of decimals wanted on the text. Only when type 
        % is set to 'default'.
        decimals        = 2;               
        
        % Force the number of decimals. I.e. even integers get 
        % zeros as decimals.
        force           = 0;                
        
        % Sets the language of the text. I.e. how decimal sign 
        % should be plotted. Only when the input to the plot  
        % function is of class nb_bar. {'english'} | 'norwegian'.
        language        = 'english'; 
        
        % Sets the location of the annotation. 
        % {'on'} : Place it on the bars
        % 'top'  ; Place it on the top of the bars
        location        = 'on'; 
        
        % The rotation of the text. As a double in degrees.
        rotation        = 0;
        
        % Sets the space between the text and the bar when location  
        % is set to top. The scale factor is given as the share of 
        % the height of the y-axis. Only an option when location is 
        % set to 'top'.
        space           = 1/20;                 
        
        % Set the text of the bars. Must be a cellstr with same 
        % size as the plotted data. Where the rows will be the time 
        % periods/case dimension and the columns will be the given 
        % variables. I.e. in line with how the data is orginized in 
        % nb_ts and the nb_cs classes
        %
        % E.g: {'2,0','3,0';'4,0','5,0'}
        string          = {};              
        
        % Sets the how the text on the bars should be created:
        % - {'default'} : The text represent the contribution
        % - 'manual'    : The text is set manually by the user. See 
        %                 property string (When the string property   
        %                 is set this will be the default value of 
        %                 this property)
        type            = 'default';          
        
    end
    
    properties (Hidden=true)
        
        hgchild         = [];
        
    end
    
    %======================================================================
    % Methods of the class 
    %======================================================================
    methods
        
        function obj = nb_barAnnotation(varargin)
        % Constructor

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
            
            s = struct(...
                'class',                'nb_barAnnotation',...
                'color',                obj.color,...
                'decimals',             obj.decimals,...
                'force',                obj.force,...
                'language',             obj.language,...
                'location',             obj.location,...
                'rotation',             obj.rotation,...
                'space',                obj.space,...
                'string',               {obj.string},...
                'type',                 obj.type,...
                'fontName',             obj.fontName,...
                'fontSize',             obj.fontSize,...
                'fontUnits',            obj.fontUnits,...
                'fontWeight',           obj.fontWeight,...
                'normalized',           obj.normalized,...
                'deleteOption',         obj.deleteOption);
            
        end
        
    end
    
    methods (Access=protected)
        
        function plot(obj)
            
            % Get the parent to plot on
            %------------------------------------------------------
            ax = obj.parent;
            if isempty(ax)
                return
            end
            if ~isvalid(ax) 
                return
            end
            
            % Delete the old objects plotted by this object
            %--------------------------------------------------------------
            if ~isempty(obj.children)
                if all(ishandle(obj.children))
                    delete(obj.children)
                end
            end
            
            % Need to check if the nb_axes object contain a nb_bar plot
            %------------------------------------------------------------------
            ind = false(1,size(ax.children,2));
            for ii = 1:size(ax.children,2)

                if isa(ax.children{ii},'nb_bar')
                    ind(ii) = true;
                end

            end

            if ~any(ind)
                warning('nb_barAnnotation:didNotFindBarPlot',[mfilename ':: The nb_axes object given does not contain any bar plot. This nb_barAnnotation object is ignored']);
                return;
            end
            
            % Create a hggroup object to group the text object to
            % one handle
            %------------------------------------------------------
            obj.hgchild = hggroup('parent',ax.axesLabelHandle);

            % Get the handle of the bar plot
            %------------------------------------------------------------------
            barHandle = [ax.children{1,ind}];

            % Test the color spcification
            %----------------------------------------------------------------------
            if ischar(obj.color)
                cData = nb_plotHandle.interpretColor(obj.color);
            else
                cData = obj.color;
            end

            % If the font size is normalized we get the font size
            % transformed to another units
            %--------------------------------------------------------------
            if strcmpi(obj.fontUnits,'normalized')

                if strcmpi(obj.normalized,'axes')
                    fontS = obj.fontSize;
                else % figure
                    fontS = obj.fontSize*0.8/ax.position(4);
                end

            else
                fontS = obj.fontSize;
            end
            fontU = obj.fontUnits;

            % Get the data of the bar plot
            %--------------------------------------------------------------
            for bb = 1:length(barHandle)
            
                pos    = ax.position;
                xData  = barHandle(bb).xData;
                yData  = barHandle(bb).yData;

                switch lower(obj.location)

                    case 'on'

                        % Get the text on the bars
                        %------------------------------------------------------
                        switch obj.type

                            case 'default'

                                switch obj.decimals

                                    case 0
                                        regexp = '%0.0f';
                                    case 1
                                        regexp = '%0.1f';
                                    case 2
                                        regexp = '%0.2f';
                                    case 3
                                        regexp = '%0.3f';
                                    case 4 
                                        regexp = '%0.4f';
                                    otherwise
                                        regexp = '%0.4f';
                                        warning('nb_barAnnotation:plot:TooManyDeciamls',[mfilename ':: Maximal number of decimal points are reach. Force 4 decimals.'])
                                end

                                stringT = cell(size(yData));
                                for ii = 1:size(yData,2)
                                    stringT(:,ii) = cellstr(num2str(yData(:,ii),regexp));
                                end

                                stringT = strtrim(stringT);

                                if strcmpi(obj.language,'norwegian') || strcmpi(obj.language,'norsk')
                                    stringT = strrep(stringT,'.',',');
                                end

                            case 'manual'

                                stringT = obj.string;

                                if any(size(stringT) ~= size(yData))
                                    error([mfilename ':: The size (' int2str(size(stringT)) ') of the provided text to the ''string'' property do not match the size of the data (' int2str(size(yData)) ')'])
                                end

                            otherwise

                                error([mfilename ':: The property ''type'' can only be set to ''default'' or ''manual''.'])

                        end

                        % Plot the annotation
                        %------------------------------------------------------
                        t       = zeros(1,size(yData,2)*size(yData,1));
                        counter =  1;
                        if strcmpi(barHandle(bb).style,'stacked') || strcmpi(barHandle(bb).style,'dec')

                            for ii = 1:size(yData,1)

                                x         = xData(ii);
                                x         = nb_pos2pos(x,ax.xLim,[pos(1),pos(1) + pos(3)],ax.xScale,'normal');
                                yDataRow  = yData(ii,:); 
                                stringRow = stringT(ii,:);

                                yDataRowPos  = yDataRow(yDataRow>=0);
                                yDataRowPosS = cumsum(yDataRowPos);
                                stringRowPos = stringRow(yDataRow>=0);
                                for jj = 1:size(yDataRowPos,2)

                                    if jj == 1
                                       y = yDataRowPos(jj)/2;
                                    else
                                       y = yDataRowPos(jj)/2 + yDataRowPosS(jj-1);
                                    end

                                    str        = strtrim(stringRowPos{jj});
                                    y          = nb_pos2pos(y,ax.yLim,[pos(2),pos(2) + pos(4)],ax.yScale,'normal');
                                    t(counter) = text(x,y,str,...
                                                      'clipping',           'off',...
                                                      'color',              cData,...
                                                      'fontName',           obj.fontName,...
                                                      'fontWeight',         obj.fontWeight,...
                                                      'fontUnits',          fontU,...
                                                      'fontSize',           fontS,...
                                                      'HorizontalAlignment','center',...
                                                      'parent',             obj.hgchild,...
                                                      'rotation',           obj.rotation);

                                    counter    = counter + 1;

                                end

                                yDataRowNeg  = yDataRow(yDataRow<0);
                                yDataRowNegS = cumsum(yDataRowNeg);
                                stringRowNeg = stringRow(yDataRow<0);
                                for jj = 1:size(yDataRowNeg,2)

                                    if jj == 1
                                        y    = yDataRowNeg(jj)/2;
                                    else
                                        y    = yDataRowNeg(jj)/2 + yDataRowNegS(jj-1);
                                    end

                                    str        = strtrim(stringRowNeg{jj});
                                    x          = nb_pos2pos(x,ax.xLim,[pos(1),pos(1) + pos(3)],ax.xScale,'normal');
                                    y          = nb_pos2pos(y,ax.yLim,[pos(2),pos(2) + pos(4)],ax.yScale,'normal');
                                    t(counter) = text(x,y,str,...
                                                      'color',              cData,...
                                                      'fontName',           obj.fontName,...
                                                      'fontWeight',         obj.fontWeight,...
                                                      'fontUnits',          fontU,...
                                                      'fontSize',           fontS,...
                                                      'HorizontalAlignment','center',...
                                                      'parent',             obj.hgchild,...
                                                      'rotation',           obj.rotation);

                                    counter    = counter + 1;

                                end

                            end

                            ind          = t == 0;
                            obj.children = t(~ind);

                        else % Grouped bar plots

                            barWidth = barHandle(bb).barWidth;

                            for ii = 1:size(yData,1)

                                n       = size(yData,2);
                                xTemp   = xData(ii) - barWidth/2 + barWidth/n/2 - barWidth/n;
                                for jj = 1:size(yData,2)

                                    y          = yData(ii,jj)/2;
                                    xTemp      = xTemp + barWidth/n;
                                    str        = stringT{ii,jj};
                                    xTempAx    = nb_pos2pos(xTemp,ax.xLim,[pos(1),pos(1) + pos(3)],ax.xScale,'normal');
                                    y          = nb_pos2pos(y,ax.yLim,[pos(2),pos(2) + pos(4)],ax.yScale,'normal');
                                    t(counter) = text(xTempAx,y,str,...
                                                      'color',              cData,...
                                                      'fontName',           obj.fontName,...
                                                      'fontWeight',         obj.fontWeight,...
                                                      'fontUnits',          fontU,...
                                                      'fontSize',           fontS,...
                                                      'HorizontalAlignment','center',...
                                                      'parent',             obj.hgchild,...
                                                      'rotation',           obj.rotation);

                                    counter    = counter + 1;

                                end

                            end

                            ind          = t == 0;
                            obj.children = t(~ind);
                            obj.children = t;

                        end

                    case 'top'

                        % Get the text on the bars
                        %------------------------------------------------------
                        switch obj.type

                            case 'default'

                                switch obj.decimals

                                    case 0
                                        regexp = '%0.0f';
                                    case 1
                                        regexp = '%0.1f';
                                    case 2
                                        regexp = '%0.2f';
                                    case 3
                                        regexp = '%0.3f';
                                    case 4 
                                        regexp = '%0.4f';
                                    otherwise
                                        regexp = '%0.4f';
                                        warning('nb_barAnnotation:plot:TooManyDeciamls',[mfilename ':: Maximal number of decimal points are reach. Force 4 decimals.'])
                                end

                                switch barHandle(bb).style

                                    case {'stacked','dec'}

                                        yD       = cumsum(yData,2);
                                        stringT   = cellstr(num2str(yD(:,end),regexp));
                                        yD       = yD(:,end);

                                    case 'grouped'

                                        stringT = cell(size(yData));
                                        for ii = 1:size(yData,2)
                                            stringT(:,ii) = cellstr(num2str(yData(:,ii),regexp));
                                        end

                                    otherwise

                                        error([mfilename ':: The style of the bar plot cannot be ' barHandle(bb).style '. Some properties ar not set correctly.'])

                                end

                                stringT = strtrim(stringT);

                                if strcmpi(obj.language,'norwegian') || strcmpi(obj.language,'norsk')
                                    stringT = strrep(stringT,'.',',');
                                end

                            case 'manual'

                                stringT = obj.string;
                                switch barHandle(bb).style

                                    case {'stacked','dec'}

                                        if any(size(stringT) ~= size(yData(:,1)))
                                            error([mfilename ':: The size (' int2str(size(stringT)) ') of the provided text to the ''string'' property do not match the size of the data (' int2str(size(yData)) ')'])
                                        end

                                    case 'grouped'

                                        if any(size(stringT) ~= size(yData))
                                            error([mfilename ':: The size (' int2str(size(stringT)) ') of the provided text to the ''string'' property do not match the size of the data (' int2str(size(yData)) ')'])
                                        end

                                    otherwise

                                        error([mfilename ':: The style of the bar plot cannot be ' barHandle(bb).style '. Some properties ar not set correctly.'])

                                end

                            otherwise

                                error([mfilename ':: The property ''type'' can only be set to ''default'' or ''manual''.'])

                        end

                        % Plot the annotation
                        %------------------------------------------------------
                        t       = zeros(1,size(yData,2)*size(yData,1));
                        counter =  1;
                        differ  = (max(max(yData,[],1),[],2) - min(min(yData,[],1),[],2))*obj.space;

                        if strcmpi(barHandle(bb).style,'stacked') || strcmpi(barHandle(bb).style,'dec')

                            for jj = 1:size(yD,1)

                                x    = xData(jj);
                                if yD(jj) >= 0
                                    y = yD(jj) + differ;
                                else
                                    y = yD(jj) - differ;
                                end
                                str        = strtrim(stringT{jj});
                                x          = nb_pos2pos(x,ax.xLim,[pos(1),pos(1) + pos(3)],ax.xScale,'normal');
                                y          = nb_pos2pos(y,ax.yLim,[pos(2),pos(2) + pos(4)],ax.yScale,'normal');
                                t(counter) = text(x,y,str,...
                                                  'color',              cData,...
                                                  'fontName',           obj.fontName,...
                                                  'fontWeight',         obj.fontWeight,...
                                                  'fontUnits',          fontU,...
                                                  'fontSize',           fontS,...
                                                  'HorizontalAlignment','center',...
                                                  'parent',             obj.hgchild,...
                                                  'rotation',           obj.rotation,...
                                                  'verticalAlignment',  'bottom');

                                counter    = counter + 1;

                            end

                            ind          = t == 0;
                            obj.children = t(~ind);

                        else % Grouped bar plots

                            barWidth = barHandle(bb).barWidth;
                            differ   = diff(barHandle(bb).parent.yLim)*obj.space;

                            for ii = 1:size(yData,1)

                                n       = size(yData,2);
                                xTemp   = xData(ii) - barWidth/2 + barWidth/n/2 - barWidth/n;
                                for jj = 1:size(yData,2)

                                    if yData(ii,jj) >= 0
                                        y = yData(ii,jj) + differ;
                                    else
                                        y = yData(ii,jj) - differ;
                                    end
                                    xTemp      = xTemp + barWidth/n;
                                    str        = stringT{ii,jj};
                                    xTempAx    = nb_pos2pos(xTemp,ax.xLim,[pos(1),pos(1) + pos(3)],ax.xScale,'normal');
                                    y          = nb_pos2pos(y,ax.yLim,[pos(2),pos(2) + pos(4)],ax.yScale,'normal');
                                    t(counter) = text(xTempAx,y,str,...
                                                      'color',              cData,...
                                                      'fontName',           obj.fontName,...
                                                      'fontWeight',         obj.fontWeight,...
                                                      'fontUnits',          fontU,...
                                                      'fontSize',           fontS,...
                                                      'horizontalAlignment','center',...
                                                      'parent',             obj.hgchild,...
                                                      'rotation',           obj.rotation,...
                                                      'verticalAlignment',  'bottom');

                                    counter    = counter + 1;

                                end

                            end

                            ind          = t == 0;
                            obj.children = t(~ind);

                        end

                    otherwise

                        error([mfilename ':: Unsupported location ' obj.location '.'])

                end
                
            end
            
            % Add a uicontext menu to the arrow
            %------------------------------------------------------
%             cMenu = uicontextmenu('parent',ax.parent.figureHandle); 
%                  uimenu(cMenu,'Label','Edit','Callback',@obj.editCallback);
%                  uimenu(cMenu,'Label','Delete','Callback',@obj.deleteCallback);
%             set(obj.hgchild,'UIContextMenu',cMenu)    
               
        end
        
        function editCallback(obj,~,~)
        % Callback function called when user click on the edit 
        % option of the uicontextmenu handle attached to the bar
        % annotation handle
            
            nb_editBarAnnotation(obj);
        
        end
        
        function deleteCallback(obj,~,~)
        % Callback function called when user click on the delete 
        % option of the uicontextmenu handle attached to the text
        % handle 
        
            nb_confirmWindow('Are you sure you want to delete the selected object?',@notDelete,{@deleteAnnotation,obj},'Delete Annotation');
            
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
        
        function obj = unstruct(s)
            
            obj                     = nb_barAnnotation();
            obj.color               = s.color;
            obj.decimals            = s.decimals;
            obj.force               = s.force;
            obj.language            = s.language;
            obj.location            = s.location;
            obj.rotation            = s.rotation;
            obj.space               = s.space;
            obj.string              = s.string;
            obj.type                = s.type;
            obj.fontName            = s.fontName;
            obj.fontSize            = s.fontSize;
            obj.fontUnits           = s.fontUnits;
            obj.fontWeight          = s.fontWeight;
            obj.normalized          = s.normalized;
            obj.deleteOption        = s.deleteOption;
            
        end
        
    end
    
end
