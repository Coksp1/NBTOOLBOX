function test = nb_cfsTest(X,varargin)
% Syntax:
%
% test = nb_cfsTest(X,varargin)
%
% Description:
%
% This function implements the procedure suggested by Barigozzi and 
% Trapani (2018) to determine the dimension of the common factor space in 
% a large, possibly non-stationary, dataset.
% 
% References:
%
% Barigozzi and Trapani (2018), "Determining the dimension of factor  
% structures in non-stationary large datasets", Discussion Papers 18/01, 
% University of Nottingham, Granger Centre for Time Series Econometrics.
%
% Trapani (2018), "A Randomized Sequential Procedure to Determine the 
% Number of Factors", Journal of American Statistical Associations, vol.
% 113, no. 523, 1341-1349. 
%
% Input:
% 
% - X       : A nobs x nvar double.
%
% Optional input:
%
% - 'alpha' : Significance level of the test. Default is 0.05. Must be
%             in (0,1).
%
% - 'k'     : Select the value of the k parameter of the paper. Either  
%             '1', 'p' or 'p+1'. Default is '1'.
%
% - 'u'     : Select the bound during randomization procedure. Default is
%             sqrt(2). The actual limits will be +- this number. 
% 
% Output:
% 
% - test : A struct with fields:
%
%          > 'r'     : Estimated total number of factors.
%
%          > 'r1'    : 1 if the data is estimated to have factors with
%                      linear trends, otherwise 0.
%
%          > 'r2'    : Estimated number of zero-mean I(1) factors;
%                      r2 = rStar - r1.
%
%          > 'r3'    : Estimated number of I(0) factors; r3 = r - rStar.
%
%          > 'rStar' : Estimated number of non-stationary common factors.
%
% Examples:
%
% See also:
% nb_pca, nb_trapaniNFactorTest
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [T,N,P] = size(X);
    if P > 1
        error([mfilename ':: This function does not handle datasets with more than one page.'])
    end
    
    if N < 2
        error([mfilename ':: X must have at least two columns.'])
    end
    
    if T < 10
        error([mfilename ':: At least 10 periods of data is needed'])
    end
    
    % Parse optional inputs
    inputs = parseInputs(varargin{:});
    
    % Use the suggested delta as in section 4 of the paper.
    beta       = log(N)/log(T);
    delta_star = 10^-5;
    if beta < 0.5
        delta = delta_star;
    else
        delta = 1 - 0.5/beta + delta_star;
    end
    
    % Covariance matrices and rescaled eigenvalues
    
%     Sigma  = X'*X/T;
%     nu     = flip(sort(eig(Sigma),1),1);
%     nuBar  = calculateNuBar(inputs,nu,N,1); % See equation 10 of Trapani (2018)
%     phi    = exp(N^delta*nu./nuBar); % See equation 11 of Trapani (2018)
%     r      = applyTestTrapani(phi,N,T,inputs); % Applies the Trapani (2018) test statistic
    
    deltaX = diff(X);
    Sigma3 = deltaX'*deltaX/T;
    nu3    = flip(eig(Sigma3),1);
    nuBar3 = calculateNuBar(inputs,nu3,N,0.25); % See equation 19 of Barigozzi and Trapani (2018)
    phi3   = exp(N^delta*nu3./nuBar3); 

    Sigma2 = X'*X/T^2;
    nu2    = flip(eig(Sigma2),1);
    phi2   = exp(N^delta*log(log(T))*nu2./nuBar3); % See equation 27 of Barigozzi and Trapani (2018)
    %nuBar2 = calculateNuBar(inputs,nu2,N,0.25); 
    
    Sigma1 = X'*X/T^3;
    nu1    = flip(eig(Sigma1),1);
    phi1   = exp(N^delta*nu1./nuBar3); % See equation 21 of Barigozzi and Trapani (2018)
    
    % Determining the presence of factors with linear trends
    r1    = applyTest(1,phi1,N,T,inputs); 
    
    % Determining the number of non-stationary common factors
    rStar = applyTest(2,phi2,N,T,inputs);
    
    % Determining the number of common factors
    r     = applyTest(3,phi3,N,T,inputs); 
    
    % Determining the number of zero-mean I(1)
    r2    = rStar - r1;
    
    % Determining the number of I(0) factors 
    r3    = r - rStar; 
    
    % Collect results
    test = struct(...
        'r',    r,...
        'r1',   r1,...
        'r2',   r2,...
        'r3',   r3,...
        'rStar',rStar);
    
