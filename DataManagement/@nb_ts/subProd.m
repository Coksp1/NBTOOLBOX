function obj = subProd(obj,k,w)
% Syntax:
%
% obj = subProd(obj,k)
% obj = subProd(obj,k,w)
%
% Description:
%
% Calculates the cumulative prod over the last k periods (including the
% present period).
% 
% Input:
% 
% - obj : An object of class nb_ts.
%
% - k   : Lets you choose what frequency you want to calulate the
%         cumulative product over. As a double. E.g. 4 if you have
%         quarterly data and want to calculate the product over the
%         last 4 quarters.
% 
% - w   : Weights applies to the k periods to multiply over. Default is 
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
% growth12Q   = subProd(growth12Q,4);
%
% See also:
% pcn, growth, nb_ts.subAvg, nb_ts.subSum
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        w = [];
    end

    obj.data = nb_subProd(obj.data,k,w);
    
    if obj.isUpdateable()
       % Add operation to the link property, so when the object 
       % is updated the operation will be done on the updated 
       % object
       obj = obj.addOperation(@subProd,{k,w});
        
   end
    
end
