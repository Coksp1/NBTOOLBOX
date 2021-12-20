function plotter = plotCalculated(obj,calendar)
% Syntax:
%
% plotter = plotCalculated(obj,calendar)
%
% Description:
%
% Plot calculated series of the object.
% 
% Input:
% 
% - obj      : An object of class nb_calculate_vintages.
%
% - calendar : The calendar to use for selecting the contexts to plot the
%              calculated series of. Must be of class nb_calendar. Default  
%              is nb_lastCalendar. To return all use nb_allCalendar.
%
% Output:
% 
% - plotter : An object of class nb_graph_ts. Use the graph method or the
%             nb_graphPagesGUI class to display the graphs.
%
% See also:
% nb_graph_ts
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        calendar = nb_lastCalendar();
    end

    if numel(obj) > 1
        error([mfilename ':: The obj input must be a scalar nb_calculate_vintages.'])
    end
    if nb_isempty(obj.results)
        error([mfilename ':: No calculation results available.'])
    end
    
    % Get the contexts selected by the calendar
    calendarD = getCalendar(calendar,'','',obj,false,true);
    index     = nb_calendar.doOneModel(obj.results.data.dataNames,calendarD);
    index     = unique(index);
    
    % Construct plotter object
    plotter = nb_graph_ts(permute(keepPages(obj.results.data,index))); %#ok<LTARG>
    plotter.set('noLegend',true)

end
