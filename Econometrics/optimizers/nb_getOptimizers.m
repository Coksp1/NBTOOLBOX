function optimizers = nb_getOptimizers(type)
% Syntax:
%
% optimizers = nb_getOptimizers(type)
%
% Description:
%
% Get the optimizers you have available for different estimation jobs.
% 
% This function also tries to detect optimizer of other toolboxes, such 
% as csminwel (Chris Sims) and bee_gate (RISE toolbox). You need to add 
% these optimimzer separately, as they are not part of NB toolbox.
%
% Input:
% 
% - type       : Either 'arima', 'ml' or '' (all). When set to 'arima' or
%                'ml' optimzers that needs fixed bound, as nb_abc,
%                are not returned.
% 
% Output:
% 
% - optimizers : A cellstr with the supported optimizers. 
%
% See also:
% nb_getDefaultOptimset, nb_abc, nb_pso, fmincon, fminunc, fminsearch
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 1
        type = '';
    end

    if any(strcmpi(type,{'arima','ml'}))
        optimizers = {'nb_pso'};
    else
        optimizers = {'nb_abc','nb_pso'};
    end
    if license('test','optimization_toolbox')
        optimizers = [optimizers,{'fmincon','fminunc','fminsearch'}];
    end
    
    if exist('csminwel.m','file')
        optimizers = [optimizers,'csminwel'];
    end
    if ~any(strcmpi(type,{'arima','ml'}))
        if exist('bee_gate.m','file')
            optimizers = [optimizers,'bee_gate'];
        end
    end

end
