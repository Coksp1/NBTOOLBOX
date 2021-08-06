function obj = diag(obj,typeName)
% Syntax:
%
% obj = diag(obj)
%
% Description:
%
% Take the diagonal elements of the data and return it as a own type.
% 
% The data must be symmetric matrix! 
%
% Input:
% 
% - obj      : An object of class nb_cs.
%
% - typeName : Name of the created type. Default is 'diag'.
% 
% Output:
% 
% - obj      : An object of class nb_cs with one type.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        typeName = 'diag';
    end
    
    d          = obj.data;
    [s1,s2,s3] = size(d);
    if s1 ~= s2
        error([mfilename ':: The data must be given as a symmetric matrix. Is ' int2str(s1) ' x ' int2str(s2)])
    end
    
    new = nan(1,s2,s3);
    for ii = 1:s3
        new(:,:,ii) = diag(d(:,:,ii));
    end
    obj.data  = new;
    obj.types = {typeName};
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@ctranspose);
        
    end

end
