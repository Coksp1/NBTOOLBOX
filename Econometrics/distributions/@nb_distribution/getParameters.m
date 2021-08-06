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
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

   if numel(obj) > 1
       error([mfilename ':: This method only support scalar nb_distribution object.'])
   end
   value = horzcat(obj.parameters{:});
   
end
