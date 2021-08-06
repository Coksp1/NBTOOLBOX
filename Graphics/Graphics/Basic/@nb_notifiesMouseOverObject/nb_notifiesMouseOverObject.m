classdef nb_notifiesMouseOverObject < handle
% Description:
%     
% An abstract class that indicates that the subclass has a 
% notifyMouseOverObject method.
%
% See also:
% nb_notifiesMouseOverObject
%     
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

   properties (Access=protected)
       
       
   end

   methods(Abstract=true,Hidden=true)
       
       [x,y,value] = notifyMouseOverObject(obj,cPoint)
       
   end
    
    
end
