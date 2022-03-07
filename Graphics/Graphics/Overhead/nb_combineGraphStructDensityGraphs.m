function plotter = nb_combineGraphStructDensityGraphs(varargin)
% Syntax:
%
% plotter = nb_combineGraphStructDensityGraphs(varargin)
%
% Description:
%
% Inputs are nb_graph_ts objects where each object uses the fanDatasets
% property in combination with GraphStruct property.
% 
% Input:
% 
% - varargin : Every second input starting with the first must be the a 
%              string (Used by the legend), and every second element 
%              starting with the second element must be an object of 
%              class nb_graph_ts.
% 
% Output:
% 
% - plotter  : An object you can use the graphInfoStruct method or the
%              nb_graphInfoStructGUI class on.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        error([mfilename ':: You need at least two inputs to this function.'])
    end
    perc = max(varargin{2}.fanPercentiles);
    data = nb_ts();
    
    nGraphs       = length(varargin)/2;
    defaultColors = nb_defaultColors(nGraphs);
    colors        = nan(nGraphs*3,3);
    lineStyles    = cell(1,nGraphs*4);
    legends       = repmat({''},[1,nGraphs*3]);
    kk            = 1;
    ff            = 1;
    for ii = 2:2:length(varargin)
       
        legend = varargin{ii-1};
        if ~ischar(legend)
            error([mfilename ':: Every second element starting with the first must be a on line char.'])
        end
        
        dataM              = varargin{ii}.DB;
        dataM.dataNames    = strcat(legend,'_',dataM.dataNames);
        fanData            = varargin{ii}.fanDatasets;
        percData           = percentiles(fanData,nb_interpretPerc(perc,false)/100);
        percData.dataNames = strcat(legend,'_',percData.dataNames);
        data               = addPages(data,dataM,percData);
        legends{kk}        = legend;           
        
        % Line settings
        tempColors              = defaultColors(ii/2,:);
        colors(kk:kk+2,:)       = tempColors(ones(1,3),:);
        lineStyles(ff:2:ff+2)   = percData.dataNames;
        lineStyles(ff+1:2:ff+3) = {'--'};
        
        kk = kk + 3;
        ff = ff + 4;
        
    end
    
    plotter = copy(varargin{2});
    plotter.set('fanDatasets',{},'lineStyles',lineStyles,'colorOrder',colors,'legends',legends);
    plotter.resetDataSource(data);


end
