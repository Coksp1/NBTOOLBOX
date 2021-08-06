function obj = subAvg(obj,k)
% Syntax:
%
% obj = subAvg(obj,k)
%
% Description:
%
% - Will for the last k periods (including the present) calculate the
%   cumulative sum and then divide by the amount of periods, which gives
%   you the average over those periods.
%
% Input: 
%
% - obj     : An object of class nb_ts.
%
% - k       : Lets you choose what frequency you want to calulate the
%             average over. As a double. E.g. 4 if you have quarterly data
%             and want to calculate the average over the last 4 quarters.
% 
% Output:
% 
% - obj     : An nb_ts object where the data are the average over 
%             the last k periods.
%
% Examples:
%
% dataquarter = nb_ts('histdata.db', '', '2000Q1', {'QSA_PCPIJAE'});
% growth12Q   = pcn(dataquarter,4);
% growth12Q   = subAvg(growth12Q,4);
%
% See also: 
% growth, q2y, pcn.
%
% Written by Tobias Ingebrigtsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

   obj.data = nb_subAvg(obj.data,k);
   
   if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@subAvg,{k});
        
   end

end
