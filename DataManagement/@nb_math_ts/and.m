function a = and(a,b)
% Syntax:
%
% a = and(a,b)
%
% Description:
%
% The and operator (&). Act element-wise on the data of the two 
% nb_math_ts objects
% 
% Input:
% 
% - a         : An object of class nb_math_ts
% 
% - b         : An object of class nb_math_ts
% 
% Output:
% 
% - a         : An object of class nb_math_ts. Where the and 
%               operator has evaluated all the data elements of the 
%               object. The data will be a logical matrix 
% 
% Examples:
%
% a = a & b;
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isa(a,'nb_math_ts') && isa(b,'nb_math_ts')

        [a,b] = checkConformity(a,b);

        ind = ~isnan(a.data) & ~isnan(b.data);
        if any(~ind(:))
            for pp = 1:a.dim3
                for vv = 1:a.dim2
                    a.data(ind(:,vv,pp),vv,pp)  = a.data(ind(:,vv,pp),vv,pp) & b.data(ind(:,vv,pp),vv,pp);
                    a.data(~ind(:,vv,pp),vv,pp) = nan;
                end
            end
        else
            a.data = a.data & b.data;
        end
        
    else

        error([mfilename ':: Undefined function ''and'' for input arguments of type ''' class(a) ''' and ''' class(b) '''.'])
    end

end
