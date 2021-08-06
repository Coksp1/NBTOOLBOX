function obj = expm1(obj)
% Syntax:
%
% obj = expm1(obj)
%
% Description:
%
% exp(obj) is the exponential of the elements of obj, e to the obj.
% expm1(obj) computes exp(obj)-1, compensating for the roundoff in
% exp(obj).
% (For small real X, expm1(X) should be approximately X, whereas the
% computed value of EXP(X)-1 can be zero or have high relative error.)
% 
% Input:
% 
% - obj           : An object of class nb_ts, nb_cs or nb_data
% 
% Output:
% 
% - obj           : An object of class nb_ts, nb_cs or nb_data where the  
%                   data are equal to e.^obj.data-1
% 
% Examples:
% 
% obj = expm1(obj);
%
% Written by Andreas Haga Raavand

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = expm1(obj.data);

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@expm1);
        
    end
    
end
