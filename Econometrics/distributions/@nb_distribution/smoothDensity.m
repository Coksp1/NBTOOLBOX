function smoothDensity(obj,smoothing,varargin)
% Syntax:
%
% smoothDensity(obj,smoothing,varargin)
%
% Description:
%
% Smooth out a distribution of type kernel.
%
% This method should be used with care, as the many of the properties of
% the original distribution may be changed.
% 
% Input:
% 
% - obj       : A scalar nb_distribution object
%
% - smoothing : > A 1x2 cell : First element is the number of elements to  
%                              smooth out in the neighbourhood of the 
%                              selected point, while the second input is 
%                              the index of selected point.
%
%               > 'kernel'   : Using a kernel smoother on the random
%                              draws to smooth out distribution.
% 
% Optional input:
%
% - varargin  : Optional input given to the nb_ksdensity function. Please 
%               see help for that function.
%
% Examples:
%
% est = nb_distribution.perc2DistCDF([10,30,50,70,90],[1,4,6,7,8],-1,14);
% s   = copy(est);
% smoothDensity(s,'kernel');
% plot([est,s])
%
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This function only handles a scalar nb_distribution object.'])
    end

    if ~strcmpi(obj.type,'kernel')
        error([mfilename ':: To use this method the distribution must be of type ''kernel''. Please see the convert method.'])
    end
    
    % Check that the optional input 'function' is not used
    ind = strcmpi('function',varargin);
    if any(ind)
        error([mfilename ':: The '''' function '''' input is not supported as a optional input to the ksdensity function'])
    end

    % Use a kernel density estimator to smooth out the pdf
    if strcmpi(smoothing,'kernel')
        draws  = random(obj,1,1000);
        [f,xi] = nb_ksdensity(draws,'numDomain',1000,varargin{:});
    elseif iscell(smoothing) && nb_sizeEqual(smoothing,[1,2])
        [xi,f] = smoothNeighbourhood(obj.parameters{1},obj.parameters{2},smoothing{2},smoothing{1});
    else
        error([mfilename ':: the smoothing input has been given a wrong value'])
    end
    
    % Assign distribution object
    obj.parameters = {xi(:),f(:)};
    if size(xi,1) > 1000
        % Keep number of domain point 1000
        temp           = asData(obj,[],'pdf');
        obj.parameters = {getVariable(temp,'domain'),getVariable(temp,obj.name)};
    end
    
end

%==========================================================================
function [x,f] = smoothNeighbourhood(x,f,index,neighbourhood)

    s = size(f,1);
    if index > s || index < 1
        error([mfilename ':: index input is outside bounds.'])
    end

    % Secure that the neighbourhood is included in the domain
    binsL = x(2) - x(1);
    if index + neighbourhood > s
        added = index + neighbourhood - s;
        f     = [f;zeros(added,1)];
        x     = [x; x(end) + cumsum(binsL*ones(added,1))];
    end
    
    if index - neighbourhood < 1
        added = abs(index - neighbourhood) + 1;
        f     = [zeros(added,1);f];
        x     = [x(1) - flipud(cumsum(binsL*ones(added,1))); x];
        index = index + added;
    end
    
    % Then we smooth out the neighbourhood
    nhood = index - neighbourhood:index + neighbourhood;
    X     = [x(index - neighbourhood); x(index) ; x(index + neighbourhood)];
    F     = [f(index - neighbourhood); f(index) ; f(index + neighbourhood)];
    Xq    = x(nhood);
    Fq    = interp1(X,F,Xq,'spline');

    % Then we need to find out the difference with the non-smoothed, so
    % this value is removed/added to the non-neighbourhood part
    fNeighbourhood = f(nhood);
    value          = sum(Fq - fNeighbourhood);
    others         = true(s,1);
    others(nhood)  = false;
    fOthers        = f(others);
    fOthers        = fOthers*binsL;
    fOthers        = fOthers/(1 - sum(f(nhood))); % Scale so the weights sum to 1
    if abs(1 - sum(fOthers)) > 0.001
        fOthers = fOthers/sum(fOthers);
    end
    decrement     = -value.*fOthers;
    f(others)     = f(others) + decrement;
    f(nhood)      = Fq;
    
    % Do some tests
    if any(f < 0)
        error([mfilename ':: The smoothed distribution resulted in negative density at some point(s) in the domain'])
    end
    
end
