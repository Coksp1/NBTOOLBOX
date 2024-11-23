function plotter = plot(obj,varargin)
% Syntax:
% 
% plot(obj,varargin)
% plotter = plot(obj,varargin)
%
% Description:
%
% Plot the data of the nb_dataSource object.
%
% Caution: If the data of the object is of class nb_distribution this
%          method will redirect to plotDist.
% 
% Input:
% 
% - obj      : An object of class nb_ts, nb_cs or nb_data
% 
% - plotType : A string with either:
%
%                 > 'graph'   (Default)
% 
%                 > 'graphSubPlots'
% 
%                 > 'graphInfoStruct'
% 
%              The name of the graphing method of the class
%              nb_graph_ts, nb_graph_cs or nb_graph_data.
%
%              Caution: This is an optional input. If not given it is
%              assumed that the optional input pairs are starting from the 
%              second input to this function. 
% 
% - varargin : Same as the input to the method set() of the  
%              nb_graph_ts, nb_graph_cs or nb_graph_data class.
% 
%              I.e. ...,'inputName', inputValue,...
%
%              Caution: If the data of the object is of class 
%                       nb_distribution, see nb_ts.plotDist for the
%                       optional input pairs supported.
% 
% Output:
% 
% Plotted output
% 
% Examples:
% 
% plot(obj)
% 
% plot(obj,'graphSubPlots')
% 
% plot(obj,'','startGraph','2008Q1','endGraph','2011Q2')
% 
%   same as
% 
% plot(obj,'graph','startGraph','2008Q1','endGraph','2011Q2')
% 
% See also:
% nb_graph_ts, nb_ts.plotDist
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin == 1
        loc = 1;
    else
        [ind,loc] = nb_ismemberi(varargin{1},{'graph','graphSubPlots','graphInfoStruct'});
        if ind 
            varargin = varargin(2:end);
        else
            loc = 1;
        end
    end
    
    if isa(obj.data,'nb_distribution')
        if isa(obj,'nb_ts')
            plotter = plotDist(obj,'graph',varargin{:});
        else
            error([mfilename ':: Cannot plot nb_cs or nb_data objects storing nb_distribution objects as data.'])
        end
        return
    end
    
    % Initialize the graphing object
    if isa(obj,'nb_ts')
        plotterT = nb_graph_ts(obj);
    elseif isa(obj,'nb_cs')
        plotterT = nb_graph_cs(obj);
    elseif isa(obj,'nb_data')
        plotterT = nb_graph_data(obj);
    else
        error([mfilename ':: There is no way to plot an object of class ' class(obj)])
    end
    plotterT.set(varargin);

    % Do the plotting
    if nargout == 0
        switch loc
            case 1
                plotterT.graph();
            case 2
                plotterT.graphSubPlots();
            case 3
                plotterT.graphInfoStruct();
            otherwise
                error([mfilename ':: The class nb_graph_ts has no graphing method; ' plotType '(...)'])
        end
    else
        plotter = plotterT;
    end
    
end
