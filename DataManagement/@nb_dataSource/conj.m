function obj = conj(obj)
% Syntax:
%
% obj = conj(obj)
%
% Description:
%
% conj(obj) is the complex conjugate of the elements of obj.
% For a complex element x of obj, conj(x) = REAL(x) - i*IMAG(x).
% 
% Input:
% 
% - obj       : An object of class nb_ts, nb_cs or nb_data
% 
% Output: 
% 
% - obj       : An object of class nb_ts, nb_cs or nb_data
% 
% Examples:
%
% out = conj(in);
% 
% Written by Andreas Haga Raavand

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = conj(obj.data);

    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@conj);
        
    end
    
end
