function [derivFunc,I,J,V,jac] = nb_doSymbolic(fh,vars,pars,varValues,pValues)
% Syntax:
%
% [derivFunc,I,J,V,jac] = nb_doSymbolic(fh,vars,varValues,pars,pValues)
%
% Description:
%
% Construct function handle with the derivatives of a given function, or
% evaluate the full jacobian.
% 
% Input:
% 
% - fh        : A function handle. @(x,y)x*y or @(x,y,p)x*y^p. Please
%               order parameters at the end!
%
% - vars      : List the variables input to the function. E.g. {'x','y'}.
%
% - pars      : List the parameters input to the function. E.g. {} or 
%               {'p'}.
%
% - varValues : The values of the variables for where you want to evaluate 
%               the derivative. Only needed if the output V and/or jac are 
%               asked for. Must have same length as vars input.
%
% - pValues   : The values of the parameters. Only needed if the output V  
%               and/or jac are asked for. Must have same length as pars
%               input.
% 
% Output:
% 
% - derivFunc : Function handle with the symbolic derivatives.
%
% - I,J,V     : Vectors such that jac  = sparse(I,J,V,nEqs,nVar), where
%               nEqs is the number of equations and nVar is the number of
%               variables.
%
% - jac       : The evaluated jacobian at the provided values. varValues
%               and pValues must be given (also applies to V)!
%
% Examples:
%
% func                = @(x,y)x*y;
% [fH,I,J,V,jac]      = nb_doSymbolic(func,{'x','y'},{},[2,1]);
% func                = @(x,y,p)x*y^p; % Parameters at the end!
% [fH2,I2,J2,V2,jac2] = nb_doSymbolic(func,{'x','y'},{'p'},[2,1],0.5);
%
% See also:
% nb_mySD
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        pValues = {};
        if nargin < 4
            varValues = {};
            if nargin < 3
                pars = {};
            end
        end
    end

    vars      = nb_rowVector(vars);
    pars      = nb_rowVector(pars);
    varsD     = nb_mySD(vars);
    parsD     = nb_param(pars);
    allD      = [varsD;parsD];
    allC      = nb_obj2cell(allD);
    symDeriv  = fh(allC{:});
    derivEqs  = [symDeriv.derivatives];
    inputs    = nb_constructInputPar(vars,pars);
    derivFunc = nb_cell2func(derivEqs,inputs);
    if nargout > 1
        [I,J] = nb_getSymbolicDerivIndex(symDeriv,vars,derivEqs);
    end
    if nargout > 3
        
        varValues = nb_rowVector(varValues);
        if isnumeric(varValues)
            varValues = num2cell(varValues);
        end
        if length(varValues) ~= length(vars)
            error([mfilename ':: The varValues must have equal length as the vars input.'])
        end
        pValues = nb_rowVector(pValues);
        if isnumeric(pValues)
            pValues = num2cell(pValues);
        end
        if length(pValues) ~= length(pars)
            error([mfilename ':: The varValues must have equal length as the vars input.'])
        end
        allValues = [varValues,pValues];
        
        nEqs = size(symDeriv,1);
        nVar = size(vars,2);
        V    = derivFunc(allValues{:});
        jac  = sparse(I,J,V,nEqs,nVar);
        
    end

end
