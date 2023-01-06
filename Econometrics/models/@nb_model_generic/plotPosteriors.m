function plotter = plotPosteriors(obj,varargin)
% Syntax:
%
% plotter = plotPosteriors(obj)
% plotter = plotPosteriors(obj,varargin)
%
% Description:
%
% Plot posteriors (and priors) drawn during estimation. Only for bayesian 
% models.
% 
% Input:
% 
% - obj     : A scalar object of class nb_model_generic. It must represent
%             a bayesian model that is estimated.
% 
% Optitonal input:
%
% - 'prior'   : Give this string as an input to compare posterior draws 
%               with the prior distributions (if available).
%
% - 'updated' : Give this string as an input to compare posterior draws 
%               with the updated prior distributions (if available).
%
% - 'subplot' : Give this string as an input to plot the priors and 
%               posteriors in subplots instead of one plot per parameter.
%
% - 'draws'   : The number of draws to sample from the posterior to base 
%               the kernel estimation on, if empty all draws are used 
%               for estimation. If 'updated' is given as input, this will 
%               also set the the same options for the updated prior!
%
% Output:
% 
% - plotter : A 1 x numCoeff vector of objects of class nb_graph_data. Use 
%             either the graph method or the nb_graphMultiGUI class to plot
%             the posteriors on screen.
%
%             Caution: If 'subplot' is given it will return a scalar
%                      nb_graph_data object. Use the graphSubPlots method
%                      or the nb_graphSubPlotGUI class to plot the 
%                      posteriors on screen.
%
% See also:
% nb_graph_data, nb_graphMultiGUI, nb_graphSubPlotGUI,
% nb_model_generic.getPosteriorDistributions
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isscalar(obj)
       error([mfilename ':: This method only works on a scalar object.']) 
    end
    
    if ~isbayesian(obj)
        error([mfilename ':: The selected object is not using bayesian methods, so no posteriors to plot.'])
    end
    
    if any(strcmpi('prior',varargin))
        prior = true;
    else
        prior = false;
    end
    
    if any(strcmpi('updated',varargin))
        updated = true;
    else
        updated = false;
    end
    
    if any(strcmpi('subplot',varargin))
        subplot = true;
    else
        subplot = false;
    end
    
    if updated
        [distrUpdatedPrior,~] = getUpdatedPriorDistributions(obj,varargin{:});
    end
    if prior
        [distrPrior,~] = getPriorDistributions(obj);
    end
    [distr,paramNames] = getPosteriorDistributions(obj,varargin{:});
    
    if subplot
        
        data = nb_data;
        for ii = 1:length(distr)
            
            if updated && prior
                dataT      = asData([distrPrior(ii),distrUpdatedPrior(ii),distr(ii)]);
                dataD      = keepVariables(dataT,'domain');
                dataD      = rename(dataD,'variable','domain',['domain_' paramNames{ii}]);
                dataPrior  = keepVariables(dataT,distrPrior(ii).name);
                dataPrior  = rename(dataPrior,'variable',distrPrior(ii).name,paramNames{ii});
                dataPriorU = keepVariables(dataT,distrUpdatedPrior(ii).name);
                dataPriorU = rename(dataPriorU,'variable',distrUpdatedPrior(ii).name,paramNames{ii});
                dataPost   = keepVariables(dataT,distr(ii).name);
                dataPost   = rename(dataPost,'variable',distr(ii).name,paramNames{ii});
                dataPDF    = addPages(dataPost,dataPriorU,dataPrior); 
                data       = [data,dataPDF,dataD]; %#ok<AGROW>
            elseif updated
                dataT      = asData([distrUpdatedPrior(ii),distr(ii)]);
                dataD      = keepVariables(dataT,'domain');
                dataD      = rename(dataD,'variable','domain',['domain_' paramNames{ii}]);
                dataPriorU = keepVariables(dataT,distrUpdatedPrior(ii).name);
                dataPriorU = rename(dataPriorU,'variable',distrUpdatedPrior(ii).name,paramNames{ii});
                dataPost   = keepVariables(dataT,distr(ii).name);
                dataPost   = rename(dataPost,'variable',distr(ii).name,paramNames{ii});
                dataPDF    = addPages(dataPost,dataPriorU); 
                data       = [data,dataPDF,dataD]; %#ok<AGROW>
            elseif prior
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
        
        names = {'Posterior'};
        if updated
            names = [names,'Updated'];
        end
        if prior
            names = [names,'Priors'];
        end
        data.dataNames = names;
        
        plotter = nb_graph_data(data);
        plotter.set('variableToPlotX',strcat('domain_',paramNames),...
                    'variablesToPlot',paramNames);
        
    else
    
        plotter(1,length(distr)) = nb_graph_data;
        if updated && prior
            for ii = 1:length(distr)
                plotter(ii) = plot([distr(ii),distrUpdatedPrior(ii),distrPrior(ii)]);
                plotter(ii).set('title',[paramNames{ii}, ' (Updated priors in yellow and priors in purple)']);
            end
        elseif updated
            for ii = 1:length(distr)
                plotter(ii) = plot([distr(ii),distrUpdatedPrior(ii)]);
                plotter(ii).set('title',[paramNames{ii}, ' (Updated priors in yellow)']);
            end
        elseif prior
            for ii = 1:length(distr)
                plotter(ii) = plot([distr(ii),distrPrior(ii)]);
                plotter(ii).set('title',[paramNames{ii}, ' (Priors in yellow)']);
            end  
        else
            for ii = 1:length(distr)
                plotter(ii) = plot(distr(ii));
                plotter(ii).set('title',paramNames{ii});
            end
        end
        
    end
    
end
