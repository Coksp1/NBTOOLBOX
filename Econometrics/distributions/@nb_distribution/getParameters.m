function value = getParameters(obj)
% Syntax:
%
% value = getParameters(obj)
%
% Description:
%
% Get the parameter values.
% 
% Output:
% 
% - value : The parameters of the object, as 1 x nParam double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

   if numel(obj) > 1
       error([mfilename ':: This method only support scalar nb_distribution object.'])
   end
   value = horzcat(obj.parameters{:});
   
end
