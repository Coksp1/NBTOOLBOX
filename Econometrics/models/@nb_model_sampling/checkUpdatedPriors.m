function [DB,plotter,pAutocorr] = checkUpdatedPriors(obj,varargin)
% Syntax:
%
% [DB,plotter,pAutocorr] = checkUpdatedPriors(obj,varargin)
%
% Description:
%
% Plot updated prior draws in the order they where drawn. This to check 
% for problems with the draws being autocorrelated.
% 
% Input:
% 
% - obj     : A scalar object of class nb_model_sampling. It must 
%             represent a bayesian model that uses system priors.
% 
% Optional input:
%
% - 'nLags' : Number of lags to include in the autocorrelation plot.
%             Defauult is 10.
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
% nb_graph_data, nb_graphSubPlotGUI, nb_model_generic.checkPosteriors
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isscalar(obj)
        error([mfilename ':: This method only works on a scalar object.']) 
    end
   
    if isempty(obj.systemPriorPath)
        error([mfilename ':: Error, no sampling of the updated priors has been done.'])
    end

    default = {'nLags', 10, {@nb_isScalarInteger,'&&',{@gt,0}}};
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    % Get parameter names
    paramNames = obj.options.prior(:,1)';
    
    % Get the updated priors draws
    output        = nb_loadDraws(obj.systemPriorPath);
    nChains       = numel(output);
    [nDraws,nPar] = size(output(1).beta);
    beta          = nan(nDraws,nPar,nChains);
    for ii = 1:nChains
        beta(:,:,ii) = output(ii).beta;
    end
    chains = nb_appendIndexes('Updated priors draws (chain',1:nChains)';
    chains = strcat(chains,')');
    DB     = nb_data(beta,chains,1,paramNames);

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
