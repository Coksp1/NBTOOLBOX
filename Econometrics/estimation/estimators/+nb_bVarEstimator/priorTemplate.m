function template = priorTemplate(type)
% Syntax:
%
% template = nb_bVarEstimator.priorTemplate(type)
%
% Description:
%
% Get prior template for a given BVAR prior type. Assign it to the prior
% field of the main estimation template.
% 
% Input:
% 
% - type : A string with the prior type. See nb_var.priorTemplate or 
%          nb_mfvar.priorTemplate for more on the output.
% 
% Output:
% 
% - template : A struct with the options of the different priors
%
% Examples:
% 
% template = nb_bVarEstimator.priorTemplate('jeffrey')
% 
% See also:
% nb_var.priorTemplate, nb_mfvar.priorTemplate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 1
        type = 'jeffrey';
    end

    if strcmpi(type(end-1:end),'mf')
        template = nb_mfvar.priorTemplate(type,1);
    else
        template = nb_var.priorTemplate(type,1);
    end
    
end
