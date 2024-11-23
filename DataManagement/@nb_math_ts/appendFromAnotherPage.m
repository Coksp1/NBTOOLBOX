function obj = appendFromAnotherPage(obj,page)
% Syntax:
%
% obj = appendFromAnotherPage(obj,page)
%
% Description:
%
% Append data from another page where the rest has missing data.
% 
% Input:
% 
% - obj  : A nObs1 x nVar x nPages nb_math_ts object.
%
% - page : The page to append data from.
% 
% Output:
% 
% - obj  : A nObs x nVar x nPages nb_math_ts object.
%
% Examples:
% 
% obj            = nb_math_ts(zeros(10,2,4),'2018Q1');
% obj(1:4,:,3:4) = nan;
% new1           = appendFromAnotherPage(obj,1);
% new2           = appendFromAnotherPage(obj,2);
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        page = 1;
    end

    if ~nb_isScalarInteger(page,0)
        error('The page must be a scalar positiv integer.')
    end
    if page > obj.dim3
        error(['The page input must be less then the number of pages ',...
               'of the object ' int2str(obj.dim)])
    end

    ind = isnan(obj.data);
    for ii = 1:obj.dim3
        if ii == page
            continue
        end
        for jj = 1:obj.dim2
            obj.data(ind(:,jj,ii),jj,ii) = obj.data(ind(:,jj,ii),jj,page);
        end
    end

end
