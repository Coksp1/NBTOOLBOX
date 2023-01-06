function obj = generalFunc(obj,func,varargin)
% Syntax:
%
% obj = generalFunc(obj,func,varargin)
%
% Description:
%
% Call general function on a nb_term objects.
% 
% Input:
% 
% - obj  : A vector of nb_term objects.
%
% - func : A one line char with the function to apply on the nb_term 
%          objects.
%
% Optional input:
%
% - nb_term objects representing the extra inputs to the function.
%
% Output:
% 
% - obj : A vector of nb_term objects.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~nb_isOneLineChar(func)
        error([mfilename ':: The func input must be a one line char with the name of the function to call.'])
    end
    ind = cellfun(@(x)isa(x,'nb_term'),varargin);
    if any(~ind)
        indN = cellfun(@(x)isnumeric(x),varargin);
        if any(not(ind | indN))
            error([mfilename ':: All optional inputs must be nb_term or number objects.'])
        else
            varargin(indN) = cellfun(@(x)nb_num(x),varargin(indN),'uniformOutput',false);
        end
    end
    obj = obj(:);
    for ii = 1:size(obj,1)
        obj(ii) = callFuncOnSub(obj(ii),func,varargin{:});
    end
    
end
