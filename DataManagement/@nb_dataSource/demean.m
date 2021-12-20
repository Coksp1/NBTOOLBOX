function obj = demean(obj,dim)
% Syntax:
%
% obj = demean(data,dim)
%
% Description:
%
% - Demeans data along the dimension you choose.
%
% Input:
% 
% - obj  : A nb_dataSource object.
%
% - dim  : A double corresponding to the dimension you want to take the
%          average over. Default is 1.
%
% Output:
% 
% - obj  : A nb_dataSource object.
%
% Written by Tobias Ingebrigtsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        dim = [];
    end
    obj.data = nb_demean(obj.data,dim);
    
    if obj.isUpdateable()
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@demean,{dim});
   end
    
end
