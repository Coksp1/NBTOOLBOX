function prior = priorTemplate(type,num)
% Syntax:
%
% prior = nb_fmdyn.priorTemplate()
% prior = nb_fmdyn.priorTemplate(type)
% prior = nb_fmdyn.priorTemplate(type,num)
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
%          - 'kkse'        : This is the prior used in the paper by 
%                          Koop and Korobilis (2014) extended by Schroder 
%                          and Eraslan (2021) to handle mixed frequency.
%
%            > 'f0VarScale'      : Scale factor on the variance of the  
%                                  prior on the initial value of factors.
%                                  Default is 10. N(0,f0VarScale*I)
%
%            > 'lambda0VarScale' : Scale factor on the variance of the  
%                                  prior on the initial value of the factor 
%                                  loadings. Default is 1. 
%                                  N(0,lambdaVarScale*I)
%           
%            > 'V0VarScale'      : Scale factor on the mean of the  
%                                  prior on the initial value of the 
%                                  measurement equation covariance matrix.  
%                                  Default is 0.1. Dogmatic prior set to 
%                                  V0VarScale*I.
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
%           > 'l_1m'             : Starting value of:
%                                  Decay factor for the measurement error
%                                  variance of the monthly variables. A
%                                  smaller value puts smaller weight on
%                                  past observations and thus allows for
%                                  faster parameter change. A value of 1
%                                  implies constant parameters. Default
%                                  is 0.9.
%
%            > 'l_1q'           :  Starting value of:
%                                  Decay factor for the measurement error
%                                  variance of the quarterly variables. A
%                                  smaller value puts smaller weight on
%                                  past observations and thus allows for
%                                  faster parameter change. A value of 1
%                                  implies constant parameters. Default
%                                  is 0.9.
%
%            > 'l_2'              : Starting value of:
%                                  Decay factor for the factor error
%                                  variance. A smaller value puts smaller 
%                                  weight on past observations and thus 
%                                  allows for faster parameter change. A 
%                                  value of 1 implies constant parameters. 
%                                  Default is 0.9.
%
%            > 'l_3'              : Starting value of:
%                                  Decay factor for the loadings' error
%                                  variance. A smaller value puts smaller 
%                                  weight on past observations and thus 
%                                  allows for faster parameter change. A 
%                                  value of 1 implies constant parameters.
%                                  Default is 0.9.
%
%            > 'l_4'              : Starting value of:
%                                  Decay factor for the factor VAR
%                                  parameters' error variance.
%                                  A smaller value puts smaller 
%                                  weight on past observations and thus 
%                                  allows for faster parameter change. A 
%                                  value of 1 implies constant parameters. 
%                                  Default is 0.9.
%
%            > 'l_1_endo_update': Controls the endogenous forgetting
%                                 factors
%                                 1: l_1m and l_1q are time-varying/endogenous
%                                 0: l_1m and l_1q are constant/static 
%                                 Default is 0.
%                                
%            > 'l_2 endo_update': Controls the endogenous forgetting
%                                 factors
%                                 1: l_2 is time-varying/endogenous
%                                 0: l_2 is constant/static 
%                                 Default is 0.
%
%            > 'l_3_endo_update': Controls the endogenous forgetting
%                                 factors
%                                 1: l_3 is time-varying/endogenous
%                                 0: l_3 is constant/static
%                                 Default is 0.
%
%            > 'l_4_endo_update': Controls the endogenous forgetting
%                                 factors
%                                 1: l_4 is time-varying/endogenous
%                                 0: l_4 is constant/static 
%                                 Default is 0.
%
% - num  : Number of prior templates to make.
%
% Output:
% 
% - options : A struct.
%
% See also:
% nb_fmdyn
%
% Written by Kenneth Sæterhagen Paulsen and Maximilian Schröder

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        num = 1; 
        if nargin < 1
            type = 'kkse';
        end
    end

    if num == 1
        prior = struct();
    else
        prior = nb_struct(num,{'constant'}); % Make it possible to initalize many objects
    end
    
    prior.type = type;
    switch lower(type)
        
        case 'kkse'
            
            prior.f0VarScale     = 10;
            prior.lambda0VarScale = 1;
            prior.V0VarScale     = 0.1;
            prior.Q0VarScale     = 0.1;
            prior.gamma          = 0.1;
            prior.method         = 'tvpmfsv';
            prior.l_1m            = 0.9;
            prior.l_1q            = 0.9;
            prior.l_2             = 0.9;
            prior.l_3             = 0.9;
            prior.l_4             = 0.9;
            prior.l_1_endo_update = 0;
            prior.l_2_endo_update = 0;
            prior.l_3_endo_update = 0;
            prior.l_4_endo_update = 0;
            
        otherwise

            error([mfilename ':: Unsupported prior type ' type])

    end

end
