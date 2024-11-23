function obj = declareUncertainParameters(obj,parameters,multiDist)
% Syntax:
%
% obj = declareUncertainParameters(obj,varargin)
%
% Description:
%
% Use this function to declare a parameter as uncertain.
%
% Caution: This will automatically trigger calculations of optimal simple
%          rules under parameter uncertainty in the method 
%          nb_dsge.optimalSimpleRules.
% 
% Input:
% 
% - obj        : An object of class nb_dsge.
%
% - parameters : A N x X char or a N x 1 cellstr with the parameters you 
%                want to declare as uncertain.
%
% - multiDist  : If N == 1:
%                   A scalar nb_distribution object.
%                Else: 
%                   A nb_copula object where the distributions property 
%                   hold N nb_distribution objects.
%
% Output:
% 
% - obj        : An object where the parameters property is updated, i.e.
%                the isUncertain field and the nb_copula object is stored
%                in the parser property.
%
% See also:
% nb_dsge.optimalSimpleRules, nb_copula, nb_distribution
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isempty(parameters)
        return
    end

    parametersOfModel = obj.parser.parameters;

    % Check and assign parameters
    test = ismember(parameters,parametersOfModel);
    if any(~test)
        error([mfilename ':: The following parameters are not part of the model; '  toString(parameters(~test))])
    end
    obj.parser.parametersIsUncertain = ismember(parametersOfModel,parameters);
    
    % Check and assign copula
    if length(parameters) == 1
        if ~isa(multiDist,'nb_distribution')
            error([mfilename ':: The multiDist input must be of class nb_distribution if only one parameter is uncertain.'])
        end
    else
        if ~isa(multiDist,'nb_copula')
            error([mfilename ':: The multiDist input must be of class nb_copula'])
        end
        if multiDist.numberOfDistributions ~= length(parameters)
            error([mfilename ':: The multiDist input (' int2str(multiDist.numberOfDistributions) ') does not match the number of '...
                             'parameters (' int2str(length(parameters)) ')'])
        end
    end
    obj.parser.parameterDistribution = multiDist;
    
end
