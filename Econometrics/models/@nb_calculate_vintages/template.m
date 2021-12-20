function options = template(num)
% Syntax:
%
% options = nb_calculate_vintages.template()
% options = nb_calculate_vintages.template(num)
%
% Description:
%
% Construct a struct which can be provided to the nb_calculate_vintages
% class constructor.
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
% nb_calculate_vintages
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 1
        num = 1;  
    end
    if num == 1
        options = struct();
    else
        options = nb_struct(num,{'dataSource'}); % Make it possible to initalize many objects
    end
    
    options.dataSource          = [];
    options.folder              = '';
    options.model               = [];
    options.nSteps              = 1;
    options.path                = '';
    options.store2              = [];
    options.varOfInterest       = '';
    options.updateAtEachContext = false;
    
end
