function results = nb_hrarima(y,p,i,q,constant,test,z,x,varargin)
% Syntax:
%
% results = nb_hrarima(y,p,i,q,constant)
% results = nb_hrarima(y,p,i,q,constant,test,z,x)
% results = nb_hrarima(y,p,i,q,constant,test,z,x,...)
%
% Description:
%
% Estimate a ARIMA(p,i,q) or ARIMAX(p,i,q) model using  the Hannan-Rissanen 
% algorithm.
% 
% y(t) = b*z + u(t)
% u(t) = lambda*u(t-1) + c*x + eps(t)
%
% Input:
% 
% - y         : A nobs x 1 double vector with the time-series.
% 
% - p         : The AR degree. As a number.
%
% - i         : The degree of integration. I.e. the number of times 
%               the time-series have to be differenced.
%
% - q         : The MA degree. As a number. 
%
% - constant  : Give 1 if a constant should be included, otherwise 
%               0. Default is 1.
%
% - test      : Give error if any of the roots of the AR process is outside
%               the unit circle.
%
% - z         : Exogenous regressors in the observation equation. As a 
%               nobs x nvars. Defualt is [].
%
% - x         : Exogenous regressors in the transition equation. As 
%               a nobs x mvars. Defualt is [].
%
% Optional input:
%
% - 'remove'  : Rows to remove from the estimation problem. As a 
%               nobs x 1 logical array. Specifies the rows of the 
%               dependent variable that includes data points needed 
%               to be removed. Lagged variables are being taken care 
%               of automatically! Elements to remove should be set to 
%               false.
%
% Output:
% 
% - results : A struct consiting of:
%
%             > beta       : The estimated coefficient of the 
%                            constant. Order; constant, AR, MA, ('texo', 
%                            'exo').
%             
%             > stdBeta    : The standard deviation of the estimated  
%                            coefficients. Constant, AR 
%                            coefficients then MA coefficients.
%
%             > tStatBeta  : The t-statistics of the estimated  
%                            coefficients. Constant, AR 
%                            coefficients then MA coefficients.
%
%             > pValBeta   : The p-values of the estimated  
%                            coefficients. Constant, AR 
%                            coefficients then MA coefficients.
%
%             > sigma      : Estimated std of the residual.
%
%             > likelihood : The log likehood.
%
%             > residual   : The estimated residual. As a
%                            nsample x 1 double. 
%
%             > X          : The model regressors. As a 
%                            nsample x nlags double.
%
%             > y          : The model dependent variable. As a
%                            nsample x 1 double.
%
%             > u          : The residual from the first stage regresson
%                            of the dependent variable on the exogenous
%                            and constant. If no constant and z is empty 
%                            this will be equal to y.
%
%             > z          : The exogenous variables included in the 
%                            observation equation.
%
%             > x          : The exogenous variables included in the 
%                            transition equation.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 8
        x = [];
        if nargin < 7
            z = [];
            if nargin < 6
                test = true;
                if nargin < 5
                    constant = 1;
                end
            end
        end
    end

    default = {'remove', [], @(x)or(islogical(x),isempty(x))};
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end

    [T,dim2] = size(y);
    if dim2 > 1
        error('The y input must be an nobs x 1 double.')
    end
    
    %==============================================================
    % Transformation
    %==============================================================
    for hh = 1:i
        y = diff(y);
    end 
    z = z(1+i:end,:);
    x = x(1+i:end,:);

    if ~isempty(inputs.remove)

        inputs.remove = inputs.remove(:);
        if size(inputs.remove,1) ~= T
            error('The ''remove'' input must has as many observations as the y input.')
        end

        % Remove these rows of the estimation problem, where remove more
        % rows, as we add lags!
        locRem             = find(~inputs.remove,1,'last');
        addedLags          = locRem + 1:min(locRem + p + q,size(y,1));
        indKeep            = inputs.remove;
        indKeep(addedLags) = false;
        indKeep            = indKeep(1+i:end);

    else
        indKeep = true(size(y));
    end
    
    if ~isempty(z) || constant
        [estParZ,stdEstParZ,tStatEstParZ,pValEstParZ,u] = nb_ols(y(indKeep),z(indKeep,:),constant);
        if any(~indKeep)
            % Fill in removed observations 
            zRem = z(~indKeep,:);
            if constant
                zRem = [ones(size(zRem,1),1),zRem];
            end
            uAll           = nan(size(y));
            uAll(indKeep)  = u;
            uAll(~indKeep) = y(~indKeep) - zRem*estParZ;
            u              = uAll;
        end
    else
        u = y;
    end

    %==============================================================
    % Estimation
    %==============================================================

    % First step: Estimate AR(p + q)
    %--------------------------------------------------------------
    r = p + q;
    if r + q >= T
        error('The sample is to short to use the Hannan-Rissanen algorithm.')
    end
    ulag    = nb_mlag(u,r);
    ut      = u(r + 1:end);
    ulag    = ulag(r + 1:end,:);
    indKeep = indKeep(r + 1:end);
    if isempty(x)
        X = ulag;
    else
        if size(x,1) ~= size(y,1)
            error('The x input must has as many observations as the y input.')
        end
        X = [ulag,x(r+1:end,:)];
    end
    [beta,~,~,~,res] = nb_ols(ut(indKeep),X(indKeep,:),false);
    if any(~indKeep)
        % Fill in removed observations
        XRem             = X(~indKeep,:);
        resAll           = nan(size(ut));
        resAll(indKeep)  = res;
        resAll(~indKeep) = ut(~indKeep) - XRem*beta;
        res              = resAll;
    end


    % Second step: Use the residuals to from the step before to 
    % estimate the ARMA(p,q) coefficients until convergance
    %--------------------------------------------------------------

    % Form the regressors
    reslag  = nb_mlag(res,q);  
    ut      = ut(q + 1:end);
    reslag  = reslag(q + 1:end,:);
    ulag    = ulag(q + 1:end,1:p);
    indKeep = indKeep(q + 1:end,:);
    if isempty(x)
        X = [ulag,reslag];
    else
        X = [ulag,reslag,x(q+r+1:end,:)];
    end

    % Estimate 
    [estPar,stdEstPar,tStatEstPar,pValEstPar,residual] = nb_ols(ut(indKeep),X(indKeep,:),false);

    if any(~indKeep)
        XRem             = X(~indKeep,:);
        resAll           = nan(size(ut));
        resAll(indKeep)  = residual;
        resAll(~indKeep) = ut(~indKeep) - XRem*beta;
    else
        resAll = residual;
    end

    if ~isempty(z) || constant
        if constant 
            estPar      = [estParZ(1);estPar;estParZ(2:end)];
            stdEstPar   = [stdEstParZ(1);stdEstPar;stdEstParZ(2:end)];
            tStatEstPar = [tStatEstParZ(1);tStatEstPar;tStatEstParZ(2:end)];
            pValEstPar  = [pValEstParZ(1);pValEstPar;pValEstParZ(2:end)];
        elseif ~isempty(z)
            estPar      = [estPar;estParZ];
            stdEstPar   = [stdEstPar;stdEstParZ];
            tStatEstPar = [tStatEstPar;tStatEstParZ];
            pValEstPar  = [pValEstPar;pValEstParZ];
        end
    end
    
    % Run a stability check of initial estimates
    %--------------------------------------------------------------
    if test
        absr = abs(roots([1,-estPar(1 + constant:p + constant)']));
        if any(absr >= 1)
            error('nb_hrarima:invalidRoots',[mfilename ':: The roots of the ARIMA(' int2str(p) ',' int2str(i) ',' int2str(q) ') Lag '...
                'operator polynominal is outside the unit circle. Cannot estimate this model.'])
        end
    end
    
    % Report results
    %--------------------------------------------------------------
    results            = struct();
    results.beta       = estPar;
    results.stdBeta    = stdEstPar;
    results.tStatBeta  = tStatEstPar;
    results.pValBeta   = pValEstPar;
    results.sigma      = residual'*residual/(size(residual,1) - size(estPar,1));
    results.likelihood = nb_olsLikelihood(residual);
    results.residual   = resAll;
    results.X          = X;
    results.y          = y(r + q + 1:end,:);
    results.u          = ut;
    results.z          = z(r + q + i + 1:end,:);
    results.x          = x(r + q + i + 1:end,:);
      
end
