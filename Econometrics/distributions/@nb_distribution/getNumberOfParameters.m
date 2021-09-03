function value = getNumberOfParameters(obj)
% Syntax:
%
% value = getNumberOfParameters(obj)
%
% Description:
%
% Get the number of parameters of the distribution.
% 
% Output:
% 
% - value : The number of parameters of the object.
%
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

   if numel(obj) > 1
       error([mfilename ':: This method only support scalar nb_distribution object.'])
   end
   value = size(obj.parameters,2); 
   
end