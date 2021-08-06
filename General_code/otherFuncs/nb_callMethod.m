function result = nb_callMethod(obj,meth,classConst,varargin)
% Syntax:
%
% result = nb_callMethod(obj,meth,classConst,varargin)
%
% Description:
%
% Call method meth on the matrix of objects obj.
% 
% Input:
% 
% - obj        : A N x M object of any class.
% 
% - meth       : The method to call.
%
% - classConst : Class constructor as a function_handle.
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

    siz = size(obj);
    obj = obj(:);
    if strcmpi(classConst,'cell')
        result = cell(prod(siz),1);
        for ii = 1:prod(siz)
            result{ii} = meth(obj(ii),varargin{:});
        end
    else
        result(prod(siz),1) = classConst();
        for ii = 1:prod(siz)
            result(ii) = meth(obj(ii),varargin{:});
        end
    end
    result = reshape(result,siz);

end
