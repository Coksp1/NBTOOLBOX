function options = template(type)
% Syntax:
%
% options = nb_estimator.template(type)
%
% Description:
%
% Options shared by many.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    options.cores                   = [];
    options.data                    = [];
    options.dataVariables           = {};
    options.page                    = [];
    options.parallel                = false;
    options.requiredDegreeOfFreedom = 3;
    options.waitbar                 = 1;
    
    switch lower(type)
        case 'time-series'
            options.dataStartDate              = '';
            options.estim_end_ind              = [];
            options.estim_start_ind            = [];
            options.real_time_estim            = false;
            options.recursive_estim            = 0;
            options.recursive_estim_start_ind  = [];
            options.rollingWindow              = [];
        case 'both'
            options.dataStartDate              = '';
            options.dataTypes                  = {};
            options.estim_end_ind              = '';
            options.estim_start_ind            = '';
            options.estim_types                = {};
            options.real_time_estim            = false;
            options.recursive_estim            = 0;
            options.recursive_estim_start_ind  = '';
            options.rollingWindow              = [];
        otherwise
            options.dataTypes                  = {};
            options.estim_types                = {};
            
    end
    
end
