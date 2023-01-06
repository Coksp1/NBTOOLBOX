function d = nb_depcat(varargin)
% Syntax:
%
% d = nb_depcat(varargin)
%
% Description:
%
% Concatenation of inputs along the 3 dimension.
% 
% Input:
% 
% - d1 : Any.
%
% - d2 : Any, but same as d1.
% 
% Output:
% 
% - d  : Any, but same type as inputs. 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin == 0
        d = [];
    end

    cl = cellfun(@class,varargin,'UniformOutput',false);
    if ~all(strcmpi(cl{1},cl(2:end)))
        error([mfilename ':: All object being concatenated must be of same class.'])
    end
    s1 = cellfun(@(x)size(x,1),varargin);
    s2 = cellfun(@(x)size(x,2),varargin);
    s3 = cellfun(@(x)size(x,3),varargin);
    if any(s1(1) ~= s1(2:end))
        error([mfilename ':: The inputs to concatenate must have same number of rows.'])
    end
    if any(s1(1) ~= s1(2:end))
        error([mfilename ':: The inputs to concatenate must have same number of columns.'])
    end
    if isnumeric(varargin{1})
        d = nan(s1(1),s2(1),sum(s3));
    else
        func                   = str2func(class(d1));
        d(s1(1),s2(1),sum(s3)) = func();
    end
    s = 1;
    e = 0;
    for ii = 1:nargin
        e          = e + s3(ii); 
        d(:,:,s:e) = varargin{ii};
        s          = e + 1;
    end
    
end
