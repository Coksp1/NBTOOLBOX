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
% - obj     : An object of class nb_ts.
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
% 'output'  : A string with the wanted output. Either 'F', 'LAMBDA',
%             'R', 'varF', 'expl', 'c', 'sigma', 'e'. See below for the
%             matching output. 
%
%             Caution: If provided it will be the only output from this
%                      function. I.e. return as F.
%
% - 'unbalanced' : true or false. Set to true to allow for unbalanced
%                  dataset. Default is false. If false all rows of the
%                  dataset containing nan value are removed from 
%                  calculations.
%
% Output:
% 
% - F       : The principal component, as a nb_ts object.
%
% - LAMBDA  : The estimated loadings, as a nb_cs object
%
% - R       : The covariance matrix of the residual in (1), as a nb_cs 
%             object.
%
% - varF    : As a nb_cs object. Each column will be the variance of the 
%             corresponding column of F.
%
% - expl    : The percentage of the total variance explained by each
%             principal component. As a 1 x r nb_cs object
%
% - c       : Constant in the factor equation. nb_cs object with size 
%             1 x nvar. 
%
% - sigma   : See 'trans'. nb_cs object with size 1 x nvar.
%
% - e       : Residual of the equation (1) above. As a nb_ts object.
%
% - Z       : Normalized (and rebalanced) version of X.
%
% Example:
% load hald;
% ingredients = nb_ts(ingredients,'',1,{'tricalcium_aluminate',...
%                                       'tricalcium_silicate',...
%                                       'tetracalcium_aluminoferrite',...
%                                       'beta_dicalcium_silicate'});
% [F,LAMBDA,R,varF,expl] = pca(ingredients)
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

    if obj.numberOfDatasets > 1
        error([mfilename ': This method is only supported on objects with one page.'])
    end

    ind = strcmpi('output',varargin);
    out = '';
    if any(ind)
        loc        = find(ind);
        out        = varargin{loc(end)+1};
        ind(loc+1) = true;
        varargin   = varargin(~ind);
    end
        
    [F,LAMBDA,R,varF,expl,c,sigma,e,Z] = nb_pca(obj.data,r,method,varargin{:});
       
    s      = size(F,2);
    varsPC = cell(1,s);
    for ii = 1:s
        varsPC{ii} = ['Factor' int2str(ii)];
    end
    vars   = obj.variables;
    
    if isempty(out)
    
        % The principal components
        F = nb_ts(F,'',obj.startDate,varsPC,false);
        if obj.isUpdateable()
            F.links      = obj.links;
            F.updateable = 1;
            F = F.addOperation(@pca,[{r,method},varargin,{'output','F'}]);
        end
            
        if nargout > 1
            % The principal components coefficients
            LAMBDA = nb_cs(LAMBDA,'',varsPC,vars,obj.sorted);
            if obj.isUpdateable()
                LAMBDA.links      = obj.links;
                LAMBDA.updateable = 1;
                LAMBDA = LAMBDA.addOperation(@pca,[{r,method},varargin,{'output','LAMBDA'}]);
            end
        end
        
        if nargout > 2
            % Covariance matrix of residuals (sum of the rest of the 
            % factors not reported)
            R = nb_cs(R,'',vars,vars,obj.sorted);
            if obj.isUpdateable()
                R.links      = obj.links;
                R.updateable = 1;
                R = R.addOperation(@pca,[{r,method},varargin,{'output','R'}]);
            end
        end
        
        if nargout > 3    
            % Variance of each factor 
            varF = nb_cs(varF,'',{'Variance'},varsPC,false);
            if obj.isUpdateable()
                varF.links      = obj.links;
                varF.updateable = 1;
                varF = varF.addOperation(@pca,[{r,method},varargin,{'output','varF'}]);
            end
        end
        
        if nargout > 4    
            % Variance of each factor 
            expl = nb_cs(expl,'',{'Explained'},varsPC,false);
            if obj.isUpdateable()
                expl.links      = obj.links;
                expl.updateable = 1;
                expl = expl.addOperation(@pca,[{r,method},varargin,{'output','expl'}]);
            end
        end
        
        if nargout > 5   
            % Constant term of equation
            c = nb_cs(c,'',{'Constant'},vars,obj.sorted); 
            if obj.isUpdateable()
                c.links      = obj.links;
                c.updateable = 1;
                c = c.addOperation(@pca,[{r,method},varargin,{'output','c'}]);
            end
        end
        
        if nargout > 6  
            % Scaling factor of equation of equation
            sigma = nb_cs(sigma,'',{'ScalingFactor'},vars,obj.sorted); 
            if obj.isUpdateable()
                sigma.links      = obj.links;
                sigma.updateable = 1;
                sigma = sigma.addOperation(@pca,[{r,method},varargin,{'output','sigma'}]);
            end
        end
        
        if nargout > 7   
            % Scaling factor of equation of equation
            e = nb_ts(e,'',obj.startDate,vars,obj.sorted);
            if obj.isUpdateable()
                e.links      = obj.links;
                e.updateable = 1;
                e = e.addOperation(@pca,[{r,method},varargin,{'output','e'}]);
            end
        end
        
        if nargout > 8   
            % Scaling factor of equation of equation
            Z = nb_ts(Z,'',obj.startDate,vars,obj.sorted);
            if obj.isUpdateable()
                Z.links      = obj.links;
                Z.updateable = 1;
                Z            = Z.addOperation(@pca,[{r,method},varargin,{'output','Z'}]);
            end
        end
        
    else
        
        switch lower(out)
            
            case 'f'
                % The principal components
                F = nb_ts(F,'',obj.startDate,varsPC,false);
            case 'lambda'
                % The principal components coefficients
                F = nb_cs(LAMBDA,'',varsPC,vars,obj.sorted);
            case 'r'
                % Covariance matrix of residuals (sum of the rest of the 
                % factors not reported)
                F = nb_cs(R,'',vars,vars,obj.sorted);
            case 'varf'
                % Variance of each factor 
                F = nb_cs(varF,'',{'Variance'},varsPC,false);
            case 'expl'
                % Variance of each factor 
                F = nb_cs(expl,'',{'Explained'},varsPC,false);
            case 'c'
                % Constant term of equation
                F = nb_cs(c,'',{'Constant'},vars,obj.sorted);
            case 'sigma'
                % Scaling factor of equation of equation
                F = nb_cs(sigma,'',{'ScalingFactor'},vars,obj.sorted);  
            case 'e'
                % Scaling factor of equation of equation
                F = nb_ts(e,'',obj.startDate,vars,obj.sorted);
            case 'z'
                % Scaling factor of equation of equation
                F = nb_ts(Z,'',obj.startDate,vars,obj.sorted);    
            otherwise
                error([mfilename ':: Unsupported output ' out '.'])
        end
        
        if obj.isUpdateable()
            F.links      = obj.links;
            F.updateable = 1;
            F = F.addOperation(@pca,[{r,method},varargin,{'output',out}]);
        end
        
    end
     
end
