function plotter = plotUpdatedPriors(obj,varargin)
% Syntax:
%
% plotter = plotUpdatedPriors(obj)
% plotter = plotUpdatedPriors(obj,varargin)
%
% Description:
%
% Plot updated priors (and priors) drawn during estimation. Only for  
% bayesian models. Only from the first chain.
% 
% Input:
% 
% - obj       : A scalar object of class nb_model_sampling. It must 
%               represent a bayesian model that is estimated using system 
%               priors. See nb_model_sampling.sampleSystemPrior.
% 
% Optitonal input:
%
% - 'prior'   : Give this string as an input to compare updated priors 
%               with the prior distribution (if available).
%
% - 'subplot' : Give this string as an input to plot the priors and 
%               posteriors in subplots instead of one plot per parameter.
%
% - 'draws'   : The number of draws to sample from the updated prior
%               to base the kernel estimation on, if empty all draws are 
%               used for estimation.
%
% Output:
% 
% - plotter : A 1 x numCoeff vector of objects of class nb_graph_data. Use 
%             either the graph method or the nb_graphMultiGUI class to plot
%             the updated priors on screen.
%
%             Caution: If 'subplot' is given it will return a scalar
%                      nb_graph_data object. Use the graphSubPlots method
%                      or the nb_graphSubPlotGUI class to plot the 
%                      updated priors on screen.
%
% See also:
% nb_graph_data, nb_graphMultiGUI, nb_graphSubPlotGUI,
% nb_model_sampling.getUpdatedPriorDistributions
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isscalar(obj)
       error([mfilename ':: This method only works on a scalar object.']) 
    end
    
    if ~isbayesian(obj)
        error([mfilename ':: The selected object is not using bayesian methods, so no updated priors to plot.'])
    end
    
    if any(strcmpi('prior',varargin))
        prior = true;
    else
        prior = false;
    end
    
    if any(strcmpi('subplot',varargin))
        subplot = true;
    else
        subplot = false;
    end
    
    if prior
        [distrPrior,~] = getPriorDistributions(obj);
    end
    
    % Get the updated priors
    [distr,paramNames] = getUpdatedPriorDistributions(obj,varargin{:});
    
    % Plot 
    if subplot
        
        data = nb_data;
        for ii = 1:length(distr)
            
            if prior
                dataT     = asData([distrPrior(ii),distr(ii)]);
                dataD     = keepVariables(dataT,'domain');
                dataD     = rename(dataD,'variable','domain',['domain_' paramNames{ii}]);
                dataPrior = keepVariables(dataT,distrPrior(ii).name);
                dataPrior = rename(dataPrior,'variable',distrPrior(ii).name,paramNames{ii});
                dataPost  = keepVariables(dataT,distr(ii).name);
                dataPost  = rename(dataPost,'variable',distr(ii).name,paramNames{ii});
                dataPDF   = addPages(dataPost,dataPrior); 
                data      = [data,dataPDF,dataD]; %#ok<AGROW>
            else
                dataT = asData(distr(ii));
                vars  = dataT.variables;
                indD  = strcmp(vars,'domain');
                dataT = rename(dataT,'variable','domain',['domain_' paramNames{ii}]);
                dataT = rename(dataT,'variable',vars{~indD},paramNames{ii});
                data  = merge(data,dataT);
            end
            
        end
        data.dataNames = {'Updated','Original'};
        
        plotter = nb_graph_data(data);
        plotter.set('variableToPlotX',strcat('domain_',paramNames),...
                    'variablesToPlot',paramNames);
        
    else
    
        plotter(1,length(distr)) = nb_graph_data;
        if prior
            for ii = 1:length(distr)
                plotter(ii) = plot([distr(ii),distrPrior(ii)]);
                plotter(ii).set('title',[paramNames{ii}, ' (Updated priors in blue)']);
            end  
        else
            for ii = 1:length(distr)
                plotter(ii) = plot(distr(ii));
                plotter(ii).set('title',paramNames{ii});
            end
        end
        
    end
    
end
