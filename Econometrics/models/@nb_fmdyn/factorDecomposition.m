function [dec,plotter] = factorDecomposition(obj)
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
% - obj     : A scalar nb_fmdyn object. 
% 
% Output:
% 
% - dec     : A nb_ts object with size T x nObservables x nFactors that 
%             stores the decomposition.
%
% - plotter : A nb_graph_ts object. Use the graph method or the
%             nb_graphPagesGUI class.
%
% See also:
% nb_graph_ts, nb_graphPagesGUI
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if numel(obj) ~= 1
        error([mfilename ':: This method only handle scalar nb_fmdyn objects.'])
    end
    if ~issolved(obj)
        error([mfilename ':: Model must be solved.'])
    end
    
    
    
    % Get the predicted observables
    nFac     = obj.options.nFactors;
    indF     = 1:nFac;
    Grest    = obj.solution.G(:,indF);
    
    % Get data on the observables
    alpha    = obj.results.smoothed.variables.data';
    errors   = obj.results.smoothed.errors.data';
    dataNorm = obj.results.Z(:,:,end)*alpha + errors;
    dataNorm = dataNorm';
    
    % Do the decomposition
    dec = nan(size(dataNorm,1),obj.observables.number,nFac);
    for ii = 1:nFac
        dec(:,:,ii) = bsxfun(@times,dataNorm,Grest(:,ii)');
    end
    
    % Make outputs
    dec = nb_ts(dec,obj.factors.name,obj.results.smoothed.variables.startDate,obj.observables.name);
    if nargout > 1
        plotter = nb_graph_ts(dec);
        plotter.set('plotType','dec','lineWidth',1.5,'position',[0.1,0.35,0.8,0.55],...
                    'legPosition',[0,-0.15],'legColumns',5);
    end
    
end
