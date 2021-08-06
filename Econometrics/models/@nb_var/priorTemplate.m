function prior = priorTemplate(type,num)
% Syntax:
%
% prior = nb_var.priorTemplate()
% prior = nb_var.priorTemplate(type)
% prior = nb_var.priorTemplate(type,num)
%
% Description:
%
% Construct a struct which can be given to the method setPrior.
%
% The structure provided the user the possibility to set different
% prior options.
%
% Caution: Hyperpriors will only be used if both the empirical and 
%          hyperprior options are set to true!
% 
% Input:
%
% - type : A string;
%
%          - 'glp'        : This is the prior used in the paper by 
%                           Giannone, Lenza and Primiceri (2014). Cannot 
%                           apply block exogenous variables with this 
%                           prior.
%
%            > 'ARcoeff'  : Hyperparameter on first lag coefficient of each
%                           equation. Default is 1.
%
%            > 'coeff'    : See same options for the 'minnesota' prior. 
%
%            > 'lambda'   : Hyperparameter that controls the overall 
%                           tightness of this prior. Defualt is 0.2.
%
%            > 'Vc'       : Hyperparamter on exogenous variables. Default
%                           is 1e7.
%
%             > 'S_scale' : Prior scale of prior on sigma. Default is 1,
%                           i.e. OLS. 
%
%          - 'glpMF'      : Same as 'glp', but as we now need a 
%                           gibbs sampler the below options are added. 
%                           This prior option supports missing 
%                           observations. Cannot apply block exogenous
%                           variables with this prior. The 'ARcoeff' 
%                           defaults to 0.9 in this case, as the model 
%                           must be stationary at the prior to run the 
%                           kalman filter.
%
%             > 'burn'    : How many draws that should be used as burn
%                           in. Default is 500.
%
%             > 'thin'    : Every k draws are kept when doing gibbs.
%                           This options sets k. Default is 2. Increase
%                           this option to prevent autocorrelated
%                           draws. See nb_model_generic.checkPosteriors
%                           to test for autocorrelated draws.
%
%          - 'jeffrey'     : Diffuse jeffrey prior. No options.
%
%          - 'minnesota'   : Minnesota prior options. See page 6 of Koop  
%                            and Korobilis (2009). Output fields:
%
%             > 'a_bar_1' : Hyperparamter on own lags. Default is 0.5.
%
%             > 'a_bar_2' : Hyperparamter on other lags. Default is 0.5.
% 
%             > 'a_bar_3' : Hyperparamter on exogenous variables. Default 
%                           is 100.
%
%             > 'ARcoeff' : Hyperparameter on first lag coefficient of each
%                           equation. Default is 0.9.
%
%             > 'coeff'   : A N x 2 cell array with specific priors
%                           on some coefficients. In the first column
%                           you must provide the name of the coefficient,
%                           name of dependent + _ + name of rhs variable
%                           + lag specifier. E.g. 'Var1_Var1_lag1' or
%                           'Var1_Var2'. In the last example Var2 is an
%                           exogenous variable. In the second column
%                           you give the prior value, as a scalar double.
%
%             > 'method'  : Sets the method to use to draw from the
%                           posterior. Either 'default' (default) or any 
%                           other string. 'default' uses (a fixed) 
%                           covariance matrix of the shocks (i.e. the 
%                           prior). Otherwise it also samples from the 
%                           posterior distribution of the covariance 
%                           matrix, as in the same way as in the case 
%                           of the independent normal wishart (inwishart)
%                           prior. The 'burn', 'thin' and 'S_scale' options 
%                           only applies to this last case.
%
%             > 'burn'    : How many draws that should be used as burn
%                           in. Default is 500.
%
%             > 'thin'    : Every k draws are kept when doing gibbs.
%                           This options sets k. Default is 2. Increase
%                           this option to prevent autocorrelated
%                           draws. See nb_model_generic.checkPosteriors
%                           to test for autocorrelated draws.
%
%             > 'S_scale' : Prior scale of prior on sigma. Default is 1,
%                           i.e. OLS. 
%
%          - 'minnesotaMF' : Same as 'minnesota'. This prior option
%                            supports missing observations. Cannot apply 
%                            block exogenous variables with this prior.
%
%          - 'nwishart'    : Normal-Wishart prior options. 
%
%             > 'V_scale' : Scale of the prior of the variance of the
%                           coefficients. Default is 10.
%
%             > 'S_scale' : Prior scale of sigma. Default is 1.
%
%          - 'nwishartMF'  : Same as 'nwishart', but as we now need a 
%                            gibbs sampler the below options are added. 
%                            This prior option supports missing 
%                            observations. Cannot apply block exogenous
%                            variables with this prior.
%
%             > 'burn'    : How many draws that should be used as burn
%                           in. Default is 500.
%
%             > 'thin'    : Every k draws are kept when doing gibbs.
%                           This options sets k. Default is 2. Increase
%                           this option to prevent autocorrelated
%                           draws. See nb_model_generic.checkPosteriors
%                           to test for autocorrelated draws.
%
%          - 'inwishart'   : Independent Normal-Wishart prior options. 
%
%             > 'V_scale' : Scale of the prior of the variance of the
%                           coefficients. Default is 10.
%
%             > 'S_scale' : Prior scale of sigma. Default is 1.
%
%             > 'burn'    : How many draws that should be used as burn
%                           in. Default is 500.
%
%             > 'thin'    : Every k draws are kept when doing gibbs.
%                           This options sets k. Default is 2. Increase
%                           this option to prevent autocorrelated
%                           draws. See nb_model_generic.checkPosteriors
%                           to test for autocorrelated draws.
%
%          - 'inwishartMF' : Same as 'inwishart'. This prior option
%                            supports missing observations.
%
%          - For the 'glp', 'jeffrey', 'minnesota' and 'nwishart' priors 
%            you also have the oppurtunity to apply the prior for the long
%            run as in Giannone et. al (2014).
%
%             > 'LR'      : Apply priors for the long run. See also
%                           nb_var.applyLongRunPriors. true or false.
%
%             > 'phi'     : Shrinkage parameter for the long run prior. 
%                           For more see nb_var.applyLongRunPriors. 
%
%             > 'H'       : Matrix that specifies the cointegration 
%                           relations. For more see 
%                           nb_var.applyLongRunPriors.
%
%          - For the 'glp', 'jeffrey', 'minnesota' and 'nwishart' priors 
%            you also have the oppurtunity to apply the sum-of-coefficients  
%            prior by Doan, Litterman, and Sims (1984).
%
%             > 'SC'      : Apply sum-of-coefficients prior. true or false.
%
%             > 'mu'      : Shrinkage parameter of the sum-of-coefficients  
%                           prior. As mu goes to 0 implies the presence  
%                           of a unit root in each equation and rules out 
%                           cointegration. 
%
%          - For the 'glp', 'jeffrey', 'minnesota' and 'nwishart' priors 
%            you also have the oppurtunity to apply the dummy-initial-
%            observation prior by Sims (1993).
%
%             > 'DIO'     : Apply dummy-initial-observation prior. true or 
%                           false.
%
%             > 'delta'   : Shrinkage parameter of the dummy-initial-
%                           observation prior. As delta goes to 0 all the 
%                           variables of the VAR are forced to be at
%                           their unconditional mean, or the system is 
%                           characterized by the presence of an
%                           unspecified number of unit roots without 
%                           drift. As such, the dummy-initialobservation 
%                           prior is consistent with cointegration
%
% - num  : Number of prior templates to make.
%
% Output:
% 
% - options : A struct.
%
% See also:
% nb_var, nb_model_generic.checkPosteriors
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        num = 1; 
        if nargin < 1
            type = 'jeffrey';
        end
    end

    if num == 1
        prior = struct();
    else
        prior = nb_struct(num,{'constant'}); % Make it possible to initalize many objects
    end
    
    prior.type = type;
    switch lower(type)
        
        case 'glp'
            
            prior.ARcoeff = 1;
            prior.lambda  = 0.2;
            prior.Vc      = 1e7;
            prior.S_scale = 1;
            prior.LR      = false;
            prior.phi     = [];
            prior.H       = [];
            prior.SC      = false;
            prior.mu      = 1; 
            prior.DIO     = false;
            prior.delta   = 1;

            % Hyperpriors
            % Gamma with mode 1 and std 1
            prior.ARcoeffHyperprior = @(x)nb_distribution.gamma_pdf(x,2.618034,0.618034);
            
            % Gamma with mode 0.2 and std 0.4
            prior.lambdaHyperprior = @(x)nb_distribution.gamma_pdf(x,1.640388,0.312311);
            
            % Normal with mean 1e7 and std 1e7
            prior.VcHyperprior = @(x)nb_distribution.normal_pdf(x,1e7,1e7);
            
            % Gamma with mode 1 and std 1
            prior.S_scaleHyperprior = @(x)nb_distribution.gamma_pdf(x,2.618034,0.618034);
            
            % Gamma with mode 1 and std 1
            prior.phiHyperprior = @(x)nb_distribution.gamma_pdf(x,2.618034,0.618034);
            
            % Gamma with mode 1 and std 1
            prior.muHyperprior = @(x)nb_distribution.gamma_pdf(x,2.618034,0.618034);
            
            % Gamma with mode 1 and std 1
            prior.deltaHyperprior = @(x)nb_distribution.gamma_pdf(x,2.618034,0.618034);
            
        case 'glpmf'
            
            prior.ARcoeff = 0.9;
            prior.lambda  = 0.2;
            prior.Vc      = 1e7;
            prior.S_scale = 1;
            prior.burn    = 500;
            prior.thin    = 2;

            % Hyperpriors
            % Gamma with mode 1 and std 1
            prior.ARcoeffHyperprior = @(x)nb_distribution.gamma_pdf(x,2.618034,0.618034);
            
            % Gamma with mode 0.2 and std 0.4
            prior.lambdaHyperprior = @(x)nb_distribution.gamma_pdf(x,1.640388,0.312311);
            
            % Normal with mean 1e7 and std 1e7
            prior.VcHyperprior = @(x)nb_distribution.normal_pdf(x,1e7,1e7);
            
            % Gamma with mode 1 and std 1
            prior.S_scaleHyperprior = @(x)nb_distribution.gamma_pdf(x,2.618034,0.618034);
              
        case 'jeffrey'
            
            prior.LR    = false;
            prior.phi   = [];
            prior.H     = [];
            prior.SC    = false;
            prior.mu    = 1;
            prior.DIO   = false;
            prior.delta = 1;

        case {'minnesota','minnesotamf'}

            prior.a_bar_1 = 0.5;
            prior.a_bar_2 = 0.5;
            prior.a_bar_3 = 100;
            prior.ARcoeff = 0.9;
            prior.coeff   = {};
            prior.method  = 'mci';
            prior.burn    = 500;
            prior.thin    = 2;
            prior.S_scale = 1;
            if strcmpi(type,'minnesota')
                prior.LR    = false;
                prior.phi   = [];
                prior.H     = [];
                prior.SC    = false;
                prior.mu    = 1;
                prior.DIO   = false;
                prior.delta = 1;
            end
            
        case 'nwishart'

            prior.V_scale = 10;
            prior.S_scale = 1;
            prior.LR      = false;
            prior.phi     = [];
            prior.H       = [];
            prior.SC      = false;
            prior.mu      = 1;
            prior.DIO     = false;
            prior.delta   = 1;
            
            % Hyperpriors
            % Gamma with mode 10 and std 10
            prior.V_scaleHyperprior = @(x)nb_distribution.gamma_pdf(x,2.618034,6.180340);
            
            % Gamma with mode 1 and std 1
            prior.S_scaleHyperprior = @(x)nb_distribution.gamma_pdf(x,2.618034,0.618034);
            
            % Gamma with mode 1 and std 1
            prior.phiHyperprior = @(x)nb_distribution.gamma_pdf(x,2.618034,0.618034);
            
            % Gamma with mode 1 and std 1
            prior.muHyperprior = @(x)nb_distribution.gamma_pdf(x,2.618034,0.618034);
            
            % Gamma with mode 1 and std 1
            prior.deltaHyperprior = @(x)nb_distribution.gamma_pdf(x,2.618034,0.618034);
            
        case 'nwishartmf'
            
            prior.V_scale = 10;
            prior.S_scale = 1;
            prior.burn    = 500;
            prior.thin    = 2;
            
        case {'inwishart','inwishartmf'} 

            prior.V_scale = 10;
            prior.S_scale = 1;
            prior.burn    = 500;
            prior.thin    = 2;

        otherwise

            error([mfilename ':: Unsupported prior type ' type])

    end

end
