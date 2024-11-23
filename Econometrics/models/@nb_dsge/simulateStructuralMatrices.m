function [Alead,A0,Alag,B] = simulateStructuralMatrices(obj,method,headings)
% Syntax:
%
% [Alead,A0,Alag,B] = simulateStructuralMatrices(obj,method,headings)
%
% Description:
%
% Alead*y(+1) + A0*y + Alag*y(-1) + B*e
% 
% Input:
% 
% - obj      : An object of class nb_dsge.
%
% - method   : Either 'mean', 'median', 'var', 'std', 'skewness', 
%              'kurtosis' or 'sim' (default). 'sim' will return the 
%              simulation where the pages are the different draws.
% 
% - headings : Give true to add table headings to the outputs. Not
%              supported for method set to 'sim'. Deault is false.
%
% Output:
% 
% - [Alead,A0,Alag,B] : The structural representation of the DSGE model.
%                       Ax has size nEndo x nEndo x N, and B has size 
%                       nEndo x nExo x N. N is equal to
%                       options.uncertain_draws if method is equal to 
%                       'sim', otherwise 1.
%
% See also:
% nb_dsge.declareUncertainParameters
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        headings = false;
    end

    if numel(obj) > 1
        error([mfilename ':: This method only handle a scalar nb_dsge object.'])
    end     
    
    if ~isfield(obj.parser,'eqFunction')
        obj.parser = nb_dsge.eqs2func(obj.parser);
    end
    
    if ~obj.steadyStateSolved
        obj = checkSteadyState(obj);
    end
    
    [Alead,A0,Alag,B] = nb_dsge.simulateStructuralMatricesStatic(obj.parser,obj.options,obj.solution,obj.results);

    method = lower(method);
    switch method
        case {'mean','median'}
            func  = str2func(method);
            Alead = func(Alead,3);
            A0    = func(A0,3);
            Alag  = func(Alag,3);
            B     = func(B,3);
        case {'var','std','skewness','kurtosis'}
            func  = str2func(method);
            Alead = func(Alead,0,3);
            A0    = func(A0,0,3);
            Alag  = func(Alag,0,3);
            B     = func(B,0,3);
        case 'sim'
            if headings
                error([mfilename ':: The headings input cannot be set to true if method is set to ''sim''.'])
            end
        otherwise
            error([mfilename ':: Unsupported method ' method '.'])
    end
    
    if ~strcmpi(method,'sim')
        Alead(Alead < eps^(0.7)) = 0;
        A0(A0 < eps^(0.7))       = 0;
        Alag(Alag < eps^(0.7))   = 0;
        B(B < eps^(0.7))         = 0;
    end
    
    if headings
       
        nEndo  = size(Alead,2);
        nExo   = size(B,2);
        nEqs   = size(Alead,1);
        AleadT = Alead;
        A0T    = A0;
        AlagT  = Alag;
        BT     = B; 
        
        Alead      = cell(nEqs + 1,nEndo);
        Alead(1,:) = obj.parser.endogenous;
        A0         = Alead;
        Alag       = Alead;
        B          = cell(nEqs + 1,nExo);
        B(1,:)     = obj.parser.exogenous;
        
        Alead(2:end,:) = num2cell(AleadT);
        A0(2:end,:)    = num2cell(A0T);
        Alag(2:end,:)  = num2cell(AlagT);
        B(2:end,:)     = num2cell(BT);
        
    end
            
end
