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
% - obj       : An object of class nb_math_ts
% 
% Output: 
% 
% - obj       : An object of class nb_math_ts
% 
% Examples:
%
% out = conj(in);
% 
% Written by Andreas Haga Raavand  

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    obj.data = conj(obj.data);

    
end
