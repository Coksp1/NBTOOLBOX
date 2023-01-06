function [res,plotter] = gelmanRubin(obj,type)
% Syntax:
%
% [res,plotter] = gelmanRubin(obj)
% [res,plotter] = gelmanRubin(obj,type)
%
% Description:
%
% Calculates the recursive Gelman-Rubin diagnostic of multiple M-H chains.
% 
% Input:
% 
% - obj   : A scalar nb_model_sampling object.
% 
% - type  : 'posterior' to test posterior draws (default) or 'updated' 
%           to test updated prior draws.  
% 
% Output:
% 
% - res     : A nDraws x nParam nb_data object storing the test statistic. 
%             If any element is >> 1 run the M-H for a longer period, as  
%             it has not converged to the stationary distribution.
%
% - plotter : A object of class nb_graph_data. Use the graphSubPlots
%             method or the nb_graphSubPlotGUI class to produce the
%             graph on screen.
%
% See also:
% nb_mcmc.gelmanRubinRecursive, nb_model_sampling.sample
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        type = '';
    end

    if numel(obj) > 1
        error([mfilename ':: This method only handles scalar ' class(obj) '.'])
    end
    
    % Get names of estimated parameters
    paramEst = obj.options.prior(:,1)';
    
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
    
    % Produce the test statistics
    beta = nb_mcmc.loadBetaFromOuput(output,[],'cell');
    R    = nb_mcmc.gelmanRubinRecursive(beta{:});
    res  = nb_data(R,'Gelman-Rubin statistics',1,paramEst);
    if nargout > 1
        plotter = nb_graph_data(res);
    end

end
