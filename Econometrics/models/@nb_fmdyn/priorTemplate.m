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
%          - 'kkse' : This is the prior used in the paper by 
%                     Koop and Korobilis (2014) extended by Schroder 
%                     and Eraslan (2021) to handle mixed frequency.
%
% - num  : Number of prior templates to make.
%
% Output:
% 
% - options : A struct.
%
% See also:
% nb_fmdyn, nb_fmdyn.setPrior, nb_fmdyn.priorHelp
%
% Written by Kenneth Sæterhagen Paulsen and Maximilian Schröder

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        num = 1; 
        if nargin < 1
            type = 'kkse';
        end
    end

    if num == 1
        prior = struct();
    else
        prior = nb_struct(num,{'gamma'}); % Make it possible to initalize many objects
    end
    
    prior.type = type;
    switch lower(type)
        
        case 'kkse'
            
            prior.f0VarScale      = 10;
            prior.lambda0VarScale = 1;
            prior.V0VarScale      = 0.1;
            prior.Q0VarScale      = 0.1;
            prior.gamma           = 0.1;
            prior.method          = 'tvpmfsv';
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

            error(['Unsupported prior type ' type])

    end

end
