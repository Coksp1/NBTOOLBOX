function x = skewness(obj,type)
% Syntax:
%
% x = skewness(obj)
%
% Description:
%
% Evaluate the skewness of the given distribution.
%
% The skewness will be adjusted for bias. See the function skewness made
% by MATLAB inc.
% 
% Input:
% 
% - obj  : An object of class nb_distribution
%
% - type : Type of skewness measure
%          > 'normal'   : E[(X-mean(X))^3]/var(X)^(2/3)
%          > 'pearson1' : (mean(X) - mode(X))/sqrt(var(X))
%          > 'pearson2' : 3*(mean(X) - median(X))/sqrt(var(X))
%          > 'bowley'   : Set u t0 3/4 in the max problem below.  
%          > 'quantile' : max [icdf(u) + icdf(1-u) - 2median(X)/...
%                              icdf(u) + icdf(1-u)]
%          > 'paulsen'  : cdf(mean(X)) - (1-cdf(mean(X)))
%
% Output:
% 
% - x   : numel(obj) == 1 : A double with size as 1 x 1
%         otherwise       : A double with size 1 x nobj
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        type = 'default';
    end

    switch lower(type) 
        case {'normal','default'}
            x = normalSkewness(obj);
        case 'pearson1'
            x = (mean(obj) - mode(obj))./std(obj);
        case 'pearson2'
            x = 3*(mean(obj) - median(obj))./std(obj);
        case 'quantile'
            
            if numel(obj) > 1
                error([mfilename ':: Type set to quantile is only supported for scalar nb_distribution objects'])
            end
            opt     = getOpt();
            [u,~,e] = fminbnd(@quantileSkew,1/2,0.99,opt,obj); 
            interpretExitFlag(e);
            x = quantileMeas(obj,u);
            
        case 'bowley'
            x = quantileMeas(obj,3/4);
        case 'paulsen'
            x = cdf(obj,mean(obj)) - (1 - cdf(obj,mean(obj)));
        otherwise
            error([mfilename ':: None supported skewness type ' type])
    end
    

end

%==========================================================================
function x = normalSkewness(obj)

    nobj1 = size(obj,1); 
    nobj  = size(obj,2);
    lb    = reshape({obj.lowerBound},nobj1,nobj);
    ub    = reshape({obj.upperBound},nobj1,nobj);
    ms    = reshape({obj.meanShift},nobj1,nobj);
    x     = nan(nobj1,nobj);

    for jj = 1:nobj1
        
        for ii = 1:nobj

            if ~isempty(lb{jj,ii}) || ~isempty(ub{jj,ii}) % Truncated distribution

                % Use the same seed when returning the "random" numbers
                seed          = 2.0719e+05;
                defaultStream = RandStream.getGlobalStream;
                savedState    = defaultStream.State;
                s             = RandStream.create('mt19937ar','seed',seed);
                RandStream.setGlobalStream(s);

                % Some distribution may have a close form solution here, and
                % at some point I may want to add those!
                if isempty(ms{jj,ii})
                    x(jj,ii) = nb_distribution.truncated_skewness(obj(jj,ii).type,obj(jj,ii).parameters,lb{jj,ii},ub{jj,ii});
                else
                    x(jj,ii) = nb_distribution.meanshift_skewness(obj(jj,ii).type,obj(jj,ii).parameters,lb{jj,ii},ub{jj,ii},ms{jj,ii});
                end
                
                % Reset the seed
                defaultStream.State = savedState;
                RandStream.setGlobalStream(defaultStream);

            else
                func     = str2func(['nb_distribution.' obj(jj,ii).type '_skewness']);
                x(jj,ii) = func(obj(jj,ii).parameters{:});
            end

        end
        
    end

end

function x = quantileSkew(u,obj)

    x = quantileMeas(obj,u);
    x = -abs(x);

end

function x = quantileMeas(obj,u)

    ICDFU  = icdf(obj,u);
    ICDF1U = icdf(obj,1-u);
    t      = ICDFU + ICDF1U;
    x      = (t - 2*median(obj))./t;

end

function opt = getOpt()

    tol = eps;
    opt = optimset('Display','off','MaxFunEvals',10000,...
                   'MaxIter',10000,'TolFun',tol,'TolX',tol);

end

function interpretExitFlag(e)

    if e == 1
        return
    elseif e == 0
        error('Error during fsolve:: Too many function evaluations or iterations.')
    elseif e == -1
        error('Error during fsolve:: Stopped by output/plot function.')
    else
        error('Error during fsolve')
    end 

end
