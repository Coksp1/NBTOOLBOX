function [res,plotter] = meanPlot(obj,periods,type)
% Syntax:
%
% [res,plotter] = meanPlot(obj)
% [res,plotter] = meanPlot(obj,periods,type)
%
% Description:
%
% Calculates the (moving) mean of each sampled chain and plot it.
% 
% Input:
% 
% - obj     : A scalar nb_model_sampling object.
%
% - periods : Maximum period length when calculating the moving mean. 
%             Default is to use the full sample.
%
% - type    : 'posterior' to test posterior draws (default) or 'updated' 
%             to test updated prior draws.  
% 
% Output:
% 
% - res     : A nDraws x nParam x nChain nb_data object with the
%             (moving) mean of the parameters.
%
% - plotter : A object of class nb_graph_data. Use the graphSubPlots
%             method or the nb_graphSubPlotGUI class to produce the
%             graph on screen.
%
% See also:
% nb_model_sampling.sample
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        type = 'posterior';
    end

    if nargin < 2
        periods = [];
    else
        if ~isempty(periods)
            if ~nb_isScalarInteger(periods)
                error([mfilename ':: The periods input must be a scalar integer.'])
            end
        end
    end
    
    % Get the sampled output
    if strcmpi(type,'updated')
        if ~isa(obj,'nb_model_sampling')
            error([mfilename ':: Error, no sampling of the updated priors can be done for this model.'])
        end
        if isempty(obj.systemPriorPath)
            error([mfilename ':: Error, no sampling of the updated priors has been done.'])
        end
        output = nb_loadDraws(obj.systemPriorPath);
    else
        if ~isfield(obj.estOptions,'pathToSave')
            error([mfilename ':: Error no sampling of the posteriors has been done.'])
        end
        posterior = nb_loadDraws(obj.estOptions.pathToSave);
        if ~isfield(posterior,'output')
            error([mfilename ':: No sampling is done.'])
        elseif nb_isempty(posterior.output)
            error([mfilename ':: No sampling is done.'])
        end
        output = posterior.output;
    end
    
    % Calculate the recursive mean 
    beta                 = nb_mcmc.loadBetaFromOuput(output);
    [draws,nPar,nChains] = size(beta);
    res                  = nan(draws,nPar,nChains);
    if isempty(periods)
        res = bsxfun(@rdivide, cumsum(beta,1),transpose(1:draws));
    else
        % Moving recursive mean
        res(1:periods,:,:) = bsxfun(@rdivide, cumsum(beta(1:periods,:,:)),transpose(1:periods));
        for pp = 1+periods:draws
            res(pp,:,:) = mean(beta(pp-periods:pp,:,:));
        end
    end
    
    % Get names of estimated parameters
    paramEst = obj.options.prior(:,1)';
    
    % Make nb_data object
    chains = nb_appendIndexes('Mean (chain',1:nChains)';
    chains = strcat(chains,')');
    res    = nb_data(res,chains,1,paramEst);
    
    % Make plotter object
    if nargout > 1
        plotter = nb_graph_data(res);
    end
    
end
