function result = nb_callMethodWaitbar(obj,meth,classConst,waitbar,varargin)
% Syntax:
%
% result = nb_callMethodWaitbar(obj,meth,classConst,waitbar,varargin)
%
% Description:
%
% Call method meth on the matrix of objects obj using a waitbar.
% 
% Input:
% 
% - obj        : A N x M object of any class.
% 
% - meth       : The method to call.
%
% - classConst : Class constructor as a function_handle.
%
% - waitbar    : A nb_waitbar5 object.
%
% Optional input:
%
% - varargin   : Given to the method specified by meth.
%
% Output:
% 
% - result : A N x M object of class cl.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isa(waitbar,'nb_waitbar5')
        error([mfilename ':: The waitbar input must be a nb_waitbar5 object.'])
    end

    [s1,s2] = size(obj);
    num     = s1*s2;
    obj     = obj(:);
    value   = int2str(getNextAvailable(waitbar));
    waitbar.(['maxIterations', value]) = num;
    
    if strcmpi(classConst,'cell')
        result = cell(num,1);
        for ii = 1:num
            result{ii}                  = meth(obj(ii),varargin{:});
            waitbar.(['status', value]) = ii;
        end
    else
        result(num,1) = classConst();
        for ii = 1:num
            result(ii)                  = meth(obj(ii),varargin{:});
            waitbar.(['status', value]) = ii;
        end
    end
    result = reshape(result,[s1,s2]);

end
