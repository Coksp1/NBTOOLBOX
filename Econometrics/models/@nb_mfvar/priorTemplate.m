function prior = priorTemplate(type,num)
% Syntax:
%
% prior = nb_mfvar.priorTemplate()
% prior = nb_mfvar.priorTemplate(type)
% prior = nb_mfvar.priorTemplate(type,num)
%
% Description:
%
% Construct a struct which can be given to the method setPrior.
%
% The structure provided the user the possibility to set different
% prior options.
% 
% Input:
%
% - type : A string;
%
%          - 'minnesotaMF' : Minnesota type prior options.
%
%               > 'a_bar_1' : Hyperparamter on own lags. Default is 0.5.
%
%               > 'a_bar_2' : Hyperparamter on other lags. Default is 0.5.
% 
%               > 'a_bar_3' : Hyperparamter on other lags. Default is 100.
%
%               > 'ARcoeff' : Hyperparameter on first lag coefficient of 
%                             each equation. Default is 0.9.
%
%               > 'coeff'   : A N x 2 cell array with specific priors
%                             on some coefficients. In the first column
%                             you must provide the name of the coefficient,
%                             name of dependent + _ + name of rhs variable
%                             + lag specifier. E.g. 'Var1_Var1_lag1' or
%                             'Var1_Var2'. In the last example Var2 is an
%                             exogenous variable. In the second column
%                             you give the prior value, as a scalar double.
%
%               > 'method'  : Sets the method to use to draw from the
%                             posterior. Either 'default' (default) or any 
%                             other string. 'default' uses (a fixed) 
%                             covariance matrix of the shocks (i.e. the 
%                             prior). Otherwise it also samples from the 
%                             posterior distribution of the covariance 
%                             matrix, as in the same way as in the case 
%                             of the independent normal wishart (inwishart)
%                             prior. The 'burn', 'thin' and 'S_scale'  
%                             options only applies to this last case.
%
%               > 'burn'    : How many draws that should be used as burn
%                             in. Default is 500.
%
%               > 'thin'    : Every k draws are kept when doing gibbs.
%                             This options sets k. Default is 2. Increase
%                             this option to prevent autocorrelated
%                             draws. See nb_model_generic.checkPosteriors
%                             to test for autocorrelated draws.
%
%               > 'S_scale' : Prior scale of sigma, i.e. the covariance 
%                             matrix of the residuals. Default is 1. 
%
%               > 'R_scale' : Inverse prior scale of R, i.e. the covariance 
%                             matrix of the measurement errors. Default is 
%                             10. Default is to only used it for high 
%                             frequency variables, if series are measured 
%                             with more than one frequency. To apply it to
%                             specific variables use a cell array. In the 
%                             first column you must provide the name of
%                             dependent variable. E.g. 'Var1'. In the 
%                             second column you give the prior value, 
%                             as a scalar double. Full example 
%                             {'Var1',inf;'Var2',10}. Here you allow for no
%                             measurement error in 'Var1', and some
%                             measurement error in 'Var2'. All variables
%                             not provided when a cell is used, are set to
%                             inf. 
%
%                             The posterior is constructed by dividing the
%                             variance of each series by the scaling
%                             parameters.
%
%               > 'mixing'  : Set to 'low' to use the low frequency
%                             observations when forming the prior of the
%                             covariance matrix of the residuals. Only
%                             in use if you have declared variables as
%                             mixing. Default is to use the high frequency
%                             variable ('high').
%
%          - 'nwishartMF'  : Normal-Wishart prior options. 
%
%               > 'V_scale' : Scale of the prior of the variance of the
%                             coefficients. Default is 10.
%
%               > 'S_scale' : Prior scale of sigma, i.e. the covariance 
%                             matrix of the residuals. Default is 1.
%
%               > 'burn'    : How many draws that should be used as burn
%                             in. Default is 500.
%
%               > 'thin'    : Every k draws are kept when doing gibbs.
%                             This options sets k. Default is 2. Increase
%                             this option to prevent autocorrelated
%                             draws. See nb_model_generic.checkPosteriors
%                             to test for autocorrelated draws.
%
%               > 'R_scale' : Inverse prior scale of R, i.e. the covariance 
%                             matrix of the measurement errors. Default is 
%                             10. Default is to only used it for high 
%                             frequency variables, if series are measured 
%                             with more than one frequency. To apply it to
%                             specific variables use a cell array. In the 
%                             first column you must provide the name of
%                             dependent variable. E.g. 'Var1'. In the 
%                             second column you give the prior value, 
%                             as a scalar double. Full example 
%                             {'Var1',inf;'Var2',10}. Here you allow for no
%                             measurement error in 'Var1', and some
%                             measurement error in 'Var2'. All variables
%                             not provided when a cell is used, are set to
%                             inf. 
%
%                             The posterior is constructed by dividing the
%                             variance of each series by the scaling
%                             parameters.
%
%          - 'glpMF' : This is the prior used in the paper by Giannone, 
%                      Lenza and Primiceri (2014) adapted to the mixed 
%                      frequency setting. Cannot apply block exogenous 
%                      variables with this prior.
%
%               > 'ARcoeff'  : Hyperparameter on first lag coefficient of 
%                              each equation. Default is 0.9.
%
%               > 'coeff'    : See same options for the 'minnesota' prior. 
%
%               > 'lambda'   : Hyperparameter that controls the overall 
%                              tightness of this prior. Defualt is 0.2.
%
%               > 'Vc'       : Hyperparamter on exogenous variables. 
%                              Default is 1e7.
%
%               > 'S_scale'  : Prior scale of prior on sigma. Default is 1,
%                              i.e. OLS.
%
%               > 'burn'    : How many draws that should be used as burn
%                             in. Default is 500.
%
%               > 'thin'    : Every k draws are kept when doing gibbs.
%                             This options sets k. Default is 2. Increase
%                             this option to prevent autocorrelated
%                             draws. See nb_model_generic.checkPosteriors
%                             to test for autocorrelated draws.
%
%          - 'inwishartMF' : Independent Normal-Wishart prior options. 
%
%               > 'V_scale' : Scale of the prior of the variance of the
%                             coefficients. Default is 10.
%
%               > 'S_scale' : Prior scale of sigma, i.e. the covariance 
%                             matrix of the residuals. Default is 1.
%
%               > 'burn'    : How many draws that should be used as burn
%                             in. Default is 500.
%
%               > 'thin'    : Every k draws are kept when doing gibbs.
%                             This options sets k. Default is 2. Increase
%                             this option to prevent autocorrelated
%                             draws. See nb_model_generic.checkPosteriors
%                             to test for autocorrelated draws.
%
%               > 'R_scale' : Inverse prior scale of R, i.e. the covariance 
%                             matrix of the measurement errors. Default is 
%                             10. Default is to only used it for high 
%                             frequency variables, if series are measured 
%                             with more than one frequency. To apply it to
%                             specific variables use a cell array. In the 
%                             first column you must provide the name of
%                             dependent variable. E.g. 'Var1'. In the 
%                             second column you give the prior value, 
%                             as a scalar double. Full example 
%                             {'Var1',inf;'Var2',10}. Here you allow for no
%                             measurement error in 'Var1', and some
%                             measurement error in 'Var2'. All variables
%                             not provided when a cell is used, are set to
%                             inf. 
%
%                             The posterior is constructed by dividing the
%                             variance of each series by the scaling
%                             parameters.
%
%          - 'kkse'        : This is the prior used in the paper by 
%                            Koop and Korobilis (2014) extended by Schroder 
%                            and Eraslan (2021) to handle mixed frequency,
%                            but adapted to the VAR setting.
%
%            > 'f0VarScale'      : Scale factor on the variance of the  
%                                  prior on the initial value of factors.
%                                  Default is 10. N(0,f0VarScale*I)
%
%            > 'lambda0VarScale' : Scale factor on the variance of the  
%                                  prior on the initial value of the factor 
%                                  loadings. Default is 1. 
%                                  N(0,lambdaVarScale*I). !!Remove!!
%           
%            > 'V0VarScale'      : Scale factor on the mean of the  
%                                  prior on the initial value of the 
%                                  measurment equation covariance matrix.  
%                                  Default is 0.1. Dogmatic prior set to 
%                                  V0VarScale*I. !!Remove!!
%
%            > 'Q0VarScale'      : Scale factor on the mean of the  
%                                  prior on the initial value of the 
%                                  state equation covariance matrix.  
%                                  Default is 0.1. Dogmatic prior set to 
%                                  Q0VarScale*I.
%
%            > 'gamma'           : Hyperparameter on prior variance of the
%                                  coefficients of the state equations. 
%                                  On the form V(i,j) = gamma./
%                                  (ceil(j/options.nFactors).^2). Where
%                                  V is a matrix with size option.nFactors 
%                                  x option.nLags*option.nFactors. Default 
%                                  value is 0.1.
%
%            > 'l_1m'            : Decay factor for the measurement error
%                                  variance of the monthly variables. A
%                                  smaller value puts smaller weight on
%                                  past observations and thus allows for
%                                  faster parameter change. A value of 1
%                                  implies constant parameters. Default
%                                  is 1. Do not adjust!
%
%            > 'l_1q'           :  Decay factor for the measurement error
%                                  variance of the quarterly variables. A
%                                  smaller value puts smaller weight on
%                                  past observations and thus allows for
%                                  faster parameter change. A value of 1
%                                  implies constant parameters. Default
%                                  is 1. Do not adjust!
%
%            > 'l_2'             : Decay factor for the factor error
%                                  variance. A smaller value puts smaller 
%                                  weight on past observations and thus 
%                                  allows for faster parameter change. A 
%                                  value of 1 implies constant parameters. 
%                                  Default is 0.9.
%
%            > 'l_3'             : Decay factor for the loadings' error
%                                  variance. A smaller value puts smaller 
%                                  weight on past observations and thus 
%                                  allows for faster parameter change. A 
%                                  value of 1 implies constant parameters.
%                                  Default is 1. Do not adjust!
%
%            > 'l_4'             : Decay factor for the factor VAR
%                                  parameters' error variance.
%                                  A smaller value puts smaller 
%                                  weight on past observations and thus 
%                                  allows for faster parameter change. A 
%                                  value of 1 implies constant parameters. 
%                                  Default is 0.9.
%
% - num  : Number of prior templates to make.
%
% Output:
% 
% - options : A struct.
%
% See also:
% nb_mfvar, nb_model_generic.checkPosteriors
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        num = 1; 
        if nargin < 1
            type = 'minnesotamf';
        end
    end

    if num == 1
        prior = struct();
    else
        prior = nb_struct(num,{'constant'}); % Make it possible to initalize many objects
    end
    
    prior.type = type;
    switch lower(type)

        case 'minnesotamf'

            prior.a_bar_1  = 0.5;
            prior.a_bar_2  = 0.5;
            prior.a_bar_3  = 100;
            prior.ARcoeff  = 0.9;
            prior.coeff    = {};
            prior.S_scale  = 1;
            prior.method   = 'default';
            prior.burn     = 500;
            prior.thin     = 2;
            prior.R_scale  = 10; 
            prior.maxTries = 100;
            prior.mixing   = 'high';
            
        case 'glpmf'

            prior.ARcoeff  = 0.9;
            prior.lambda   = 0.2;
            prior.Vc       = 1e7;
            prior.S_scale  = 1;
            prior.burn     = 500;
            prior.thin     = 2;
            prior.R_scale  = 10; 
            prior.maxTries = 100;
            prior.mixing   = 'high';    
             
        case 'nwishartmf'

            prior.V_scale  = 10;
            prior.S_scale  = 1;
            prior.burn     = 500;
            prior.thin     = 2;
            prior.R_scale  = 10; 
            prior.maxTries = 100;
            
        case 'inwishartmf' 

            prior.V_scale  = 10;
            prior.S_scale  = 1;
            prior.burn     = 500;
            prior.thin     = 2;
            prior.R_scale  = 10; 
            prior.maxTries = 100;
            
        case 'kkse'
            
            % TODO: update here to default correctly!
            prior.f0VarScale      = 10;
            prior.lambda0VarScale = 1;
            prior.V0VarScale      = 0.1;
            prior.Q0VarScale      = 0.1;
            prior.gamma           = 0.1;
            prior.method          = 'tvpmfsv';
            prior.l_1m            = 1;
            prior.l_1q            = 1;
            prior.l_2             = 0.9;
            prior.l_3             = 1;
            prior.l_4             = 0.9;        

        otherwise
            error([mfilename ':: Unsupported prior type ' type])
    end

end
