function Y = nb_addLeads(X,nLeads,dimExpand,dim)
% Syntax:
%
% Y = nb_addLeads(X,nLeads,dimExpand,dim)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin<4
        dim = 1;
        if nargin<3
            dimExpand = 2;
        end
    end
    
    if dim == dimExpand
        error([mfilename ':: The ''dim'' and ''dimExpand'' cannot be equal.'])
    end
    
    if size(X,dimExpand) > 1
        error([mfilename ':: Size in the ''dim'' dimension cannot be greater than 1.'])
    end
    
    dims         = [dimExpand,dim];
    allDims      = [1,2,3,4];
    ind          = ismember(allDims,dims);
    order        = [dims,allDims(~ind)];
    X            = permute(X,order);
    [~,s2,s3,s4] = size(X);
    Y            = nan(1+nLeads,s2,s3,s4);
    for ii = 0:nLeads
       Y(ii+1,:,:,:) = [X(:,1+ii:end,:,:), zeros(1,ii,s3,s4)];
    end
    [~,loc] = ismember(allDims,order);        
    Y       = permute(Y,loc);
    
end
