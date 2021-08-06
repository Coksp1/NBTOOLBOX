function assignParameters(obj,param)
% Syntax:
%
% assignParameters(obj,param)
%
% Description:
%
% Assign parameters to a scalar distribution object.
% 
% Input:
% 
% - obj   : A nb_distribution object.
%
% - param : The parameters to assign the object, as 1 x nParam double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

   if numel(obj) > 1
       error([mfilename ':: This method only support scalar nb_distribution object.'])
   end
   if length(param) ~= getNumberOfParameters(obj)
       error([mfilename ':: The assign parameters does not have the correct length.'])
   end
   obj.parameters = num2cell(nb_rowVector(param));
   
end
