function obj = setLossFunction(obj,lossFunction,optimal)
% Syntax:
%
% obj = setLossFunction(obj,lossFunction,optimal)
%
% Description:
%
% Set the loss function to optimize, be it with optimal simple rules,
% with full optimal monetary policy solution or for calculating the loss
% using the calculateLoss method.
%
% Caution: If you already have solved the model under optimal policy,
%          you can reset the loss function with the optimal input 
%          set to true, and then call the solve method to re-solve the
%          model.
%
% Tip    : If you already have solved the model under optimal policy, 
%          and you for some reason want to calculate the loss with another
%          loss function than in the model, you can use this method with
%          the optimal input set to true. Do not call the solve method in
%          this case!
% 
% Input:
% 
% - obj          : An object of class nb_dsge.
%
% - lossFunction : A string with the loss function. E.g.
%                  '0.5*(INF2+LAM_Y*Y2)'.
% 
% - optimal      : Set it to false to not trigger solving the model under
%                  optimal monetary policy, i.e. this loss function can
%                  then be used to calculate the loss of a DSGE solved 
%                  with taylor type rule. Default is true.
%
% Output:
% 
% - obj : An object of class nb_dsge, where the parser property has been
%         updated with the new loss function.
%
% See also:
% nb_dsge.solve, nb_dsge.optimalSimpleRules, 
% nb_dsge.looseOptimalMonetaryPolicySolver, 
% nb_dsge.optimalMonetaryPolicySolver, nb_dsge.calculateLoss
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        optimal = true;
    end

    if ~nb_isScalarLogical(optimal)
        error([mfilename ':: The optimal input must be a scalar logical.'])
    end
    
    % Initial check
    parser  = obj.estOptions.parser;
    numEndo = size(parser.endogenous,2);
    if isfield(parser,'equationsParsed')
        numEq = size(parser.equationsParsed,1);
        if numEndo <= numEq
            error([mfilename ':: When solving the model with optimal monetary policy you need at least one degree of freedom. ',...
                             'You need more endogenous variables (' int2str(numEndo) ') than equations (' int2str(numEq) ').'])
        end
    end
    obj.parser = nb_dsge.parseLossFunction(parser,lossFunction);
    if size(obj.parser.parameters,2) ~= size(obj.results.beta,1)
        % Some new parameters where added with the loss function
        obj.results.beta = [obj.results.beta;nan(size(obj.parser.parameters,2) - size(obj.results.beta,1),1)];
    end
    obj.parser.optimal = optimal;

end
