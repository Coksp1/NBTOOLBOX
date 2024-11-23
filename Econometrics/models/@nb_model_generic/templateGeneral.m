function options = templateGeneral(num,type)
% Syntax:
%
% options = nb_model_generic.templateGeneral(num,type)
%
% Description:
%
% Properties shared by many models.
%
% This structure provided the user the possibility to set different
% estimation options.
% 
% Input:
%
% - num : Number of models to create.
%
% Output:
% 
% - options : A struct.
%
% See also:
% nb_model_generic
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 1
        num = 1;  
    end

    if num == 1
        options = struct();
    else
        options = nb_struct(num,{'data'}); % Make it possible to initalize many objects
    end
    
    options.cores                   = [];
    options.data                    = nb_ts;
    options.page                    = [];
    options.parallel                = false;
    options.requiredDegreeOfFreedom = 3;
    options.waitbar                 = 1;
    
    switch lower(type)
        case 'time-series'
            options.estim_end_date              = '';
            options.estim_start_date            = '';
            options.real_time_estim             = false;
            options.recursive_estim             = 0;
            options.recursive_estim_start_date  = '';
            options.rollingWindow               = [];
        case 'group'
        case 'both'
            options.estim_end_date              = '';
            options.estim_start_date            = '';
            options.estim_types                 = {};
            options.real_time_estim             = false;
            options.recursive_estim             = 0;
            options.recursive_estim_start_date  = '';
            options.rollingWindow               = [];
        otherwise
            options.estim_types                 = {};
            
    end
    
end
