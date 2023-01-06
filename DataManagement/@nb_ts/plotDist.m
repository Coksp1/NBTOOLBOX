function f = plotDist(obj, varargin)
% Syntax:
%
% f = plotDist(obj, varargin)
%
% Description:
%
% A method for plotting the data of an nb_ts object when it is of type
% nb_distribution. It allows for both 2D and 3D plots.
% 
% Input:
% 
%  - obj : An nb_ts object.
%
% Optional input:
%
% - '3d'         : Either true or false. If true, the method will create a 
%                  3D-plot. Otherwise it will return 2D plots. Default is 
%                  false.
%
% - 'type'       : What type of distribution to plot, either cdf or pdf. 
%                  As string.
%
% - 'function'   : Either 'surf' or 'mesh', depending on how you want the
%                  surface of the 3D-plot to look like.
%
% - 'angle'      : Allows for adjusting the angle of the X-labels. Default 
%                  is 60.
%
% - 'startGraph' : Sets the start date of the plot. Default is the start 
%                  date of the data.  As a string or as an object of class 
%                  nb_date.
%
% - 'endGraph'   : Sets the end date of the plot. Default is the end date 
%                  of the data. As a string or as an object of class 
%                  nb_date.
%
% - Other optional inputs: See the nb_graph_data class.
% 
% Output:
% 
% - f : Either a MATLAB figure or a nb_graph_data object.
%
% Examples:
%
% First create some data:
% obj = nb_ts(randn(1000,2),'','2010M1',{'v1','v2'})
% 
% Recursively estimate a pdf of the data:
% rD = obj.ksdensity('recStart','2012M1','recEnd','2030M1', 'recursive',1)
% 
% Create a 3D-plot
% rD.plotDist('3d',1)
%
% See also:
% nb_ts.plot
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    [d3,   inputs] = nb_parseOneOptional('3d',false,varargin{:});
    [x,    inputs] = nb_parseOneOptional('x','',inputs{:});
    [type, inputs] = nb_parseOneOptional('type','pdf',inputs{:});
    [func, inputs] = nb_parseOneOptional('function','surf',inputs{:});
    [angl, inputs] = nb_parseOneOptional('angle',60,inputs{:});
    
    
    if obj.numberOfObservations == 1
        % If the object contains only one nb_distrbution object
        N            = obj.numberOfVariables;
        plotter(1,N) = nb_graph_data;
        for ii = 1:N
            plotter(1,ii) = obj.data(1,ii).plot();
        end
    else
        
        [startGraph, inputs] = nb_parseOneOptional('startGraph','',inputs{:});
        [endGraph,   inputs] = nb_parseOneOptional('endGraph','',inputs{:});
        if isempty(startGraph)
            startGraph = obj.startDate;
        else
            startGraph = interpretDateInput(obj,startGraph);
        end
        if isempty(endGraph)
            endGraph = obj.endDate;
        else
            endGraph = interpretDateInput(obj,endGraph);
        end

        obj = window(obj,startGraph,endGraph);
        if ~d3
            N            = obj.numberOfVariables;
            plotter(1,N) = nb_graph_data;
            for ii = 1:N
                plotter(:,ii) = obj.data(:,ii).plot();
            end
        else
            
            % If the object contains multiple nb_distrbution objects, allow for
            % 3d plots
            N                   = obj.numberOfVariables;
            f                   = nb_gobjects(1,N);
            [xTick,xTickLabels] = getXTickLabel(obj,inputs{:});
            for ii = 1:N
                
                [f(ii),ax,p] = plot3d(obj.data(:,ii),x,type,func);
                set(ax, 'XTickLabel',xTickLabels);
                set(ax, 'XTickLabelRotation', angl);
                set(ax, 'XTick',xTick);
                title(ax,obj.variables(ii));
                if strcmp(func,'surf')
                    set(p,'LineStyle','none')
                end
                
            end
            
        end
        
    end     
    
end

%==========================================================================
function [xTick,xTickLabels]  = getXTickLabel(obj,varargin)

    [xTickFrequency,inputs] = nb_parseOneOptional('xTickFrequency','',varargin{:});
    [spacing,    inputs]    = nb_parseOneOptional('spacing','',inputs{:});
    [xTickStart, inputs]    = nb_parseOneOptional('xTickStart','',inputs{:});
    [language,   ~]         = nb_parseOneOptional('language','english',inputs{:});
    if ~isempty(xTickFrequency)
        freq = nb_date.getFrequencyAsInteger(xTickFrequency);
    else
        if obj.frequency == 365
            freq = 1;
        else
            freq = obj.frequency;
        end
    end

    % Find the start end end dates given the wanted frequency
    if freq == obj.frequency
        start  = obj.startDate;
        finish = obj.endDate;
    else
        start  = obj.startDate.getDate(freq);
        finish = obj.endDate.getDate(freq);  
    end

    % Find the spacing between ticks if not given
    
    
    if isempty(spacing)
        space = nb_graph_ts.findXSpacing(start,finish); 
    else
        if ~nb_isScalarInteger(spacing)
            error([mfilename ':: The spacing you set must be an integer.'])
        end
        if spacing < 1
            error([mfilename ':: The spacing value must be larger than 1.'])
        end
        space = spacing;
    end

    % Find the x-tick marks
    periods = obj.endDate - obj.startDate;
    switch language
        case {'english','engelsk'}
            [xTickdates,locations] = obj.startDate.toDates(0:periods,'NBEnglish',freq);
        case {'norsk','norwegian'}
            [xTickdates,locations] = obj.startGraph.toDates(0:periods,'NBNorsk',freq);
        otherwise
            error([mfilename ':: The language ' language ' is not supported by this function.'])
    end

    if ~isempty(xTickStart)
        startX = nb_date.toDate(xTickStart,freq);
        startX = startX - start + 1;
        if startX < 1
            startX = 1;
        end   
    else
        startX = 1;
    end

    % Find the final x-ticks marks given the spacing and assign 
    % the properties of the object
    xTick       = locations(startX:space:end);
    xTickLabels = xTickdates(startX:space:end);

end
