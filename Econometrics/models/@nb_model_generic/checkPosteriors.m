function [DB,plotter,pAutocorr] = checkPosteriors(obj,varargin)
% Syntax:
%
% [DB,plotter,pAutocorr] = checkPosteriors(obj,varargin)
%
% Description:
%
% Plot posteriors draws in the order they where drawn. This to check for
% problems with posterior draws that may be autocorrelated.
% 
% Input:
% 
% - obj     : A scalar object of class nb_model_generic. It must represent
%             a bayesian model that is estimated.
% 
% Optional input:
%
% - 'nLags' : Number of lags to include in the autocorrelation plot.
%             Defauult is 10.
%
% - 'iter'  : The recursive iteration date. Either as a string or a 
%             nb_date object. If recursive estimation is done, this input
%             must be provided.
%
% Output:
% 
% - DB        : A nb_data object with size nDraws x numCoeff. 
%
% - plotter   : A nb_graph_data object. Use the graphSubPlots or 
%               the nb_graphSubPlotGUI class to plot it on screen.
%
% - pAutocorr : A nb_graph_data object. Use the graphSubPlots or 
%               the nb_graphSubPlotGUI class to plot it on screen.
%
%               Caution: Only plots the autocorrelation for the first chain
%                        if the sampler has used more than one chain.
%
% See also:
% nb_graph_data, nb_graphSubPlotGUI, nb_model_sampling.checkUpdatedPriors
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isscalar(obj)
        error([mfilename ':: This method only works on a scalar object.']) 
    end
    
    if ~isestimated(obj)
        error([mfilename ':: Model must be estimated.']) 
    end
       
    if ~isbayesian(obj)
        error([mfilename ':: Model must be estimated with bayesian methods.'])
    end
    
    default = {'nLags',          10,      {@nb_isScalarInteger,'&&',{@gt,0}};...
               'iter',           '',      {{@isa,'nb_date'},'||',@ischar,'&&',{@gt,0}}};
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    % Get the estimation options at a given iteration
    if length(obj.estOptions) > 1
        % Real-time estimated model
        estOpt = obj.estOptions;
        if isempty(inputs.iter)
            error([mfilename ':: You need to provide the iter input if you have done recursive estimation.'])
        end
        dataStart   = nb_date.date2freq(estOpt(end).dataStartDate);
        recStartEst = dataStart + (estOpt(end).recursive_estim_start_ind - 1);
        iterDate    = nb_date.date2freq(inputs.iter);
        if iterDate.frequency ~= recStartEst.frequency
            error([mfilename ': Wrong frequency given to the iter input.'])
        end
        iter    = (iterDate - recStartEst) + 1;
        periods = length(estOpt);
        if iter < 1
            error([mfilename ': The iter input must come after the real-time recursive estimation start date (' toString(recStartEst) ').'])
        end
        if iter > periods
            error([mfilename ': The iter input cannot come after the real-time recursive estimation end date (' toString(recStartEst + (periods - 1)) ').'])
        end
        estOpt = estOpt(iter);
    else
        estOpt = obj.estOptions;
    end
    
    if strcmpi(estOpt.estim_method,'bvar')
        func = @(x)nb_bVarEstimator.getCoeff(x);
    else
        func = str2func(['nb_' lower(estOpt.estim_method) 'Estimator.getCoeff']);
    end
    
    % Get parameter names
    paramNames = func(estOpt);
    if isfield(estOpt,'dependent')
        dep = estOpt.dependent;
        if length(dep) > 1
            % Robustify for multiple equation models
            paramNamesT = {};
            for ii = 1:length(dep)
                paramNamesT = [paramNamesT, strcat(dep{ii},'_',paramNames)]; %#ok<AGROW>
            end
            paramNames = paramNamesT;
        end
    end
    
    % Get the posterior draws
    posterior = nb_loadDraws(estOpt.pathToSave);
    if length(posterior) > 1
        if isempty(inputs.iter)
            error([mfilename ':: You need to provide the iter input if you have done recursive estimation.'])
        end
        dataStart   = nb_date.date2freq(estOpt.dataStartDate);
        recStartEst = dataStart + (estOpt.recursive_estim_start_ind - 1);
        iterDate    = nb_date.date2freq(inputs.iter);
        if iterDate.frequency ~= recStartEst.frequency
            error([mfilename ': Wrong frequency given to the iter input.'])
        end
        iter    = (iterDate - recStartEst) + 1;
        periods = length(posterior);
        if iter < 1
            error([mfilename ': The iter input must come after the recursive estimation start date (' toString(recStartEst) ').'])
        end
        if iter > periods
            error([mfilename ': The iter input cannot come after the recursive estimation end date (' toString(recStartEst + (periods - 1)) ').'])
        end
        posterior = posterior(iter); 
    end
    
    if isfield(posterior,'output')
        % A M-H type sampler is used so we plot the full chain
        beta   = nb_mcmc.loadBetaFromOuput(posterior.output);
        chains = nb_appendIndexes('Posterior draws (chain',1:size(beta,3))';
        chains = strcat(chains,')');
        DB     = nb_data(beta,chains,1,paramNames);
    else
        beta = posterior.betaD;
        beta = permute(beta,[3,1,2]);
        beta = beta(:,:);
        DB   = nb_data(beta,'Posterior draws',1,paramNames);
    end
    
    % Create graph object
    if nargout > 1
        plotter = nb_graph_data(DB);
    end
    
    % Produce autocorrelation plot (only first chain, if more!)
    if nargout > 2
      
        statData  = autocorr(DB(:,:,1),inputs.nLags,'asymptotic',0.05);
        pAutocorr = nb_graph_data(statData);
        if inputs.nLags > 1 
           markers = {};
        else
           markers = {statData.dataNames{1},'',statData.dataNames{2}, 'square',statData.dataNames{3}, 'square'};
        end
        pAutocorr.set('lineWidth',2,...
                      'plotTypes',   {statData.dataNames{1},'grouped'},...
                      'markers',     markers,...
                      'colororder',  {'sky blue','purple','purple'});
        
    end
       
end
