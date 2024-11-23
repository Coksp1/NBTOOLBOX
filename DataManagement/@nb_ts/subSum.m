function obj = subSum(obj,k,w)
% Syntax:
%
% obj = subSum(obj,k)
% obj = subSum(obj,k,w)
%
% Description:
%
% Calculates the cumulative sum over the last k periods (including the
% present period).
% 
% Input:
% 
% - obj : An object of class nb_ts.
%
% - k   : Lets you choose what frequency you want to calulate the
%         cumulative sum over. As a double. E.g. 4 if you have
%         quarterly data and want to calculate the sum over the
%         last 4 quarters.
% 
% - w   : Weights applies to the k periods to sum over. Default is 
%         equal weights! As a double vector with length k.
%
% Output:
% 
% - obj    : An object of class nb_ts.
%
%
% Examples:
%
% dataquarter = nb_ts('histdata.db', '', '2000Q1', {'QSA_PCPIJAE'});
% growth12Q   = pcn(dataquarter,4);
% growth12Q   = subSum(growth12Q,4);
%
% See also:
% pcn, growth, nb_ts.subAvg, nb_ts.subProd
%
% Written by Tobias Ingebrigtsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        w = [];
    end

    obj.data = nb_subSum(obj.data,k,w);
    
    if obj.isUpdateable()
       % Add operation to the link property, so when the object 
       % is updated the operation will be done on the updated 
       % object
       obj = obj.addOperation(@subSum,{k,w});
        
   end
    
end
