function [obj,res] = simulate(start,obs,vars,pages,lambda,rho,dist,burn,varargin)
% Syntax:
% 
% obj       = nb_ts.simulate()
% obj       = nb_ts.simulate(start,obs,vars,pages,lambda,rho,dist,burn)
% [obj,res] = nb_ts.simulate(start,obs,vars,pages,lambda,rho,dist,burn,...
%               varargin)
%
% Description:
%
% Simulate time-series data from a VAR-MA model
% 
% Input:
% 
% - start  : The start date of the created nb_ts object.
%
% - obs    : The number of observation of the created nb_ts object.
% 
% - vars   : Either a 1 x nVars cellstr with the variables of the nb_ts
%            object, or a scalar with the number of variables of the
%            returned nb_ts object.
%
% - pages  : Number of pages of the nb_ts object. I.e. the number of
%            simulations from the process.
%
% - lambda : The VAR coefficients. As a nVar x nVar*nLags double.
%            Default is a zero matrix.
%
% - rho    : The MA coefficients (including the contemporaneous). 
%            As a nVar x nMA + 1. Default is a vector of ones. The weight
%            on the contemporaneous innovation comes first, then the first
%            MA term and so on.
%
% - dist   : The distribution to draw the residuals from. As a 1 x svars
%            nb_distribution object. Default is N(0,1), i.e. when [] is
%            given.
%
% - burn   : Number of observations used to simulate starting values. As 
%            an integer. Default is 10.
%
% Optional input:
%
% - 'exoData' : A obs * burn x nExo double with the simulated data of the
%               exogenous variables.
%
% - 'B'       : A nVars x nExo double with the coefficients on the
%               exogenous variables of the VAR.
%
% Output:
% 
% - obj    : A nb_ts object with the simulated data.
%
% - res    : A nb_ts object with the simulated innovations.
%
% Examples:
%
% % AR(2) model with std 0.5^2
% obj = nb_ts.simulate('1994Q1',100,1,1000,[0.9,-0.2],0.5)
%
% % A VAR with two variables and two lags
% obj = nb_ts.simulate('1994Q1',100,2,1000,...
%                 [0.9,-0.2,0.3,0;0.1,0,0.7,0.05],[0.5;0.3])
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 8
        burn = 10;
        if nargin < 7
            dist = [];
            if nargin < 6
                rho = [];
                if nargin < 5
                    lambda = [];
                    if nargin < 4
                        pages = 1000;
                        if nargin < 3
                            vars = 1;
                            if nargin < 2
                                obs = 1;
                                if nargin < 1
                                    start = 1;
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    default = {'exoData', [], @isnumeric;...
               'B',       [], @isnumeric};       
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    if ~nb_iswholenumber(burn)
        error([mfilename ':: The burn input must be an interger larger than zero'])
    end

    if iscellstr(vars)
        svars = size(vars,2);
    elseif isscalar(vars) && isnumeric(vars)
        svars = vars;
        vars  = nb_appendIndexes('Var',1:svars); 
    else
        error([mfilename ':: The vars input must either be a double or a cellstr'])
    end
    
    if isempty(lambda)
        lambda = zeros(svars,svars);
    end
    if isempty(rho)
        rho = ones(svars,1);
    end    
        
    if size(lambda,1) ~= svars
        error([mfilename ':: The lambda input must have as many number of rows as the number of variables.'])
    end
    if size(rho,1) ~= svars
        error([mfilename ':: The rho input must have as many number of rows as the number of variables.'])
    end
    
    nAR = size(lambda,2)/svars;
    if rem(nAR,1) ~= 0
        error([mfilename ':: size(lambda,2) must be equal to nAR*nLags.'])
    end
    nMA = size(rho,2) - 1;
    rho = flip(rho,2); % Flip the MA matrix
    
    if isempty(dist)
        distT(1,svars) = nb_distribution();
        dist           = distT;
    else
        if ~isa(dist,'nb_distribution')
            error([mfilename ':: The dist input must be a nb_distribution object with size 1 x 1 or 1x' int2str(svars) '.'])
        end
        
        if nb_sizeEqual(dist,[1,1])
            dist = dist(:,ones(1,svars));
        elseif ~nb_sizeEqual(dist,[1,svars])
            error([mfilename ':: The dist input must be a nb_distribution object with size 1 x 1 or 1x' int2str(svars) '.'])
        end
    end
    
    % Check inputs on exogenous variables
    obsb = burn + obs;
    if isempty(inputs.exoData)
        B = nan(svars,0);
        X = nan(0,obsb);
    else
        B = inputs.B;
        if size(B,1) ~= svars
            error([mfilename ':: ''B'' input must have ' int2str(svars) ' rows.'])
        end
        X = inputs.exoData;
        if size(X,1) ~= obsb
            error([mfilename ':: ''exoData'' input must have ' int2str(obsb) ' rows.'])
        end
        if size(X,2) ~= size(B,2)
            error([mfilename ':: The number of columns of the inputs ''B'' and ''exoData'' inputs must match.'])
        end
        X = X';
    end
    
    % Preallocate and simulate residuals
    Y = zeros(svars*nAR,obsb+nMA+1,pages);
    E = random(dist,obsb+nMA+1,pages);
    E = permute(E,[4,1,2,3]); % svars x obs x pages
    
    % Construct matrices
    numRows = (nAR - 1)*svars;
    A       = [lambda;eye(numRows),zeros(numRows,svars)];
    
    % Construct simulations
    for ii = 1:pages 
        ttExo = 1;
        for tt = nMA+2:obsb+nMA+1
           Y(:,tt,ii)       = A*Y(:,tt-1,ii); 
           Y(1:svars,tt,ii) = Y(1:svars,tt,ii) + sum(rho.*E(:,tt-nMA:tt,ii),2) + B*X(:,ttExo);
           ttExo            = ttExo + 1;
        end
    end
    Y = Y(1:svars,burn+nMA+2:end,:);
    
    % Construct nb_ts object
    obj = nb_ts(permute(Y,[2,1,3]),'Simulation',start,vars);
    if ~isempty(X)
        exoVars = nb_appendIndexes('ExoVar',1:size(X,1)); 
        exoObj  = nb_ts(X(:,burn+1:end)','',start,exoVars);
        obj     = merge(obj,exoObj);
    end
    if nargout > 1
        E   = E(:,burn+nMA+2:end,:);
        res = nb_ts(permute(E,[2,1,3]),'Simulation',start,strcat('E_',vars));
    end
    
end
