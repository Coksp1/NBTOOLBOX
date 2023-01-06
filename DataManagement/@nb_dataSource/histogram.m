function [data,plotter] = histogram(obj,M)
% Syntax:
%
% data           = histogram(obj)
% [data,plotter] = histogram(obj,M)
%
% Description:
%
% Create a histogram of a object containing only one variable and one page!
% 
% Input:
% 
% - obj     : A nb_dataSource object with size N x 1 x 1.
%
% - M       : The number of bins of the histogram.
% 
% Output:
% 
% - data    : A nb_cs object with size M x 1 x 1.
%
% - plotter : A nb_graph_cs object with the histogram plotted.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        M = [];
    end
    if isempty(M)
        M = 10;
    end

    if obj.numberOfVariables ~= 1
        error('The number of variables must be 1.')
    end
    if obj.numberOfDatasets ~= 1
        error('The number of variables must be 1.')
    end

    maxLim = max(obj.data);
    minLim = min(obj.data);
    stdD   = nanstd(obj.data);
    stdStr = num2str(stdD);
    indDot = strfind(stdStr,'.');
    if ~isempty(indDot)
        round2 = 1;
        kk     = indDot + 1;
        while kk < size(stdStr,2)
            if ~strcmp(stdStr(kk),'0')
                break;
            end
            round2 = round2 + 1;
            kk     = kk + 1;
        end
        maxLim = ceil(maxLim*10^round2)/(10^round2);
        minLim = floor(minLim*10^round2)/(10^round2);
    end
    x = linspace(minLim,maxLim,M);
    
    counts = nb_histcounts(obj.data,x);
    
    intervals = strtrim(cellstr(num2str(x')));
    intervals = strcat(intervals(1:end-1),{' - '},intervals(2:end));
    data      = nb_cs(counts(2:end),'',intervals,obj.variables);
    
    if nargout > 1
        plotter = nb_graph_cs(data);
        plotter.set('plotType','grouped','barWidth',1,'xTickRotation',10);
    end

end
