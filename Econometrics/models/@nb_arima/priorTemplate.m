function prior = priorTemplate(num)
% Syntax:
%
% prior = nb_arima.priorTemplate()
% prior = nb_arima.priorTemplate(num)
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
% - num     : Number of prior templates to make.
%
% Output:
% 
% - prior : A struct with different prior options. For help on these
%           options use nb_arima.priorHelp.
%
% See also:
% nb_arima, nb_arima.set, nb_arima.priorHelp
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 1
        num = 1; 
    end

    if num == 1
        prior = struct();
    else
        prior = nb_struct(num,{'ARcoeff'}); % Make it possible to initalize many objects
    end
    
    prior.ARcoeff     = [];
    prior.a_bar_AR    = 0.5000;
    prior.a_bar_MA    = 0.5000;
    prior.a_bar_sigma = sqrt(10);
    prior.a_bar_exo   = 100;

end
