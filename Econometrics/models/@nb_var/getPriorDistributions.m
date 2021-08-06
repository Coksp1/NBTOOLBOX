function [distr,paramNames] = getPriorDistributions(obj)
% Syntax:
%
% [distr,paramNames] = getPriorDistributions(obj)
%
% Description:
%
% Get prior distributions of B-VAR model.
% 
% Input:
% 
% - obj        : An object of class nb_var. 
% 
% Output:
% 
% - distr      : A 1 x numCoeff nb_distribution object.
%
% - paramNames : A 1 x numCoeff cellstr with the names of the parameters.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    error([mfilename ':: To get prior distributions for B-Var models are not yet supported.'])

end

