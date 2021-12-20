function obj = checkModel(obj)
% Syntax:
%
% obj = checkModel(obj)
%
% Description:
%
% Secure that the object is up to date when it comes to the options.
% 
% Input:
% 
% - obj : An object of class nb_calculate_vintages.
% 
% Output:
% 
% - obj : An object of class nb_calculate_vintages.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    t           = nb_calculate_vintages.template();
    obj.options = orderfields(nb_structcat(obj.options,t,'first'));
    
end
