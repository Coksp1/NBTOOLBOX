function obj = double2NormalDist(d,sigma)
% Syntax:
%
% obj = nb_distribution.double2NormalDist(d,sigma)
%
% Description:
%
% Convert a double to a nb_distribution object representing a random
% univariate normal variable.
% 
% Input:
% 
% - d     : A double matrix representing the mean. dim < 3 
% 
% - sigma : A double matrix with same size as d representing the std.
%
% Output:
% 
% - obj   : An object of class nb_distribution matching the size of d.
%
% Examples:
%
% obj = nb_distribution.double2Dist(rand(2,2)) 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isempty(d)
        [dim1,dim2] = size(d);
        if dim1
            obj(dim1,1) = nb_distribution;
            obj         = obj(:,false); 
        elseif dim2
            obj(1,dim2) = nb_distribution;
            obj         = obj(false,:); 
        else   
            obj = nb_distribution.empty();
        end
        return
    end

    [dim1,dim2,dim3]    = size(d);
    [dims1,dims2,dims3] = size(d);
    if dim3 > 1 
        error([mfilename ':: The input d cannot have dim > 2.'])
    end
    if dims3 > 1 
        error([mfilename ':: The input sigma cannot have dim > 2.'])
    end
    if dim1 ~= dims1 || dim2 ~= dims2
        error([mfilename ':: The inputs must have same size.'])
    end
    d     = d(:);
    sigma = sigma(:);
    type  = {'normal'};
    type  = type(1,ones(1,dim1*dim2));
    param = cell(1,dim1*dim2);
    for ii = 1:dim1*dim2
       param{ii} = {d(ii),sigma(ii)}; 
    end
    
    obj = nb_distribution.initialize('type',        type,...
                                     'parameters',  param);                          
    obj = reshape(obj,dim1,dim2);

end
