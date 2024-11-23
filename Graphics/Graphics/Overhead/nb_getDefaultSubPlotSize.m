function subPlotSize = nb_getDefaultSubPlotSize(num)
% Syntax:
%
% subPlotSize = nb_getDefaultSubPlotSize(num)
%
% Description:
%
% Get default sub plot size given the number of variables being plotted.
% Can be assign the 'subPlotSize' property of a nb_graph object.
% 
% Input:
% 
% - num : The number of plotted variables.
% 
% Output:
% 
% - subPlotSize : A 1 x 2 double with the default sub plot size.
%
% See also:
% nb_graph_ts.subPlotSize, nb_graph_cs.subPlotSize, 
% nb_graph_data.subPlotSize
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if num == 1
        subPlotSize = [1,1];
    elseif num == 2
        subPlotSize = [2,1];
    elseif num <= 4
        subPlotSize = [2,2];
    elseif num <= 6
        subPlotSize = [3,2];
    elseif num <= 9
        subPlotSize = [3,3]; 
    elseif num <= 12
        subPlotSize = [4,3];
    else
        subPlotSize = [4,4];
    end
    
end
