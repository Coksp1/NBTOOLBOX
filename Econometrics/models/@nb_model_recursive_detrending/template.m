function options = template(num)
% Syntax:
%
% options = nb_model_recursive_detrending.template()
% options = nb_model_recursive_detrending.template(num)
%
% Description:
%
% Construct a struct which can be provided to the 
% nb_model_recursive_detrending class constructor.
%
% This structure provided the user the possibility to set different
% options.
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
% nb_model_recursive_detrending
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 1
        num = 1;  
    end

    if num == 1
        options = struct();
    else
        options = nb_struct(num,{'recursive_estim_start_date'}); % Make it possible to initalize many objects
    end  
    options.recursive_end_date   = '';
    options.recursive_start_date = '';
    
end
