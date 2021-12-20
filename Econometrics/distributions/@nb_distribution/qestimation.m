function dist = qestimation(type,quantiles,values,varargin)
% Syntax:
%
% dist = nb_distribution.qestimation(type,quantiles,values)
%
% Description:
%
% Estimate a distribution given known quantiles.
% 
% Caution : Only for the distribution family with two parameters, except
%           for 'ast'.
%
% Caution : This function minimizes the absolute deviation between the
%           quantiles provided and the quantiles of the (parameterized)
%           distribution.
%
% Input:
% 
% - type      : The type of distribution to estimate.
%
%               See the nb_distribution class for the supported 
%               distributions.
%
% - quantiles : The 1xN quantiles. Should be between 0 and 1. N must be
%               greater than or equal to the number of parameters (K) of 
%               the distribution to estimate. If the distribution does not
%               match perfectly a sum(abs(qDist-quantiles)) measure will
%               be minimized. Here qDist is the quantiles produced by the
%               provided distribution.
%
% - values    : The 1xN known values at the quantiles.
%
% Optional input:
%
% - 'optimizer' : 'lsqnonlin', 'fminsearch' or 'fmincon'.
%
% - 'optimset'  : A struct. See optimset function. If not given the default
%                 settings are used.
%
% Output:
% 
% - dist      : The found distribution as an nb_distribution object.
%
% Examples:
%
% dist1 = nb_distribution.qestimation('normal',[0.5,0.7],[0,0.5])
% dist2 = nb_distribution.qestimation('normal',[0.5,0.7,0.9],[0,0.5,0.8])
% dist3 = nb_distribution.qestimation('ast',[0.1,0.3,0.5,0.7],...
%                           [0,0.5,0.7,0.9])
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    default = {'optimizer', 'fmincon', @nb_isOneLineChar;...
               'optimset',  [],        @isstruct};
    [inputs,message] = nb_parseInputs(mfilename,default,varargin{:});
    if ~isempty(message)
        error(message)
    end
    
    if isempty(inputs.optimset)
        opt = getOpt();
    else
        opt = inputs.optimset;
    end

    if diff(quantiles) < 0
        error([mfilename ':: The quantiles must be given in increasing order.'])
    end
    if any(quantiles >= 1) || any(quantiles <= 0)
        error([mfilename ':: The quantiles must be in (0,1).'])
    end
    if diff(values) < 0
        error([mfilename ':: The values must be given in increasing order.'])
    end

    quantiles = quantiles(:);
    values    = values(:);
    if size(values,1) ~= size(quantiles,1)
        error([mfilename ':: The values and quantiles inputs must match in size.'])
    end
    

    % Starting values
    if strcmpi(inputs.optimizer,'lsqnonlin')
        func       = str2func(['nb_distribution.' type '_icdf']);
        finderFunc = @(x)finder2(x,func,quantiles,values);
    else
        func       = str2func(['nb_distribution.' type '_cdf']);
        finderFunc = @(x)finder(x,func,quantiles,values);
    end
        
    if strcmpi(type,'ast')
        param    = [0,1,0,1000,1000];
        lb       = [-inf,0,0,0,0];
        ub       = [inf,inf,1,inf,inf];
    elseif strcmpi(type,'skt')
        
        % Get intial value of location
        indMedian = quantiles == 0.5;
        if any(indMedian)
            location = values(indMedian);
        else
            location = mean(values);
        end
        
        % Get intial value of scale
        [~,ind25] = min(abs(quantiles - 0.25));
        [~,ind75] = min(abs(quantiles - 0.75));
        scale     = (values(ind75) - values(ind25))/(norminv(0.75) - norminv(0.25));
        shape     = 0;
        
        % Collect
        param      = [location,scale,shape,10];
        lb         = [-inf,0,-inf,0];
        ub         = [inf,inf,inf,inf];
        
%         param = [location,scale,shape];
%         lb    = [-inf,0,-inf];
%         ub    = [inf,inf,inf];
%         
%         ssqMin = inf;
        
%         func   = str2func(['nb_distribution.' type '_cdf']);
%         for df = 1:30
%             [parThis, ssq] = lsqnonlin(@(x) quantiles' - func(values', x(1), x(2), x(3), df), param, lb, ub, opt);
%             if ssq < ssqMin
%                x   = parThis; 
%                dof = df;
%             end
%         end
        
%         func   = str2func(['nb_distribution.' type '_icdf']);
%         for df = 1:30
%             [parThis, ssq] = lsqnonlin(@(x) values' - func(quantiles', x(1), x(2), x(3), df), param, lb, ub, opt);
%             if ssq < ssqMin
%                x   = parThis; 
%                dof = df;
%             end
%         end
%         dist = nb_distribution('type',type,'parameters',{x(1),x(2),x(3),dof});
%         return
        
    else
        param    = [2,2];
        try
            func(param(1),param(2),2);
        catch %#ok<CTCH>
            error([mfilename ':: The selected distribution ' type ' is not valid for this algorithm.'])
        end
        
        if strcmpi(type,'normal')
            lb = [-inf,0];
            ub = [inf,inf];
        else
            lb = [];
            ub = [];
        end
        
    end
    
    numParam = size(param,2);
    if size(quantiles,1) < numParam
        error([mfilename ':: You must at least provide as many quantiles as there are parameters of the ',...
                         'selected distribution (' int2str(numParam) ').'])
    end
    
    % Do estimation
    switch lower(inputs.optimizer)
        case 'fmincon'
            [x,~,e] = fmincon(finderFunc,param,[],[],[],[],lb,ub,[],opt);
        case 'fminsearch'
            [x,~,e] = fminsearch(finderFunc,param,opt);
        case 'lsqnonlin'
            [x,~,~,e] = lsqnonlin(finderFunc, param, lb, ub, opt);
            
    end
    nb_interpretExitFlag(e,inputs.optimizer);
    
    x(x < eps^(0.8)) = 0;
    if strcmpi(type,'ast')
        dist = nb_distribution('type',type,'parameters',{x(1),x(2),x(3),x(4),x(5)});
    elseif strcmpi(type,'skt')
        dist = nb_distribution('type',type,'parameters',{x(1),x(2),x(3),x(4)});
    else
        dist = nb_distribution('type',type,'parameters',{x(1),x(2)});
    end

end

function f = finder(x,func,q,v)

    try
        n  = size(v,1);
        qe = nan(n,1);
        if size(x,2) == 2
            for ii = 1:size(v,1)
                qe(ii) = func(v(ii),x(1),x(2));
            end   
        elseif size(x,2) == 4
            for ii = 1:size(v,1)
                qe(ii) = func(v(ii),x(1),x(2),x(3),x(4));
            end
        else
            for ii = 1:size(v,1)
                qe(ii) = func(v(ii),x(1),x(2),x(3),x(4),x(5));
            end
        end
        f = sum(abs(qe-q));
    catch
        f = 1e3;
    end
    
end

function f = finder2(x,func,q,v)

    try
        n  = size(v,1);
        if size(x,2) == 2
            f =  v' - func(q', x(1), x(2)); 
        elseif size(x,2) == 4
            f =  v' - func(q', x(1), x(2), x(3), x(4));
        else
            f =  v' - func(q', x(1), x(2), x(3), x(4), x(5));
        end
    catch
        f = 1e3;
    end
    
end

function opt = getOpt()

    tol = eps;
    opt = optimset('Display','off','MaxFunEvals',10000,...
                   'MaxIter',10000,'TolFun',tol,'TolX',tol);

end
