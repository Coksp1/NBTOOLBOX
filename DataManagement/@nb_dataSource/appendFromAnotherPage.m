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
% - obj  : A nObs1 x nVar x nPages nb_dataSource object.
%
% - page : The page to append data from.
% 
% Output:
% 
% - obj  : A nObs x nVar x nPages nb_dataSource object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        page = 1;
    end

    if ~nb_isScalarInteger(page,0)
        error('The page must be a scalar positiv integer.')
    end
    if page > obj.numberOfDatasets
        error(['The page input must be less then the number of pages ',...
               'of the object ' int2str(obj.dim)])
    end

    ind = isnan(obj.data);
    for ii = 1:obj.numberOfDatasets
        if ii == page
            continue
        end
        for jj = 1:obj.numberOfVariables
            obj.data(ind(:,jj,ii),jj,ii) = obj.data(ind(:,jj,ii),jj,page);
        end
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@appendFromAnotherPage,{page});
        
    end

end
