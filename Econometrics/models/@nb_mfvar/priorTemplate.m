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
% See the nb_mfvar.priorHelp method to get help on the options of each of 
% the below listed priors.
%
% You can get more information on each of these priors in the documentation
% ...\NBTOOLBOX\Documentation\theory.pdf
% 
% Input:
%
% - type : A string;
%
%          - 'minnesotaMF' : Minnesota type prior options.
%
%          - 'nwishartMF'  : Normal-Wishart prior options. 
%
%          - 'glpMF'       : This is the prior used in the paper by  
%                            Giannone, Lenza and Primiceri (2014) adapted 
%                            to the mixed frequency setting. Cannot apply  
%                            block exogenous variables with this prior.
%
%          - 'inwishartMF' : Independent Normal-Wishart prior options. 
%
%          - 'kkse'        : This is the prior used in the paper by 
%                            Koop and Korobilis (2014) extended by Schroder 
%                            and Eraslan (2021) to handle mixed frequency,
%                            but adapted to the MF-VAR setting.
%
% - num  : Number of prior templates to make.
%
% Output:
% 
% - options : A struct.
%
% See also:
% nb_mfvar, nb_model_generic.checkPosteriors, nb_mfvar.priorHelp, 
% nb_mfvar.setPrior
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        num = 1; 
        if nargin < 1
            type = 'minnesotamf';
        end
    end

    if num == 1
        prior = struct();
    else
        prior = nb_struct(num,{'R_scale'}); % Make it possible to initalize many objects
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
            
            prior.f0VarScale      = 10;
            prior.lambda0VarScale = 1;
            prior.V0VarScale      = 0.1;
            prior.R_scale         = 10;
            prior.Q0VarScale      = 0.1;
            prior.gamma           = 0.1;
            prior.method          = 'tvpmfsv';
            prior.l_1m            = 1;
            prior.l_1q            = 1;
            prior.l_2             = 0.9;
            prior.l_3             = 1;
            prior.l_4             = 0.9; 
            prior.l_1_endo_update = 0;
            prior.l_2_endo_update = 0;
            prior.l_3_endo_update = 0;
            prior.l_4_endo_update = 0;

        otherwise
            error(['Unsupported prior type ' type])
    end

end
