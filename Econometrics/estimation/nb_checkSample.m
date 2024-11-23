function [endInd,startInd,varargout] = nb_checkSample(varargin)
% Syntax:
%
% nb_checkSample(y,X)
% [endInd,startInd,varargout] = nb_checkSample(varargin)
%
% Description:
%
% Check data first and last real observations. 
%
% Input:
% 
% - varargin  : Matrices that can be horcat
% 
% Output:
% 
% - endInd    : Last real data point in the data
%
% - startInd  : First real data point in the data
%
% - varargout : Same as varargin, but may have been shortened due to
%               trailing and leading nan values
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    X     = [varargin{:}];
    isNaN = any(~isfinite(X),2);
    
    if isNaN(1)
        startInd = find(~isNaN,1);
    else
        startInd = 1;
    end
    endInd = find(~isNaN,1,'last');
    if isempty(endInd)
        error([mfilename ':: The data is unbalanced, which is not yet supported.'])
    end
    
    varargout = varargin;
    if endInd == size(X,1) && startInd == 1
        return
    end
    
    if any(isNaN(startInd:endInd))
        error([mfilename ':: The data contain missing observation in the middle of the sample, which this estimator does not support.'])
    end
    
    for ii = 1:length(varargin)
        varargout{ii} = varargin{ii}(startInd:endInd,:);
    end
    
end
