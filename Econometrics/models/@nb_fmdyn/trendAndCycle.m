function [O,decomp,results] = trendAndCycle(obj,varargin)
% Syntax:
%
% [O,decomp,results] = trendAndCycle(obj,varargin)
%
% Description:
%
% Decompose the observed variables  into deterministic, trend, cycle and 
% noise components.
%
% We follow Barigozzi and Luciani (2017) "Common Factors, Trends, and 
% Cycles in Large Datasets".
% 
% The decomposition is given by:
%
% O_t = Dhat_t                              (Deterministic)
%     + G*PHI1*That_t                       (Trend)
%     + G*PHI0*Chat_t                       (Cycle)
%     + G*PHI0*(Ghat_t - H*Chat_t) + eps_t  (Noise)
%
% where O_t is the observed variables, G is the factor loadings and eps_t
% is the idiosyncratic components found during estimation. See section 3.3
% for a description of the rest of the terms in the equation.
%
% Input:
% 
% - 'q'     : The number of common shocks. d=q-m will be the number of
%             stationary common shocks.
%
% - 'm'     : The number of common trends. Same as q-d in Barigozzi and 
%             Luciani (2017).
% 
% - 'nLags' : Number of lags to include in equation (20) of Barigozzi and 
%             Luciani (2017).
%
% Output:
% 
% - O       : A T x N x 4 nb_ts object. T is number of observations, N is 
%             number of observed variables. The pages represents 
%             deterministic, trend, cycle and noise components 
%             respectively.
%             
% - decomp  : A struct with fields:
%
%       > That : A T x m nb_ts object. T is number of observations, m 
%                is the number of common trends.
%
%       > Chat : A T x (q-m) nb_ts object. T is number of observations,  
%                (q-m) is the number of common stationary shocks (cycle).
%
%       > Ihat : A T x (r - q) nb_ts object. T is number of observations,  
%                m is the number of common noise.
%
% - results : A struct with fields PHI1, PHI0 and H. See equation above. 
%
% See also:
% nb_model_generic.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This method only supportd scalar nb_fmdyn objects.'])
    end
    if ~isestimated(obj)
        error([mfilename ':: Model is not estimated.'])
    end
    
    % Parse the arguments
    %-------------------- 
    default = {'q',     [],  {@(x)nb_isScalarInteger(x,0),'||',@isempty};...
               'm',     [],  {@(x)nb_isScalarInteger(x,0),'||',@isempty};...
               'nLags', 2,   @(x)nb_isScalarInteger(x,0)};
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    % Estimate q and m if not provided
    %---------------------------------
    if isempty(inputs.q)
        error([mfilename ':: Automatic selection of q is not yet supported.'])
    end
    if isempty(inputs.m)
        error([mfilename ':: Automatic selection of m is not yet supported.'])
    end
    q = inputs.q;
    m = inputs.m;
    d = q - m;
    
    % Estimate the decomposition given q and m
    %-----------------------------------------
    func    = str2func([obj.estOptions.estimator '.getFactors']);
    factors = func(obj.results,obj.estOptions);
    F       = double(factors);
    func    = str2func([obj.estOptions.estimator '.getObservables']);
    
    % Check inputs
    [T,r] = size(F);
    if q > r
        error([mfilename ':: The q input must be less than the number of factors (' int2str(r) ').'])
    end
    
    % Calculate eigenvectors
    S       = F'*F/T^2;
    [V,D]   = eig(S,'vector');
    [~,ind] = sort(D,'descend');
    V       = V(:,ind);
    
    % Estimate of the common trends
    PHI1 = V(:,1:m);
    That = PHI1'*F';
    
    % Estimate of the common shocks
    PHI0         = V(:,m+1:end);
    Ghat         = PHI0'*F';
    GhatLag      = nb_mlag(Ghat',inputs.nLags,'varFast');
    [~,~,~,~,nu] = nb_ols(Ghat(:,inputs.nLags+1:end)',GhatLag(inputs.nLags+1:end,:));
    SigmaNu      = nu'*nu/(size(nu,1)-1);
    [Vnu,Dnu]    = eig(SigmaNu,'vector');
    [~,ind]      = sort(Dnu,'descend');
    Vnu          = Vnu(:,ind);
    H            = Vnu(:,1:d);
    Chat         = H'*Ghat;
    
    % Estimate the common noise
    Ihat = Ghat - H*Chat;
    
    % Apply decomposition to the observables
    %---------------------------------------
    if obj.estOptions(end).mixedFrequency
        epsStart = obj.options.nFactors*max(obj.options.nLags,5) + 1;
    else
        epsStart = obj.options.nFactors*obj.options.nLags + 1;
    end
    eps   = obj.results.smoothed.variables.data(:,epsStart:end);
    err   = obj.results.smoothed.errors.data;
    G     = obj.results.Z(:,1:epsStart-1,end);
    ThatO = G*PHI1*That; 
    ChatO = G*PHI0*H*Chat; 
    IharO = G*PHI0*Ihat + eps' + err';
    
    % Map to correct variation if standardized
    if ~isempty(obj.results.S)
        ThatO = bsxfun(@times,ThatO,obj.results.S(:,:,end));
        ChatO = bsxfun(@times,ChatO,obj.results.S(:,:,end));
        IharO = bsxfun(@times,IharO,obj.results.S(:,:,end));
    end
    
    % Add deterministic comonents
    DhatO  = obj.results.C(:,:,end)*obj.results.W';
    
    % Construct output
    %-----------------
    N          = size(G,1);
    dec        = nan(T,N,4);
    dec(:,:,1) = DhatO';
    dec(:,:,2) = ThatO';
    dec(:,:,3) = ChatO';
    dec(:,:,4) = IharO';
    O          = nb_ts(dec,{'Deterministic','Trend','Cycle','Noise'},...
                       obj.results.smoothed.variables.startDate,obj.observables.name);
    results    = struct('PHI1',PHI1,'PHI0',PHI0,'H',H);
    decomp     = struct('That',That,'Chat',Chat,'Ihat',Ihat);
    
end
