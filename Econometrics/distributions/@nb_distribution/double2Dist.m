function obj = double2Dist(d)
% Syntax:
%
% obj = nb_distribution.double2Dist(d)
%
% Description:
%
% Convert a double to a nb_distribution object representing a non-random
% variable, i.e. a constant.
% 
% Input:
% 
% - d : A double matrix. dim < 3 
% 
% Output:
% 
% - obj : An object of class nb_distribution matching the size of d.
%
% Examples:
%
% obj = nb_distribution.double2Dist(rand(2,2)) 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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

    [dim1,dim2,dim3] = size(d);
    if dim3 > 1
        error([mfilename ':: The double cannot have dim > 2.'])
    end
    d     = d(:);
    type  = {'constant'};
    type  = type(1,ones(1,dim1*dim2));
    param = cell(1,dim1*dim2);
    for ii = 1:dim1*dim2
       param{ii} = {d(ii)}; 
    end
    
    obj = nb_distribution.initialize('type',        type,...
                                     'parameters',  param);                          
    obj = reshape(obj,dim1,dim2);

end
