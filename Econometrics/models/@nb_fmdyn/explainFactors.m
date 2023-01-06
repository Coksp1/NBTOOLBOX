function [explained,plotter] = explainFactors(obj)
% Syntax:
%
% [dec,plotter] = factorDecomposition(obj)
%
% Description:
%
% Decompostion of the factors into contributions from the observables.
% 
% Input:
% 
% - obj       : A scalar nb_fmdyn object. 
% 
% Output:
% 
% - explained : A nb_cs object with size nFactors x nObservables that 
%               stores the explained variance of each observable.
%
% - plotter   : A 1 x nFactors nb_graph_cs object array. Use the graph 
%               method or the nb_graphMultiGUI class.
%
% See also:
% nb_graph_cs, nb_graphMultiGUI
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if numel(obj) ~= 1
        error([mfilename ':: This method only handle scalar nb_fmdyn objects.'])
    end
    if ~issolved(obj)
        error([mfilename ':: Model must be solved.'])
    end

    nFac      = obj.options.nFactors;
    indF      = 1:nFac;
    F         = obj.results.smoothed.variables.data(:,indF)';
    Grest     = obj.solution.G(:,indF);
    explained = nan(obj.observables.number,nFac);
    for ii = 1:nFac
        Xhat            = transpose(Grest(:,ii)*F(ii,:));
        explained(:,ii) = var(Xhat);
    end
    
    % Make outputs
    explained = nb_cs(explained','Explained',obj.factors.name,obj.observables.name);
    if nargout > 1
        plotter(1,nFac) = nb_graph_cs();
        for ii = 1:nFac
            plotter(ii) = nb_graph_cs(explained(ii,:));
            plotter(ii).set('plotType','pie','title',obj.factors.name{ii});
        end
    end
    
end
