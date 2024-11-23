function [F,LAMBDA,R,varF,expl,c,sigma,e,Z] = pca(obj,r,method,varargin)
% Syntax:
%
% F                                  = pca(obj)
% [F,LAMBDA,R,varF,expl,c,sigma,e,Z] = pca(obj,r,method,varargin)
%
% Description:
%
% Principal Component Analysis of the data of the object.
% 
% Input:
%
% - obj     : An object of class nb_math_ts.
%
% - r       : The number of principal component. If empty this number will
%             be found by the Bai and Ng (2002) test, see the optional
%             option crit below, i.e choose the CT part of the selection 
%             criterion; log(V(ii,F)) + CT. Where;
%
%             V(ii,F) = sum(diag(e_ii'*e_ii/T))/ii
%
%             and e_ii is the residual when ii factors are used
%
% - method  : Either 'svd' or 'eig'. Default is 'svd'.
%
%             > 'svd' : Uses single value deomposition to construct the
%                       principal components. This is the numerically best
%                       way, as the 'eig' method could be very unprecise!
%
%            > 'eig'  : Uses the eigenvalue decomposition approach instead
%
% Optional inputs:
%
% - 'crit'  : You can choose between the follwing selection criterion
%
%            > 1: log(NT/NT1)*ii*NT1/NT;
%
%            > 2: (NT1/NT)*log(min([N;T]))*ii;
%
%         	 > 3: ii*log(GCT)/GCT;
%
%         	 > 4: 2*ii/T;
% 
%            > 5: log(T)*ii/T;
%
%            > 6: 2*ii*NT1/NT;
%
%            > 7: log(NT)*ii*NT1/NT; (default)
%
%            where NT1 = N + T, GCT = min(N,T), NT = N*T and ii = 1:rMax
%
% - 'rMax'  : The maximal number of factors to test for. Must be less than
%             or equal to N. Default is N.
%
% - 'trans' : Give 'demean' if you want to demean the data in the matrix
%             X. Default. Give 'standardize' if you want to standardise the 
%             data in the matrix X. Gice 'none' to drop any kind of
%             transformation of the data in the matrix X.
%
%             Caution: To get back X when 'demean' is given you need to add
%                      the constant terms in c. I.e;
%
%                      X = c(ones(T,1),1) + F*LAMBDA + e, e ~ N(0,R) (1')
%
%                      To get back X when 'standardise' you need to add
%                      the constant term and multiply with sigma. I.e.
%
%                      X = c(ones(T,1),:) + F*LAMBDA.*sigma(ones(T,1),:) + 
%                          eps, eps ~ N(0,R*) (1*)
%
%                      Be aware that the eps differ from e, as e is the
%                      residual from the standardised regression.
% 
% - 'unbalanced' : true or false. Set to true to allow for unbalanced
%                  dataset. Default is false. If false all rows of the
%                  dataset containing nan value are removed from 
%                  calculations.
%
% Output:
% 
% - F       : The principal component, as a nb_math_ts object.
%
% - LAMBDA  : The estimated loadings, as a double
%
% - R       : The covariance matrix of the residual in (1), as a double.
%
% - varF    : As a double. Each column will be the variance of the 
%             corresponding column of F.
%
% - expl    : The percentage of the total variance explained by each
%             principal component. As a 1 x r double
%
% - c       : Constant in the factor equation. double with size 
%             1 x nvar. 
%
% - sigma   : See 'trans'. double with size 1 x nvar.
%
% - e       : Residual of the equation (1) above. As a nb_math_ts object.
%
% - Z       : Normalized (and rebalanced) version of X.
%
% See also:
% nb_pca
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        method = 'svd';
        if nargin < 2
            r = [];
        end
    end

    if obj.dim3 > 1
        
        if isempty(r)
            error([mfilename ': This method is only supported on objects with one page if the number of factors is not set.'])
        end
        if nargout > 1
            error([mfilename 'This method is only supported on objects with one page if the number of outputs are larger then one.'])
        end
        F = nan(obj.dim1,r,obj.dim3);
        for ii = 1:obj.dim3
            F(:,:,ii) = nb_pca(obj.data(:,:,ii),r,method,varargin{:});
        end
        
    else
        [F,LAMBDA,R,varF,expl,c,sigma,e,Z] = nb_pca(obj.data,r,method,varargin{:});
    end
        
    % The principal components
    F = nb_math_ts(F,obj.startDate);

    if nargout > 7   
        % Scaling factor of equation of equation
        e = nb_math_ts(e,obj.startDate);
    end

    if nargout > 8   
        % Scaling factor of equation of equation
        Z = nb_math_ts(Z,obj.startDate);
    end
     
end
