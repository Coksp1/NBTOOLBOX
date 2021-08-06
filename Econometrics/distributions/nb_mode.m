function m = nb_mode(x,dim,method,varargin)
% Syntax:
%
% m = nb_mode(x,dim,method,varargin)
%
% Description:
%
% Find the mode of the empirical distribution of the number in x along the
% wanted dimension. 
% 
% Input:
% 
% - x        : A 3D double matrix.
% 
% - dim      : Either 1, 2 or 3. 1 is default.
%
% - method   : A string:
%
%   > 'kernel' : Using kernel density estimation and finds the mode of the
%                estimated distribution. (Default)
%
%                To decrease the std in the mode estimate the 'width'
%                input can be used. The default is 
% 
%                sig = median(abs(x-median(x))) / 0.6745;
%                w   = 2 * sig * (4/(3*N))^(1/5);
%
% - varargin : Extra inputs to the differen mode estimators
%
%   > 'kernel' :
%
%       Optional input given to the nb_ksdensity function. Please 
%       see help for that function.
%
%   > The rest of the methods have no optional inputs.
%
% Output:
% 
% - m : The mode with size matching the inputs x and dim.
%
% Examples:
%
% m = nb_mode(randn(1000,1),1,'kernel')
%
% See also:
% mode
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin<3
        method = 'kernel';
        if nargin<2
            dim = 1;
        end
    end

    if dim == 2
        x = permute(x,[2,1,3]);    
    elseif dim == 3
        x = permute(x,[3,2,1]);
    elseif dim ~= 1
        error([mfilename ':: Cannot calculate the mode in dim ' int2str(dim)])
    end
    
    [~,dim2,dim3] = size(x);
    switch lower(method)
        
        case 'kernel'
            
            m = nan(1,dim2,dim3);
            for ii = 1:dim2
                for jj = 1:dim3
                    m(1,ii,jj) = kernelBased(x(:,ii,jj),varargin);
                end
            end
            
        case 'standardparametric'
            
            m = standardParametric(x);
            
        case 'grenander'
            
            if nargin > 3
                k = varargin{1};
            else
                k = 2;
            end
            if nargin > 4
                p = varargin{2};
            else
                p = 1;
            end
            if p > k
                error([mfilename ': The p input must be smaller than k.'])
            end
            
            x   = sort(x,1);
            n   = size(x,1);
            xi  = x(1:n-k,:,:);
            xik = x(k+1:n,:,:);
            x1  = xik - xi;
            x2  = xik + xi;
            x3  = x1.^p;
            m   = 0.5*sum(x2./x3,1)./sum(1./x3,1);
            
        case 'hsm'
            
            if nargin > 3
                k = varargin{1};
            else
                k = size(x,1)/20;
            end
            
            x = sort(x,1);
            m = nan(1,dim2,dim3);
            for ii = 1:dim2
                for jj = 1:dim3
                    m(1,ii,jj) = hsmEngine(x(:,ii,jj),k);
                end
            end
            
        case 'hrm'
            
            if nargin > 3
                k = varargin{1};
            else
                k = size(x,1)/20;
            end
            
            x = sort(x,1);
            m = nan(1,dim2,dim3);
            for ii = 1:dim2
                for jj = 1:dim3
                    m(1,ii,jj) = hrmEngine(x(:,ii,jj),k);
                end
            end
            
        case 'approx'
            
            m = 1.5*median(x,1) - 0.5*mean(x,1);
                        
        otherwise
            error([mfilename ':: Unknown method ' method])
    end
    
    if dim == 2
        m = permute(m,[2,1,3]);    
    elseif dim == 3
        m = permute(m,[3,2,1]);
    end

end

%==========================================================================
function m = kernelBased(xt,inputs)
   
    if ~any(strcmpi('bandWidth',inputs)) || isempty(inputs)
        sig    = median(abs(xt-median(xt)))/0.6745;
        w      = 2*sig*(4/(3*size(xt,1)))^(1/5);
        inputs = [inputs,'bandWidth',w];
    end
    xi = nb_distribution.estimateDomain(xt);
    f  = nb_ksdensity(xt',xi',inputs{:});

    % Check that the density sums to 1
    binsL   = xi(2) - xi(1);
    testCDF = cumsum(f)*binsL; 
    topCDF  = max(testCDF);
    if topCDF > 1.015 || topCDF < 0.985
        error([mfilename ':: A CDF return by the ksdensity function did not sum to 1, which is not possible by definition of a density. '...
                         'Is (' num2str(topCDF) '). This is probably due to a mispecified domain.']);
    end
    m = nb_distribution.kernel_mode(xi,f);

end

%==========================================================================
function m = standardParametric(x)

    [n,v,p] = size(x);

    % Construct the expected order statistics
    i = 1:n;
    z = nb_distribution.normal_icdf((i - 0.5)/n,0,1)';

    % Make all draws positive
    mi       = min(x,[],1);
    mi(mi>0) = 0;
    xx       = bsxfun(@minus,x,mi);
    
    % Optimize alpha
    opt   = nb_getOpt();
    alpha = ones(1,v,p);
    for ii = 1:v
        for jj = 1:p
            [alpha(1,ii,jj),~,e] = fminsearch(@stPar,alpha(1,ii,jj),opt,z,xx(:,ii,jj)); 
            nb_interpretExitFlag(e,'fminsearch');
        end
    end
    
    % Estimate mean and std of transformed data
    xAlpha = bsxfun(@power,xx,alpha);
    VAR    = var(xAlpha,0,1);
    M      = mean(xAlpha,1);
    
    % Return mode estimate
    TERM = sqrt(M.^2 + (4.*VAR.*(alpha - 1))./alpha);
    m    = (0.5.*(M + TERM)).^alpha;
    m    = m + mi;
    
end

%==========================================================================
function f = stPar(alpha,z,x) 

    f = -corr(z,sort(x.^alpha));

end

%==========================================================================
function m = hsmEngine(x,crit)

    n = size(x,1);
    if n < crit
        m = mean(x,1);
        return
    end
    h  = ceil(n/2);
    d1 = x(h) - x(1);
    d2 = x(end) - x(h+1);
    if d1 < d2
        m = hsmEngine(x(1:h),crit);
    else
        m = hsmEngine(x(h+1:end),crit);
    end
    
end

%==========================================================================
function m = hrmEngine(x,crit)

    n = size(x,1);
    if n < crit
        m = mean(x,1);
        return
    end  
    h    = (x(end) - x(1))/2 + x(1);
    ind  = x < h;
    lowH = sum(ind);
    if lowH > n/2
        m = hrmEngine(x(ind),crit);
    else
        m = hrmEngine(x(~ind),crit);
    end
    
end
