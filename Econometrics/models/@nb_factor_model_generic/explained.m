function [expl,plotter] = explained(obj)
% Syntax:
%
% [expl,plotter] = explained(obj)
%
% Description:
%
% Get how much of the variation in the data the factors explain.
%
% Caution: Remember that for dynamic factor models the factors are not
%          orthogonal.
% 
% Input:
% 
% - obj     : A scalar nb_factor_model_generic object.
% 
% Output:
% 
% - expl    : A nb_cs object with size nFactors x 1.
%
% - plotter : A nb_graph_cs object. Use the graph method or the
%             nb_graphPagesGUI class to plot it on the screen.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isscalar(obj)
        error('This method only handle a scalar object.')
    end
    if ~isestimated(obj)
        error('The model is not estimated.')
    end
    if isfield(obj.results,'expl')
        if isfield(obj.estOptions,'factors')
            factorNames = obj.estOptions.factors;
        elseif isfield(obj.estOptions,'factorNames')
            factorNames = obj.estOptions.factorNames;
        else
            error(['Cannot report explained for the model of class' class(obj)])
        end
        expl = nb_cs(obj.results.expl','',factorNames,{'Explained'});
    else
        error('Cannot locate expl in the results property.')
    end
    plotter = nb_graph_cs(expl);
    
end
