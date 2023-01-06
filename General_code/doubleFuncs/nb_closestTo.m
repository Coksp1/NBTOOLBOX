function m = nb_closestTo(X,x,dim,method)
% Syntax:
%
% m = nb_closestTo(X,x,dim,method)
%
% Description:
%
% Find the closes path in the multidimension matrix X to the
% the multidimension matrix x. x must have only dimension 1 in the
% dimension dim!
% 
% Input:
% 
% - X      : A matrix with dimension less than 4.
%
% - x      : A matrix only dimension 1 in the dimension dim. Otherwise have 
%            the same dimensions as X.
%
% - dim    : The dimension to pick the closest to. An intger between 1 and 
%            4.
%
% - method : Either 'abs' (absolute deviation) or 'square' (square 
%            deviation)
% 
% Output:
% 
% m        : The "element" that was closest to x.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if size(x,dim) ~= 1
        error([mfilename ':: x must have size 1 in the dimension dim'])
    end
    
    [s1,s2,s3,s4] = size(X);
    dimIndex      = [s1,s2,s3,s4];
    dimX          = find(dimIndex>1,1,'last');
    if size(X,dim) > 1
        
        % Replicate the x matrix to have same size as X
        repInd      = ones(1,dimX);
        repInd(dim) = dimIndex(dim);
        x           = repmat(x,repInd);
        
        % Then we get the diff
        D = X - x;
        switch lower(method)
            
            case 'abs'
                D = abs(D);
            case 'square'
                D = D.^2;
            otherwise
                error([mfilename ':: Undefined method ' method])
        end            
        
        % Find the sum of error across all dimension except dim
        for ii = 1:dimX
            
            if ii ~=dim
                D = sum(D,ii);
            end
            
        end
        
        % Then we pick the closes to the x
        [~,picked] = min(D,[],dim);
        
        % Then we return that matrix
        switch dim
            case 1
                m = X(picked,:,:,:);
            case 2
                m = X(:,picked,:,:);
            case 3
                m = X(:,:,picked,:);
            case 4
                m = X(:,:,:,picked);
            otherwise
                error([mfilename ':: dim cannot be grater than 4'])
        end
        
    else
        m = X;      
    end

end
