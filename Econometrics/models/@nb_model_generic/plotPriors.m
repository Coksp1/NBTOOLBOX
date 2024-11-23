function plotter = plotPriors(obj,varargin)
% Syntax:
%
% plotter = plotPriors(obj,varargin)
%
% Description:
%
% Plot priors. Only for bayesian models.
% 
% Input:
% 
% - obj     : A scalar object of class nb_model_generic. It must represent
%             a bayesian model with a set prior.
% 
% Optitonal input:
%
% - 'subplot' : Give this string as an input to plot the priors and 
%               posteriors in subplots instead of one plot per parameter.
%
% Output:
% 
% - plotter : A 1 x numCoeff vector of objects of class nb_graph_data. Use 
%             either the graph method or the nb_graphMultiGUI class to plot
%             the priors on screen.
%
%             Caution: If 'subplot' is provided a scalar nb_graph_data
%                      object is returned. Use the graphSubPlots method
%                      or the nb_graphSubPlotGUI class to plot the priors
%                      on screen.
%
% See also:
% nb_graph_data, nb_graphMultiGUI, nb_graphSubPlotGUI
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isscalar(obj)
       error([mfilename ':: This method only works on a scalar object.']) 
    end

    if ~isbayesian(obj)
        error([mfilename ':: The selected object is not using bayesian methods, so no priors to plot.'])
    end
    
    if any(strcmpi('subplot',varargin))
        subplot = true;
    else
        subplot = false;
    end
    
    [distr,paramNames] = getPriorDistributions(obj);
    if subplot
    
        data = nb_data;
        for ii = 1:length(distr)
            dataT = asData(distr(ii));
            vars  = dataT.variables;
            indD  = strcmp(vars,'domain');
            dataT = rename(dataT,'variable','domain',['domain_' paramNames{ii}]);
            dataT = rename(dataT,'variable',vars{~indD},paramNames{ii});
            data  = merge(data,dataT);
        end
        data.dataNames = {'Priors'};
        
        plotter = nb_graph_data(data);
        plotter.set('variableToPlotX',strcat('domain_',paramNames'),...
                    'variablesToPlot',paramNames');
        
    else
        
        plotter(1,length(distr)) = nb_graph_data;
        for ii = 1:length(distr)
            plotter(ii) = plot(distr(ii));
            plotter(ii).set('title',paramNames{ii});
        end
        
    end
    
end
