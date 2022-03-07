function x1 = adjustForMissing(obj,x0)
% Syntax:
% 
% adjustForMissing(obj,x0)
% 
% Description:
% 
% Adjust the x-value of a vertical graph element for graph objects of type
% nb_graph_bd. This is necessary as x0 represent how many periods after the
% startGraph property the vertical element should be drawn, but since we
% may have missing values, this is not only date - startGraph + 1.
%
% Input:
% 
% - obj : An object of class nb_graph_bd.
% 
% - x0  : Integer. Periods after startGraph for which the element should be
%         drawn.
%
% Output:
%
% - x1 : The corrected number of periods after startGraph the vertical
%        element should be drawn.
%
% See also:
% nb_graph_bd, nb_graph_bd.graph
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obs     = obj.xDates;
    date    = x0 + obj.startGraph - 1;
    datestr = date.toString();
    
    [inDates,idx] = ismember(datestr,obs);
    if inDates
        x1 = idx;
    else
        x1 = nan;
        for ii = 1:length(obs)
            date    = date - ii;
            datestr = date.toString();
            [inDates,idx] = ismember(datestr,obs);
            if inDates
                x1 = idx + 0.5;
                break
            end
        end
        if isnan(x1)
            error([mfilename ':: Failed to find the location of where to place '...
                             'the vertical element.'])
        end
    end

end
