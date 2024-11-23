function r = nb_trapaniNFactorTest(X,varargin)
% Syntax:
%
% r = nb_trapaniNFactorTest(X)
%
% Description:
%
% This function implements a test for the number of common components in a
% large dataset based on the eigenvalues of the matrix X'X/T.
% 
% References:
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
% - 'r      : Estimated total number of factors.
%
% See also:
% nb_pca, nb_cfsTest
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

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
    Sigma  = X'*X/T;
    nu     = flip(sort(eig(Sigma),1),1);
    nuBar  = calculateNuBar(inputs,nu,N,1); % See equation 10 of Trapani (2018)
    phi    = exp(N^delta*nu./nuBar); % See equation 11 of Trapani (2018)
    r      = applyTestTrapani(phi,N,T,inputs); % Applies the Trapani (2018) test statistic
  
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
