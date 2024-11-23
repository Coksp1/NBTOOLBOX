function R = detNumFactors(obj,type,varargin)
% Syntax:
%
% R = detNumFactors(obj,type)
%
% Description:
%
% Determine the number of factors to use in the factor model. These test
% are based on PCA on the observed data. If missing observations these are
% filled in for using nb_dfmemlEstimator.fillInForMissing.
% 
% Input:
% 
% - type : One of:
%
%          > 'scree'   : Scree plot.
%
%          > 'expl'    : Criteria using that the factors should explain X
%                        amount of the variation in the data.
%
%          > 'trapani' : Uses the test that is implemented in 
%                        nb_trapaniNFactorTest.
%
%          > 'bn'      : Implements the IC_p1 test of Bai and Ng (2002).
%
%          > 'horn'    : Implements the test proposed by Horn (1965) and 
%                        developed by Ledesma et al. (2007). Code is
%                        written by Lanya Tianhao Cai (2016). This
%                        test is only valid if the time series are
%                        standardized. See the option 'transformation'
%                        of the nb_fmdyn object to apply this.
%  
% Optional input:
%
% - 'threshold' : The treshold for the given type of test. Have an impact
%                 on the following types
%
%                 > 'expl'    : Sets the X value. Default is 0.9.
%
%                 > 'trapani' : Confidenc level of test. Default is 0.05.
%
% Output:
% 
% 
%
% See also:
% nb_trapaniNFactorTest
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        type = 'horn';
    end

    if numel(obj) > 1
        error([mfilename ':: This method only supportd scalar nb_fmdyn objects.'])
    end
    default = {'threshold',     [],  @nb_isScalarNumber};
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    % Get the data
    if isempty(obj.options.data)
        error([mfilename ':: Cannot determine the number of factors without any data.'])
    end
    if obj.observables.number == 0
        error([mfilename ':: Cannot determine the number of factors without declared observed variables.'])
    end
    data = window(obj.options.data,obj.options.estim_start_date,obj.options.estim_end_date,obj.observables.name);
    X    = double(data);
    
    % Balance the data
    if any(isnan(X(:)))
        
        % Remove all rows with all nan values.
        isNaN  = isnan(X);
        keep   = ~all(isNaN,2);
        start  = find(keep,1,'first');
        finish = find(keep,1,'last');
        
        % Fill in for missing observations using spline methods
        X      = nb_dfmemlEstimator.fillInForMissing(X(start:finish,:));
        
    end
    
    switch lower(obj.options.transformation)
        case 'standardize'
            M = mean(X);
            S = std(X);
            X = bsxfun(@minus,X,M);
            X = bsxfun(@rdivide,X,S);
    end
    
    % Select the method
    switch lower(type)
        case 'scree'
            E     = calcEig(X);
            expl  = 100*E/sum(E);
            cExpl = cumsum(expl);
            data  = nb_data([expl,cExpl],'',1,{'Explained','Cumulative'});
            plotter = nb_graph_data(data);
            plotter.set('subPlotSize',[2,1]);
            nb_graphSubPlotGUI(plotter);
            R = nan; % Undetermined
        case 'expl'
            if isempty(inputs.threshold)
                inputs.threshold = 0.9;
            end
            E     = calcEig(X);
            cExpl = cumsum(100*E/sum(E));
            R     = find(cExpl>inputs.threshold,1);
        case 'trapani'
            if isempty(inputs.threshold)
                inputs.threshold = 0.05;
            end
            R = nb_trapaniNFactorTest(X,'alpha',inputs.threshold);
        case 'bn'
            R = doBaiAndNg(X);
        case 'horn'
            [~,~,~,~,R] = nb_hornParallelAnalysis(X,1000);
        otherwise
            error([mfilename ':: Type ' type ' is not supported.'])
    end
     
end

%==========================================================================
function E = calcEig(X)

    [T,~] = size(X);
    Xcov  = (X'*X)/T;
    E     = eig(Xcov);
    E     = flip(E,1);
    
end

%==========================================================================
function R = doBaiAndNg(X)

    [T,N] = size(X);
    
    % Calculate the PCs
    Xcov       = (X'*X)/T;
    [LAMBDA,~] = eigs(Xcov,N,'lm');
    F          = X/LAMBDA';

    % Do the test, see Bai and Ng (2002)
    ii   = 1:N;
    ii   = ii';
    NT   = N*T;
    NT1  = N + T;
    CT   = ii*(NT1/NT)*log(NT/NT1); % IC_p1 
    LAM = LAMBDA';
    VkF = nan(N,1);
    C   = nan(N,N,N);
    for kk = 1:N
        e         = X - F(:,1:kk)*LAM(1:kk,:);
        C(:,:,kk) = e'*e/T;
        VkF(kk)   = sum(diag(C(:,:,kk)))/N;
    end       
    IC    = log(VkF) + CT;
    [~,R] = min(IC,[],1);
     
end
