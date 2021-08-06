function obj = applyLongRunPriors(obj,H,phi)
% Syntax:
%
% obj = applyLongRunPriors(obj,H,phi)
%
% Description:
%
% Apply priors for the long run as in Giannone et. al (2014).
%
% If the prior field of the options property is not yet assign a prior, a
% jeffrey prior is used as default. 
%
% Caution: Please do not call this method before nb_var.setPrior!
% 
% Input:
% 
% - obj : A N x M matrix of nb_var objects, with nDep dependent variables.
%
% - phi : Either a nDep x 1 double vector with the prior shrinkage
%         parameter for each equation, or a m x 2 cell. m <= nDep.
%         The format of the cell input must be as follows;
%
%         {'var1',1;'var2',0.5}
%
%         If some dependent variables are not assign any parameter the
%         default is 1.
%
% - H   : A q x nDep matrix, where q <= nDep. Each row is the cointegration
%         vector to apply on the prior. If q < nDep the null space will be
%         applied to the rest of the rows.
%
%         Or it can be a q x 1 cellstr with the cointegration relations.
%         Again q <= nDep, and if q < nDep the null space will be
%         applied to the rest of the rows. Please not that only dependent
%         variables may be applied in the cointegration relations! Example:
%
%         {'var1 - var2','var3 + var1'}
% 
% Output:
% 
% - obj : A N x M matrix of nb_var objects.
%
% See also:
% nb_var.set, nb_var.setPrior
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        obj = nb_callMethod(obj,@applyLongRunPriors,'nb_var',H,phi);
        return
    end

    if isa(obj,'nb_favar')
        error([mfilename ':: Cannot apply the long run prior on nb_favar models.'])
    end
    
    n = length(obj.dependent.name);
    if n == 0
        error([mfilename ':: The model is not assign any dependent variables, and you cannot use this method before you have done that!'])
    end
    if isnumeric(phi)
        phi = nb_bVarEstimator.testLRPriorPhi(phi,n);
    elseif iscell(phi)
        
        phiD  = nan(n,1);
        [r,c] = size(phi);
        if r > n
            error([mfilename ':: When the phi input is given as a m x 2 cell matrix, m must be <= nDep.'])
        end
        if c ~= 2
            error([mfilename ':: When the phi input is given as a cell matrix, it must have two columns.'])
        end
        vars   = phi(:,1);
        values = phi(:,2);
        for ii = 1:r
            
            var = vars{ii};
            if ~nb_isOneLineChar(var)
                error([mfilename ':: When the phi input is given as a cell matrix, each element of the first column must be a one line char.'])
            end
            indV = strcmp(var,obj.dependent.name);
            if ~any(indV)
                error([mfilename ':: The variable ' var ' is not a dependent variable of the model.'])
            end
            value = values{ii};
            if ~nb_isScalarNumber(value)
                error([mfilename ':: When the phi input is given as a cell matrix, each element of the second column must be a scalar double.'])
            end
            phiD(indV) = value;
            
        end
        phi = phiD;
        
    else
        error([mfilename ':: phi input must either be a numeric vector or a m x 2 cell matrix, where m <= nDep.'])
    end
    
    if isnumeric(H) 
        H = nb_bVarEstimator.testLRPriorH(H,n);
    elseif iscellstr(H)
        if ~iscellstr(H)
            error([mfilename ':: The H input must be a cellstr, if not a double matrix.'])
        end
        inputs      = nb_constructInputPar(obj.dependent.name,{});
        cointFunc   = nb_cell2func(H,inputs);
        [~,~,~,~,H] = nb_doSymbolic(cointFunc,obj.dependent.name,{},ones(n,1),[]);
        H           = nb_bVarEstimator.testLRPriorH(H,n);
    else
        error([mfilename ':: The H input must be a m x 1 cellstr or a m x nDep double matrix.'])
    end
    
    if nb_isempty(obj.options.prior)
        obj = setPrior(obj,'jeffrey');
    end
    obj.options.prior.LR  = true;
    obj.options.prior.H   = H;
    obj.options.prior.phi = phi;
    
end
