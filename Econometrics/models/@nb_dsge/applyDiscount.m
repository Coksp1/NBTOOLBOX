function FF = applyDiscount(options,FF)
% Syntax:
%
% FF = nb_dsge.applyDiscount(options,FF)
%
% Description:
%
% Apply discount to leading terms of all or spesific equations.
% 
% Input:
% 
% - options : A struct on the format nb_dsge.template
%
% - FF      : A nEq x nForward double.
% 
% Output:
% 
% - FF      : A nEq x nForward double.
%
% See also:
% nb_dsge.rationalExpectationSolver, nb_dsge.optimalMonetaryPolicySolver,
% nb_dsge.looseOptimalMonetaryPolicySolver
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(options.discount)
        return
    end
    nEqs     = size(FF,1);
    discount = ones(nEqs,1);
    for ii = 1:length(options.discount)
        eqInd = options.discount(ii).eq;
        if strcmpi(eqInd,'all')
            eqInd = 1:nEqs;
        elseif ~nb_iswholecolumn(eqInd(:))
            error([mfilename ':: The field ''eq'' of the discount option (element ' int2str(ii) ')',...
                             'must be a scalar or vector of integers.'])
        end
        if any(eqInd < 1 | eqInd > nEqs)
            error([mfilename ':: The field ''eq'' of the discount option (element ' int2str(ii) ')',...
                             'must be between [1,' int2str(nEqs) '].'])
        end
        value = options.discount(ii).value;
        if ~nb_isScalarNumber(value,-0.0001,1.0001)
            error([mfilename ':: The field ''value'' of the discount option (element ' int2str(ii) ')',...
                             'must be a scalar double between 0 and 1.'])
        end
        discount(eqInd(:)) = value;
    end
    FF = bsxfun(@times,FF,discount);

end