end

%==========================================================================
function inputs = parseInputs(varargin)

    default = {'alpha', 0.05,                   @(x)nb_isScalarNumber(x,0,1);
               'draws', 100,                    @(x)nb_isScalarNumber(x,50);
               'k',     '1',                    @nb_isOneLineChar;
               'drawU', @defaultURandomizer,    @(x)isa(x,'function_handle')};
           
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
end

%==========================================================================
function nuBar3 = calculateNuBar(inputs,nu3,N,factor)

    switch inputs.k
        case '1'
            nuBar3 = sum(nu3)/(N + 1);
        case 'p'
            nuBar3 = zeros(size(nu3,1),1);
            for p = 1:size(nu3,1)
                nuBar3(p) = sum(nu3(p:end))/(N - p + 1);
            end
        case 'p+1'
            nuBar3 = zeros(size(nu3,1),1);
            for p = 1:size(nu3,1)-1
                nuBar3(p) = sum(nu3(p+1:end))/(N - p);
            end
        otherwise
            error(['Unsupported input selected for ''k'': ' inputs.k])
    end
    nuBar3 = nuBar3.*factor;

end

%==========================================================================
function r = applyTest(nr,phi,N,T,inputs)

    alpha = inputs.alpha/min(N,T);
    draws = inputs.draws;
    if nr == 1
        iter = 1;
    else
        iter = size(phi,1);
    end
    R = N;
    
    for p = 1:iter

        vartheta = nan(100,1);
        for ii = 1:draws

            % Step 1: xi ~ N(0,1):
            xi = randn(1,R);

            % Step 2: u restricted to a interval:
            u    = inputs.drawU();
            zeta = xi*phi(p) <= u;

            % Step 3:
            vartheta(ii) = sum((zeta - 0.5)./0.5)/sqrt(R); % Uses that normcdf(0) = 0.5
        
        end
        
        % Step 4:
        Theta = sum(vartheta.^2)/draws;
        
        % Step 5: Accept or reject H0:
        % > nr == 1: Presence of a linear trend
        % > nr == 2: Presence of a pth non-stationary variable
        %
        % If pValue < alpha we reject the H0
        pValue = 1 - nb_distribution.chis_cdf(Theta,1);%min(N,T)
        if pValue < alpha
            break
        end
        
    end
    
    if nr == 1
        if pValue < alpha
            r = 0;
        else
            r = 1; 
        end
    else
        r = p - 1;
    end
    
end

%==========================================================================
function r = applyTestTrapani(phi,N,T,inputs)

    alpha = inputs.alpha/min(N,T);
    iter  = size(phi,1);
    draws = inputs.draws;
    R     = N;
    for p = 1:iter
        
        vartheta = nan(100,1);
        for ii = 1:draws
            
            % Step 1: xi ~ N(0,1):
            xi = randn(1,R);
            
            % Step 2: draw u and evaluate zeta
            u    = inputs.drawU();
            zeta = xi*sqrt(phi(p)) <= u;
    
            % Step 3:
            vartheta(ii) = sum((zeta - 0.5)./0.5)/sqrt(R); % Uses that normcdf(0) = 0.5

        end
        
        % Step 4: Integrate
        Theta = sum(vartheta.^2)/draws;
        
        % Step 5: Accept or reject
        % > Presence of a pth factor
        %
        % If pValue < alpha we reject the H0
        pValue = 1 - nb_distribution.chis_cdf(Theta,1);
        if pValue < alpha
            break
        end
        
    end
    
    r = p - 1;
    
end

%==========================================================================
function u = defaultURandomizer()
    if rand < 0.5
        u = -sqrt(2);
    else
        u = sqrt(2);
    end
end
