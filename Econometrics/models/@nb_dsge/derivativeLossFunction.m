function solution = derivativeLossFunction(parser,solution,paramV)
% Syntax:
%
% solution = nb_dsge.derivativeLossFunction(parser,solution,paramV)
%
% Description:
%
% Take derivatives of the loss function of the DSGE model.
% 
% See also:
% nb_dsge.derivative, nb_dsge.derivativeNB, nb_dsge.calculateLoss
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    lossVars       = parser.lossVariables;
    nLossVars      = length(lossVars);
    derivatorLoss  = nb_mySD(lossVars,15);
    derivatorLoss1 = parser.lossFunction(derivatorLoss,paramV);
    V              = zeros(nLossVars,1);
    firstOrder     = derivatorLoss1.derivatives;
    try
        for ii = 1:nLossVars
            firstOrderFunc = str2func(['@(vars,pars)',firstOrder{ii}]);
            derivatorLoss2 = firstOrderFunc(derivatorLoss,paramV);
            if isa(derivatorLoss2,'nb_mySD')
                V(ii) = nb_eval(derivatorLoss2.derivatives{1},{},[]);
            else 
                warning('nb_dsge:lossHas2OrderDerivativeEqual2Zero',...
                        [mfilename ':: The second order derivative of the loss function wrt ' parser.endogenous{parser.lossVariablesIndex(ii)} ' equal 0.'])
            end
        end
    catch Err
        lFunc   = func2str(parser.lossFunction);
        param   = regexp(lFunc,'pars\(\d+\)','match');
        index   = regexp(param,'\d+','match');
        index   = [index{:}];
        index   = cellfun(@str2double,index);
        lParamV = paramV(index);
        test    = isnan(lParamV);
        lParamN = unique(parser.parameters(index));
        if any(test)
            error([mfilename ':: The following paramters of the loss function has not been assign any value; ' toString(lParamN(test))])
        else
            rethrow(Err)
        end
    end
    if isfield(parser,'isMultiplier')
        nEndo = length(parser.endogenous(~parser.isMultiplier));
    else
        nEndo = length(parser.endogenous);
    end
    lossVarsI  = parser.lossVariablesIndex;
    solution.W = sparse(lossVarsI,lossVarsI,V,nEndo,nEndo);
    
end
