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
% See the nb_var.priorHelp method to get help on the options of each of the
% below listed priors.
%
% You can get more information on each of these priors in the documentation
% ...\NBTOOLBOX\Documentation\theory.pdf
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
%          - 'glpMF'      : Same as 'glp', but as we now need a 
%                           gibbs sampler the below options are added. 
%                           This prior option supports missing 
%                           observations. Cannot apply block exogenous
%                           variables with this prior. The 'ARcoeff' 
%                           defaults to 0.9 in this case, as the model 
%                           must be stationary at the prior to run the 
%                           kalman filter.
%
%          - 'jeffrey'     : Diffuse jeffrey prior. 
%
%          - 'minnesota'   : Minnesota prior options. See page 6 of Koop  
%                            and Korobilis (2009). Output fields:
%
%          - 'minnesotaMF' : Same as 'minnesota'. This prior option
%                            supports missing observations. Cannot apply 
%                            block exogenous variables with this prior.
%
%          - 'nwishart'    : Normal-Wishart prior options. 
%
%          - 'nwishartMF'  : Same as 'nwishart', but as we now need a 
%                            gibbs sampler the below options are added. 
%                            This prior option supports missing 
%                            observations. Cannot apply block exogenous
%                            variables with this prior.
%
%          - 'inwishart'   : Independent Normal-Wishart prior options. 
%
%          - 'inwishartMF' : Same as 'inwishart'. This prior option
%                            supports missing observations.
%
%          - 'kkse'        : This is the prior used in the paper by 
%                            Koop and Korobilis (2014) extended by Schroder 
%                            and Eraslan (2021) to handle mixed frequency,
%                            but adapted to the VAR setting.
%
%          - 'dsge'        : DSGE-VAR prior. See Del Negro and Schorfheide 
%                            (2004), "Priors from General Equilibrium  
%                            Models for VARS". Let N be number of 
%                            dependent variables, L the number of lags of 
%                            the VAR, and C is equal to 1 if a constant is
%                            inlcuded. otherwise 0.
%
%          - 'laplace'     : A Laplace - Diffuse prior, i.e. the bayesian 
%                            LASSO. For more on this prior see nb_laplace.
%
%          - 'horseshoe'   : 
%                           
%
% - num  : Number of prior templates to make.
%
% Output:
% 
% - options : A struct.
%
% See also:
% nb_var, nb_model_generic.checkPosteriors, 
% nb_model_generic.getDSGEVARPriorMoments, nb_var.priorHelp, 
% nb_var.setPrior
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

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

            % Hyperpriors
            % Gamma with mode 1 and std 1
            prior.ARcoeffHyperprior = @(x)nb_distribution.gamma_pdf(x,2.618034,0.618034);
            
            % Gamma with mode 0.2 and std 0.4
            prior.lambdaHyperprior = @(x)nb_distribution.gamma_pdf(x,1.640388,0.312311);
            
            % Normal with mean 1e7 and std 1e7
            prior.VcHyperprior = @(x)nb_distribution.normal_pdf(x,1e7,1e7);
            
            % Gamma with mode 1 and std 1
            prior.S_scaleHyperprior = @(x)nb_distribution.gamma_pdf(x,2.618034,0.618034);
            
        case 'glpmf'
            
            prior.ARcoeff = 0.9;
            prior.lambda  = 0.2;
            prior.Vc      = 1e7;
            prior.S_scale = 1;
            prior.burn    = 500;
            prior.thin    = 2;
            prior.R_scale = [];

            % Hyperpriors
            % Gamma with mode 1 and std 1
            prior.ARcoeffHyperprior = @(x)nb_distribution.gamma_pdf(x,2.618034,0.618034);
            
            % Gamma with mode 0.2 and std 0.4
            prior.lambdaHyperprior = @(x)nb_distribution.gamma_pdf(x,1.640388,0.312311);
            
            % Normal with mean 1e7 and std 1e7
            prior.VcHyperprior = @(x)nb_distribution.normal_pdf(x,1e7,1e7);
            
            % Gamma with mode 1 and std 1
            prior.S_scaleHyperprior = @(x)nb_distribution.gamma_pdf(x,2.618034,0.618034);
              
            prior.nonStationary     = false;
            
        case 'jeffrey'
            
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
            
            if strcmpi(prior.type,'minnesotamf')
                prior.nonStationary = false;
                prior.R_scale       = [];
            end
             
        case 'nwishart'

            prior.V_scale = 10;
            prior.S_scale = 1;
            
            % Hyperpriors
            % Gamma with mode 10 and std 10
            prior.V_scaleHyperprior = @(x)nb_distribution.gamma_pdf(x,2.618034,6.180340);
            
            % Gamma with mode 1 and std 1
            prior.S_scaleHyperprior = @(x)nb_distribution.gamma_pdf(x,2.618034,0.618034);
            
        case 'nwishartmf'
            
            prior.V_scale = 10;
            prior.S_scale = 1;
            prior.burn    = 500;
            prior.thin    = 2;
            prior.LR      = false;
            prior.phi     = [];
            prior.H       = [];
            prior.SC      = false;
            prior.mu      = 1;
            prior.DIO     = false;
            prior.delta   = 1;
            prior.R_scale = [];
            
            % Hyperpriors
            % Gamma with mode 10 and std 10
            prior.V_scaleHyperprior = @(x)nb_distribution.gamma_pdf(x,2.618034,6.180340);
            
            % Gamma with mode 1 and std 1
            prior.S_scaleHyperprior = @(x)nb_distribution.gamma_pdf(x,2.618034,0.618034);
            
            prior.nonStationary = false;
            
        case {'inwishart','inwishartmf'} 

            prior.V_scale = 10;
            prior.S_scale = 1;
            prior.burn    = 500;
            prior.thin    = 2;
            
            if strcmpi(prior.type,'inwishartmf')
                prior.R_scale = [];
            end
            
        case 'kkse'
            
            prior.f0VarScale      = 10;
            prior.lambda0VarScale = 1;
            prior.V0VarScale      = 0.1;
            prior.Q0VarScale      = 0.1;
            prior.gamma           = 0.1;
            prior.method          = 'tvpmfsv';
            prior.l_1m            = 1;
            prior.l_1q            = 1;
            prior.l_2             = 1;
            prior.l_3             = 1;
            prior.l_4             = 1; 
            prior.l_1_endo_update = 0;
            prior.l_2_endo_update = 0;
            prior.l_3_endo_update = 0;
            prior.l_4_endo_update = 0;
            
        case {'horseshoe'} 

            prior.S_scale = 1;
            prior.burn    = 500;
            prior.thin    = 2;
            
            % horseshoe prior settings
            prior.lambda  = 0.1;
            prior.tau     = 0.1;
            prior.nu      = 0.1;
            prior.xi      = 0.1;
            
            prior.sv      = 0; % 0: constant variance 1: stochastic volatility
            
        case 'laplace'
            
            prior.constantDiffuse = true;
            prior.lambda          = [];
            prior.burn            = 500;
            prior.thin            = 2;
            
            
        case 'dsge'
            
            prior.lambda  = 0;
            prior.GammaYY = [];
            prior.GammaXX = [];
            prior.GammaXY = [];
            
        otherwise

            error([mfilename ':: Unsupported prior type ' type])

    end
    
    % Dummy observation priors
    dummyPriorTypes = {'glp','glpmf','jeffrey','minnesota','minnesotamf','nwishart','nwishartmf'};
    if any(strcmpi(type,dummyPriorTypes))
        
        prior.LR         = false;
        prior.phi        = [];
        prior.H          = [];
        prior.SC         = false;
        prior.mu         = 1;
        prior.DIO        = false;
        prior.delta      = 1;
        prior.SVD        = false;
        prior.rho        = 0.5;
        prior.periodsMax = 3;
        prior.dateSVD    = '';
        
        % Does the prior support hyperpriors?
        dummyHyperpriorTypes = {'glp','glpmf','nwishart','nwishartmf'};
        if any(strcmpi(type,dummyHyperpriorTypes))
            % Gamma with mode 1 and std 1
            prior.phiHyperprior = @(x)nb_distribution.gamma_pdf(x,2.618034,0.618034);

            % Gamma with mode 1 and std 1
            prior.muHyperprior = @(x)nb_distribution.gamma_pdf(x,2.618034,0.618034);

            % Gamma with mode 1 and std 1
            prior.deltaHyperprior = @(x)nb_distribution.gamma_pdf(x,2.618034,0.618034);
            
            % Beta with mode 0.8 and std 0.2
            prior.rhoHyperprior = @(x)nb_distribution.beta_pdf(x,3.0357,1.5089);
        end
        
    end
    
    % Settings for econometric bayes or hyperlearning
    if ~any(strcmpi(type,{'kkse','jeffrey'}))
        prior.logTransformation = false;
        prior.optParam          = {};
    end
    
end
