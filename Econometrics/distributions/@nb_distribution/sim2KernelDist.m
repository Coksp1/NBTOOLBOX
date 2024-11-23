function dist = sim2KernelDist(y,lb,ub,varargin)
% Syntax:
%
% dist = nb_distribution.sim2KernelDist(y)
% dist = nb_distribution.sim2KernelDist(y,lb,ub,varargin)
%
% Description:
%
% Convert a simulated data to a nb_distribution object.
% 
% Input:
% 
% - y  : A nHor x nVar x nDraws double matrix.
% 
% - lb : A nHor x nVar double matrix with the lower bounds. Set to
%        empty if no bounds on any elements (default). Set to -inf
%        to not bound a given element.
%
% - ub : A nHor x nVar double matrix with the upper bounds. Set to
%        empty if no bounds on any elements (default). Set to inf
%        to not bound a given element.
%
% Optional input:
%
% - varargin : See varargin in nb_distribution.estimate. 'support' is not
%              supported. See the lb and ub inputs instead.
%
% Output:
% 
% - obj : An nHor x nVar object of class nb_distribution.
%
% Examples:
%
% obj = nb_distribution.sim2KernelDist(rand(2,2,1000)) 
%
% See also:
% nb_distribution.estimate
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        ub = [];
        if nargin < 2
            lb = [];
        end
    end

    [nHor,nVar,~]   = size(y);
    dist(nHor,nVar) = nb_distribution();

    % Conver to nb_distribution objects
    if isempty(lb) && isempty(ub) 
        for ii = 1:nVar
            for hh = 1:nHor    
                dist(hh,ii) = nb_distribution.estimate(permute(y(hh,ii,:),[3,1,2]),[],varargin{:});
            end
        end
    else
        
        if ~all(size(lb) == [nHor,nVar])
            error([mfilename ':: The lb input must have size ' int2str(nHor) 'x' int2str(nVar) '.'])
        end
        if ~all(size(ub) == [nHor,nVar])
            error([mfilename ':: The lb input must have size ' int2str(nHor) 'x' int2str(nVar) '.'])
        end
        lbInf = ~isfinite(lb);
        ubInf = ~isfinite(ub);
        if any(lbInf & ~ubInf)
            ind     = lbInf & ~ubInf;
            minData = min(y,[],3);
            stdData = std(y,0,1);
            lb(ind) = minData(ind) - stdData(ind);
        end
        if any(~lbInf & ubInf)
            ind     = ~lbInf & ubInf;
            maxData = max(y,[],3);
            stdData = std(y,0,1);
            ub(ind) = maxData(ind) + stdData(ind);
        end
        
        for ii = 1:nVar
            for hh = 1:nHor    
                bounds = [lb(hh,ii),ub(hh,ii)];
                if all(isfinite(bounds))
                    dist(hh,ii) = nb_distribution.estimate(permute(y(hh,ii,:),[3,1,2]),[],'support',bounds,varargin{:});
                else
                    dist(hh,ii) = nb_distribution.estimate(permute(y(hh,ii,:),[3,1,2]),[],varargin{:});
                end
            end
        end
        
    end
        
end
