function options = template(num)
% Syntax:
%
% options = nb_model_convert.template()
% options = nb_model_convert.template(num)
%
% Description:
%
% Construct a struct which can be provided to the nb_model_convert
% class constructor.
%
% This structure provided the user the possibility to set different
% convertion options.
% 
% Input:
%
% - num     : Number of models to create.
%
% Output:
% 
% - options : A struct.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 1
        num = 1;  
    end

    if num == 1
        options = struct();
    else
        options = nb_struct(num,{'data'}); % Make it possible to initalize many objects
    end
    options.data            = nb_ts();
    options.freq            = 1;
    options.method          = '';
    options.others          = {};
    options.interpolateDate = 'end';

end
