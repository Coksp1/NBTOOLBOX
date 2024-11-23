function plotter = plotHarmonization(obj)
% Syntax:
%
% plotter = plotHarmonization(obj)
%
% Description:
%
% Plot harmonization, i.e. harmonized forecast compared with conditional
% information.
% 
% Input:
% 
% - obj     : A scalar nb_harmonize object.
% 
% Output:
% 
% - plotter : An object of class nb_graph. Use the graphSubPlots
%             method or the nb_graphSubPlotGUI class.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isscalar(obj)
        error('The input must be a scalar ')
    end
    plotter = plotForecast(obj);
    if isempty(obj.options.estim_end_date)
        endDate = obj.options.data.endDate;
    else
        endDate = obj.options.estim_end_date;
    end
    cond           = tonb_ts(obj.options.condDB,endDate + 1);
    plotter.DB     = addPages(plotter.DB,cond);
    
    plotter.DB.dataNames = {'Harmonization','Conditional information'};
    plotter.DB           = interpolate(plotter.DB,'linear');
    
    
end
