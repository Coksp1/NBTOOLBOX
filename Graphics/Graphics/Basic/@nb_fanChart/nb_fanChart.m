classdef nb_fanChart < nb_plotHandle
% Syntax:
%     
% obj = nb_fanChart(xData,yData,varargin)
% 
% Superclasses:
% 
% handle, nb_plotHandle
%     
% Description:
%     
% This is a class for plotting fan chart.  
%     
% Constructor:
%     
%     nb_fanChart(yData)
%     nb_fanChart(xData,yData)  
%     nb_fanChart(xData,yData,'propertyName',propertyValue,...)
%     handle = nb_fanChart(xData,yData,'propertyName',...
%                          propertyValue,...)
%     
%     Input:
% 
%     - xData    : The xData of the plotted data. Must be of size;
%                  size(yData,1) x 1 or 1 x size(yData,1)
%                        
%     - yData    : The yData of the plot. The columns are counted 
%                  as different simualations. And on the basis of this  
%                  data the confidence intervals are calculated.
%         
%     - varargin : ...,'propertyName',propertyValue,...
%     
%     Output
% 
%     - obj      : An object of class nb_fanChart
%     
%     Examples:
%
%     obj = nb_fanChart(rand(2,100)); % Provide only y-axis data
%     obj = nb_fanChart([1,2],rand(2,100));
%     obj = nb_fanChart(rand(2,100),'propertyName',propertyValue,...)
%     obj = nb_fanChart([1,2],rand(2,100),'propertyName',...
%                        propertyValue,...)    
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    %======================================================================
    % Properties of the class
    %======================================================================
    properties(SetAccess=protected)
        
        % The children of the plot, as MATLAB patch handles.
        children = [];                  
          
    end
    properties
       
        % Transparency of fan chart. A double between 0 and 1. 0 fully 
        % transparent, 1 opaque.
        alpha               = 1;
        
        % Either double with the RGB color specification for each 
        % percentile, or a string with the color specification to 
        % use ({'nb'} | 'red' | 'green' | 'yellow' | '')
        cData               = 'nb'; 
        
        % An nb_line object with the mean, if you set this as a 
        % string the mean will not be plotted
        central             = [];
        
        % 'all' | {'only'}. If 'all' is given the object will be 
        % delete and all that is plotted by this object are 
        % removed from the figure it is plotted on. If on the 
        % other hand 'only' is given, it will just delete the 
        % object.
        deleteOption        = 'only'; 
        
        % {'off'} : The mean line will not be included in the 
        % legend. 'on' : included it in the legend
        legendInfo          = 'on';               
        
        % The line width of center of the fan. See also property center.
        lineWidth           = 2.5; 
        
        % {'percentiles'} | 'hdi'; Which type of fan chart is going to be
        % made. 'percentiles' are produced by using percentiles, while 
        % 'hdi' use highest density intervals
        method             = 'percentiles';
        
        % The percentiles as 1 x numberOfPercentiles double. E.g:
        % [.3,.5,.7,.9] (Which is default)
        percentiles         = [.3,.5,.7,.9];
        
        % {'left'} | 'right' ; Which axes to plot on. Only if the 
        % parent is off class nb_axes. (Which is the default)
        side                = 'left';   
        
        % Set the visibility of the fan chart.
        visible             = 'on'; 
        
        % The x-axis data. Should be a vector.
        xData               = [];               
        
        % Each column of the yData property is counted as one 
        % simualation. And on the basis of this data the confidence 
        % intervals are calculated.
        %
        % If this input has more than one page, it will count each page
        % as a seperate variable, and each variable will get its own
        % fan around the central tendency. In this case percentiles 
        % property must be set to a 1x1 double.
        yData               = [];               
        
    end
    
    %======================================================================
    % Protected properties of the class
    %======================================================================
    properties (Access=protected)
        
        highest             = [];
        lowest              = [];
        type                = 'patch';
        
    end
    
    %======================================================================
    % Accessible methods
    %======================================================================
    methods
        
        function set.alpha(obj,value)
            if ~nb_isScalarNumber(value) && ~(value <= 1 && value >=0)
                error([mfilename ':: The alpha property must be'...
                    ' set to a double contained in [0,1].'])
            end
            obj.alpha = value;
        end
        
        function set.cData(obj,value)
            if ~nb_isColorProp(value,true)
                error([mfilename ':: The cData property must'...
                    ' must have dimension size'...
                    ' size(plotData,2) x 3 with the RGB'...
                    ' colors or a cellstr with size 1 x'...
                    ' size(yData,2) with the color names.'])
            end
            obj.cData = value;
        end
        
        function set.central(obj,value)
            if ~isa(value,'nb_line') && ~isempty(value)
                error([mfilename ':: The central property must be'...
                    ' given as an nb_line object or empty.'])
            end
            obj.central = value;
        end
        
        function set.deleteOption(obj,value)
            if ~any(strcmp({'all','only'},value))
                error([mfilename '::  The deleteOption property must be'...
                    ' either ''all'' or ''only''.'])
            end
            obj.deleteOption = value;
        end
        
        function set.legendInfo(obj,value)
            if ~~any(strcmp({'off','on'},value))
                error([mfilename '::  The legendInfo property must be '...
                    'either ''on'' or ''off''.'])
            end
            obj.legendInfo = value;
        end
        
        function set.lineWidth(obj,value)
            if ~isscalar(value)
                error([mfilename ':: The lineWidth property must be'...
                    ' set to a scalar double.'])
            end
            obj.lineWidth = value;
        end
        
        function set.method(obj,value)
            if isempty(value)
                value = 'percentiles';
            elseif ~any(strcmp({'percentiles','hdi'},value))
                error([mfilename '::  The method property must be '...
                    'either empty, ''percentiles'' or ''hdi''.'])
            end
            obj.method = value;
        end
        
        function set.percentiles(obj,value)
            if ~isa(value,'double') && ~isempty(value)
                error([mfilename ':: The percentiles property must be'...
                    ' given as a double vector or empty.'])
            end
            obj.percentiles = value;
        end
        
        function set.side(obj,value)
            if ~any(strcmp({'left','right'},value))
                error([mfilename '::  The side property must be '...
                    'either ''right'' or ''left'' (default).'])
            end
            obj.side = value;
        end
        
        function set.visible(obj,value)
            if ~~any(strcmp({'on','off'},value))
                error([mfilename '::  The visible property must be '...
                    'either ''on'' or ''off''.'])
            end
            obj.visible = value;
        end
        
        function set.xData(obj,value)
            if ~any(ismember(size(value),1)) && ~isa(value,'double') && ...
                    ~isempty(value)
                error([mfilename ':: The xData property must be'...
                    ' of size; size(yData,1) x 1 or'...
                    ' 1 x size(yData,1).'])
            end
            obj.xData = value;
        end
        
        function set.yData(obj,value)
            if ~isa(value,'double') && ~isempty(value)
                error([mfilename ':: The yData property must be'...
                    ' given as a double.'])
            end
            obj.yData = value;
        end
        
        
        function obj = nb_fanChart(xData,yData,varargin)
            
            if nargin < 2
                
                if nargin == 1
                    obj.yData = xData;
                    obj.xData = 1:size(xData,1);
                else
                    obj.xData = [0;1];
                    obj.yData = rand(2,50);
                end
                
            else
                
                if ~isnumeric(yData)
                    obj.yData = xData;
                    obj.xData = 1:size(xData,1);
                    varargin  = [yData,varargin];
                else
                    obj.xData = xData;
                    obj.yData = yData;
                end
                
            end
            
            if nargin > 2
                obj.set(varargin);
            else
                plotFan(obj);
            end
            
            
        end
        
        varargout = set(varargin)
        varargout = get(varargin)
        
        function lineWidth = get.lineWidth(obj)
            lineWidth = nb_scaleLineWidth(obj,obj.lineWidth);
        end
        
        %{
        ---------------------------------------------------------------
        Delete the object
        ---------------------------------------------------------------
        %}
        function delete(obj)
            
            % Remove it form its parent
            if isa(obj.parent,'nb_axes')
                if isvalid(obj.parent)
                    obj.parent.removeChild(obj);
                end
            end
            
            if strcmpi(obj.deleteOption,'all')
                
                % Delete all the children of the object
                for ii = 1:size(obj.children,2)
                    
                    if ishandle(obj.children(ii))
                        
                        % Then delete
                        delete(obj.children(ii))
                        
                    end
                    
                end
                
            end
            
        end
        
        %{
        -------------------------------------------------------------------
        Find the x-axis limits of this object
        -------------------------------------------------------------------
        %}
        function xlimit = findXLimits(obj)
            
            xlimit = [min(obj.xData),max(obj.xData)];
            
        end
        
        %{
        -------------------------------------------------------------------
        Find the y-axis limits of this object
        -------------------------------------------------------------------
        %}
        function ylimit = findYLimits(obj)
            
            % Find the method to use
            if isa(obj.parent,'nb_axes')
                meth   = obj.parent.findAxisLimitMethod;
                if isa(obj.parent.parent,'nb_figure')
                    fig = obj.parent.parent.figureHandle;
                else
                    fig = obj.parent.parent;
                end
            else
                meth   = 4;
                fig    = get(obj.parent,'parent');
            end
            dataLow  = obj.lowest;
            dataHigh = obj.highest;
            ylimit   = nb_plotHandle.findLimitsAlgo(dataLow,dataHigh,meth,fig);
            
        end
        
        %{
        -------------------------------------------------------------------
        Set the visible property of this handle and all the children
        (Without replotting) This method should only be called from the
        parent, when its visible property is set to 'off'
        -------------------------------------------------------------------
        %}
        function setVisible(obj)
            
            obj.visible = get(obj.parent,'visible');
            obj.central.setVisible();
            
        end
        
        function legendDetails = getLegendInfo(obj)
            
            % Get the legend info from the central line
            legendDetails = obj.central.getLegendInfo();
            
        end
        
    end
    
    %======================================================================
    % Protected methods
    %======================================================================
    methods (Access=protected)
        
        %{
        -------------------------------------------------------------------
        Plot the fan chart
        -------------------------------------------------------------------
        %}
        function plotFan(obj)
            
            %--------------------------------------------------------------
            % Delete the current handles
            %--------------------------------------------------------------
            if ~isempty(obj.children)
                for ii = 1:length(obj.children)
                    delete(obj.children(ii));
                end
                obj.children = [];
            end
            
            %--------------------------------------------------------------
            % Decide the parent (axes to plot on)
            %--------------------------------------------------------------
            if isempty(obj.parent)
                obj.parent = nb_axes();
                if strcmpi(obj.side,'right')
                    axh = obj.parent.plotAxesHandleRight;
                else
                    axh = obj.parent.plotAxesHandle;
                end
            else  
                if isa(obj.parent,'nb_axes')
                    if strcmpi(obj.side,'right')
                        axh = obj.parent.plotAxesHandleRight;
                    else
                        axh = obj.parent.plotAxesHandle;
                    end
                else
                    axh = obj.parent;
                end 
            end
            
            %--------------------------------------------------------------
            % Test the properties
            %--------------------------------------------------------------
            if size(obj.xData,1) == 1
                obj.xData = obj.xData';
            end
            
            if size(obj.xData,1) ~= size(obj.yData,1)
                error([mfilename ':: The ''xData'' and the ''yData'' properties has not the same number of rows.'])
            end
            
            if size(obj.xData,2) ~= 1
                error([mfilename ':: The ''xData'' property can anly have one columns or one row.']) 
            end
            
            if isempty(obj.percentiles)
                return
            end
            
            if size(obj.percentiles,2) == 1
                obj.percentiles = obj.percentiles';
            end
            obj.percentiles = sort(obj.percentiles);
            
            % Get the color data
            if ~strcmpi(obj.method,'shaded')
                if size(obj.yData,3) > 1
                    opengl('software')
                    if isempty(obj.cData) || ischar(obj.cData)
                        obj.cData = nb_defaultColors(size(obj.yData,3));
                        %obj.cData = nb_alpha(obj.cData,ones(3,3),obj.alpha,1);         
                    else
                        if size(obj.cData,1) ~= size(obj.yData,3)
                            error([mfilename ':: When size(yData,3) > 1 the cData property must have size size(yData,3) x 3.'])
                        end
                    end
                    if numel(obj.percentiles) > 1
                        error([mfilename ':: When size(yData,3) > 1 the percentiles input must be 1x1.'])
                    end
                else
                    obj.cData = nb_getFanColors(obj.cData,obj.percentiles);
                end
            end
            
            % Get intervals
            data = obj.yData;
            if strcmpi(obj.method,'shaded')
            
                if size(data,3) > 1
                    error([mfilename ':: The data cannot have more than 1 page if the method property is set to shaded.'])
                end
                perc = nb_interpretPerc(obj.percentiles,false);
                if size(data,2) == size(perc,2)
                    
                    % Interpolate
                    newPerc              = perc(1):perc(end);
                    newPerc(newPerc==50) = [];
                    
                    % Find indexed
                    nNewP = length(newPerc);
                    nPerc = length(perc);
                    ind   = nan(1,nPerc);
                    for ii = 1:nPerc
                        ind(ii) = find(abs(perc(ii) - newPerc) < eps^(1/2));
                    end
                    dataT                  = transpose(data);
                    dataT                  = sort(dataT,1);
                    plottedData            = nan(nNewP,size(dataT,2));
                    plottedData(ind,:)     = dataT;
                    plottedData            = transpose(nb_interpolate(plottedData,'linear'));
                    upp                    = plottedData(:,end:-1:nNewP/2+1);
                    low                    = plottedData(:,1:nNewP/2);
                    plottedData(:,1:2:end) = low;
                    plottedData(:,2:2:end) = upp;
                    numberOfPercentiles    = size(plottedData,2);
                    
                elseif size(data,2) > 500
                    error([mfilename ':: When method is shaded the data must have the same as the number of percentiles (' int2str(size(perc,2)) ').'])
                else
                    error([mfilename ':: When method is shaded the data must have the same as the number of percentiles (' int2str(size(perc,2)) ').'])
                end
                
                % Assign some properties used to find the axis limits later
                obj.lowest  = min(plottedData,[],2);
                obj.highest = max(plottedData,[],2);
                limInd      = cell(1,numberOfPercentiles);
                percs       = 0.02:0.02:obj.percentiles(end);
                lims        = percs*100; 
                lims        = flip(lims,2);
                lims        = strtrim(cellstr(num2str(lims')))';
                app         = {'lb1_','ub1_'};
                for ii = 1:numberOfPercentiles/2
                    ind         = 1+(ii-1)*2:ii*2;
                    limInd(ind) = strcat(app,lims{ii});
                end
                
                % Find the colors of the shading
                incr   = (1 - 0.5)/(numberOfPercentiles/2 - 1);
                percC  = 0.5:incr:1;
                if isnumeric(obj.cData)
                    if size(obj.cData,2) ~= 3
                        error([mfilename ':: The ''cData'' property must be a Mx3 matrix with the rgb colors of the plotted data.'])
                    else
                        colors = percC'*obj.cData(end,:);
                    end
                else
                    switch lower(obj.cData)
                        case 'nb'
                            colorsT = nb_getFanColors(obj.cData,zeros(1,4));
                            colorsT = [colorsT;1,1,1];
                            colors  = nan(numberOfPercentiles/2,3);
                            ind     = nan(1,5);
                            locFor  = [0.02,obj.percentiles];
                            for ii = 1:5
                                ind(ii) = find(abs(locFor(ii) - percs) < eps^(1/2));
                            end
                            colors(ind,:) = colorsT;
                            colors        = nb_interpolate(colors,'linear');
                        otherwise
                            colors = percC'*[1,1,1];
                    end
                end
                
            elseif strcmpi(obj.method,'hdi')
                
                [plottedData,limInd] = nb_hdi(data,obj.percentiles,2);
                
                % Assign some properties used to find the axis limits later
                obj.lowest          = min(min(plottedData,[],2),[],3);
                obj.highest         = max(max(plottedData,[],2),[],3);
                numberOfPercentiles = size(obj.percentiles,2)*2;
                percs               = obj.percentiles;
                colors              = obj.cData;
                
            else % percentiles
           
                % Get the index of the percentile (after the data is sorted)
                if size(data,2) == size(obj.percentiles,2)*2
                    % Each column of the data hopefully represent a percentile 
                    percentilIndexes = 1:size(data,2);
                    percentilIndexes = percentilIndexes(:);
                else
                    percentilIndexes                             = round((0.5 + [-obj.percentiles(:), obj.percentiles(:)]/2)*size(data,2));
                    percentilIndexes(percentilIndexes(:,1)==0)   = 1; % make sure that lower bound is at least the first element
                    percentilIndexes                             = sort(percentilIndexes(:));
                end
                numberOfPercentiles = size(percentilIndexes,1);

                % Sort the data
                data = sort(data,2,'ascend');
                try
                    % Lower percentiles
                    plottedData = nan(size(data,1),numberOfPercentiles,size(data,3));
                    for ii = 1:numberOfPercentiles/2
                        plottedData(:,ii*2-1,:) = data(:,percentilIndexes(numberOfPercentiles/2-ii+1),:);
                    end

                    % Upper percentiles
                    for ii = 1:numberOfPercentiles/2
                        plottedData(:,ii*2,:) = data(:,percentilIndexes(numberOfPercentiles/2 + ii),:);
                    end

                catch   %#ok<CTCH>
                    error([mfilename ':: The number of columns of the ''yData'' property (' int2str(size(obj.yData,2)) ') is less then the '...
                                     'number of percentiles you are trying to plot. (' int2str(numberOfPercentiles/2) '). Which of course is not possible.'])              
                end
                
                % Assign some properties used to find the axis limits later
                obj.lowest  = min(plottedData(:,end-1,:),[],3);
                obj.highest = max(plottedData(:,end,:),[],3);
                limInd      = cell(1,numberOfPercentiles);
                lims        = obj.percentiles*100;
                lims        = strtrim(cellstr(num2str(lims')))';
                app         = {'lb1_','ub1_'};
                for ii = 1:numberOfPercentiles/2
                    ind         = 1+(ii-1)*2:ii*2;
                    limInd(ind) = strcat(app,lims{ii});
                end
                percs  = obj.percentiles;
                colors = obj.cData;
                
            end
            
            %--------------------------------------------------------------
            % Do the plotting
            %--------------------------------------------------------------
            if size(obj.yData,3) > 1
                
                num   = size(plottedData,3);
                hh    = nan(1,num);
                x     = obj.xData; 
                low   = plottedData(:,1,:);         
                upp   = plottedData(:,2,:);
                for ii = 1:num
                    hh(ii) = plotOne(obj,axh,x,low(:,:,ii),upp(:,:,ii),obj.cData(ii,:));
                end
%                 mLow  = max(low,[],3);
%                 mUpp  = min(upp,[],3);
%                 cc    = nb_alpha(obj.cData(1,:),obj.cData(2,:),obj.alpha,1); 
%                 hh(1) = plotOne(obj,axh,x,mLow,mUpp,cc);
%                 
%                 ind1        = low(:,1,1) < low(:,1,2);
%                 [low1,upp1] = nb_fanChart.correct(ind1,low,mLow,1,2);
%                 hh(2)       = plotOne(obj,axh,x,low1,upp1,obj.cData(1,:));
%                 
%                 ind2        = low(:,1,1) > low(:,1,2);
%                 [low2,upp2] = nb_fanChart.correct(ind2,low,mLow,2,1);
%                 hh(3)       = plotOne(obj,axh,x,low2,upp2,obj.cData(2,:));
%                 
%                 ind1        = upp(:,1,1) > upp(:,1,2);
%                 [low1,upp1] = nb_fanChart.correct(ind1,upp,mUpp,2,1);
%                 hh(4)       = plotOne(obj,axh,x,low1,upp1,obj.cData(1,:));
%                 
%                 ind2        = upp(:,1,1) < upp(:,1,2);
%                 [low2,upp2] = nb_fanChart.correct(ind2,upp,mUpp,1,2);
%                 hh(5)       = plotOne(obj,axh,x,low2,upp2,obj.cData(2,:));
                
            else
            
                x  = obj.xData;
                hh = [];
                for ii = numberOfPercentiles/2:-1:1

                    % Starting from the widest fan layers
                    color = colors(ii,:);
                    for jj = 1:3
                        ind = find(strcmpi(['lb' int2str(jj) '_' int2str(percs(ii)*100)],limInd));
                        if ~isempty(ind)
                            low    = plottedData(:,ind);         
                            upp    = plottedData(:,ind+1); 
                            hh     = [hh,plotOne(obj,axh,x,low,upp,color)]; %#ok<AGROW>
                        end
                    end

                end
                
            end
            
            %--------------------------------------------------------------
            % Assign the children
            %--------------------------------------------------------------
            obj.children = hh;
            
            %--------------------------------------------------------------
            % Get the mean
            %--------------------------------------------------------------
            meanData = mean(data,2);
            
            %--------------------------------------------------------------
            % Plot the mean data, if not set to 'none'
            %--------------------------------------------------------------
            if ~ischar(obj.central)
                c = [];
                for ii = 1:size(obj.yData,3)
                    c = nb_line(obj.xData,meanData(:,:,ii),...
                                  'lineWidth',obj.lineWidth,...
                                  'parent',axh,...
                                  'visible',obj.visible);
                end
                obj.central = c;
            end
            
            %--------------------------------------------------------------
            % Correct the axes
            %--------------------------------------------------------------
            if isa(obj.parent,'nb_axes')
                
                % Update the axes given the plotted data
                obj.parent.addChild(obj);
                 
            end
            
        end
        
        function hh = plotOne(obj,axh,x,low,upp,cData)
                
            good   = ~isnan(low) & ~isnan(upp);
            filled = [upp(good);flipud(low(good))];
            xTemp  = x(good);
            xTemp  = [xTemp(:);flipud(xTemp(:))];

            hh = patch(xTemp,filled,cData,...
                           'clipping',  'on',...
                           'edgeColor', 'w',...
                           'faceAlpha', obj.alpha,...
                           'edgeAlpha', 1,...
                           'lineStyle', 'none',...
                           'parent',    axh,...
                           'visible',   obj.visible);

            % Remove it form the legend object
            set(get(get(hh,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

        end
            
    end
    
    %======================================================================
    % Static methods of the class
    %======================================================================
    methods (Static=true,Hidden=true)
        
%         function [low,upp] = correct(ind,limit,m,i1,i2)
%             
%             T        = size(m,1);
%             low      = nan(T,1);
%             upp      = low;
%             low(ind) = limit(ind,1,i1);
%             upp(ind) = limit(ind,1,i2);
%             
%             loc                    = find(ind);
%             locN                   = find(~ind) + 1;
%             loc                    = intersect(loc,locN);
%             loc1                   = loc - 1;
%             loc1(loc1<1)           = [];
%             low(loc1)              = m(loc1);
%             upp(loc1)              = m(loc1);
%             loc2                   = loc + 1;
%             loc2(loc2>length(ind)) = [];
%             low(loc2)              = m(loc2);
%             upp(loc2)              = m(loc2);
%             
%         end
        
    end
    
end
