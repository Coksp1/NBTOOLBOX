function obj = rdivide(obj,another)
% Syntax:
%
% obj = rdivide(obj,another)
%
% Description:
%
% Division operator (./) for nb_term objects.
% 
% Input:
% 
% Two cases:
%
% One input:
%
% - obj     : A vector of nb_term objects.
%
% Two inputs:
% 
% - obj     : A scalar nb_term object. 
%
% - another : A vector of nb_term objects.
%
% Output:
% 
% - obj     : A scalar nb_term object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin == 1
        another = obj(2:end);
        obj     = obj(1);
    end
    if ~isscalar(obj)
        error([mfilename ':: If two inputs are given, the obj input must be a scalar nb_term object.'])
    end
    another = another(:);
    for ii = 1:size(another,1)
        obj = times(obj,callPowerOnSub(another(ii),nb_num(-1)));
    end
    obj = clean(obj);

end
