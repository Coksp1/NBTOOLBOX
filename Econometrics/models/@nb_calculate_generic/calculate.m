function calc = calculate(obj,varargin)
% Syntax:
%
% calc = calculate(obj,varargin)
%
% Description:
%
% Do the calculation associated with the object.
% 
% Input:
% 
% - obj        : An object array of class nb_calculate_generic. 
% 
% - 'parallel' : Use this string as one of the optional inputs to run the
%                estimation in parallel.
%
% - 'cores'    : The number of cores to open, as an integer. Default
%                is to open max number of cores available. Only an 
%                option if 'parallel' is given. 
%
% - 'remove'   : Give 'remove' to remove the models that return errors from
%                the obj output. This input is not stored to the 
%                forecastOutput property of the objects. 
%
% - 'waitbar'  : Use this string to give a waitbar during estimation. I.e.
%                when looping over models. If 'parallel' is used this
%                option is not supported!
%
% - 'write'    : Use this option to write errors to a file instead of 
%                throwing the error.
%
% Optional input:
% 
% - varargin : See the the set method.
%
% Output:
% 
% - calc : An cell array of class nb_ts, each element stores the
%          calculation results of the corresponding model. An element is
%          empty if the corresponding model is found not to be valid.
%
% See also:
% nb_calculate_generic.getCalculated
%
% Written by Kenneth Sæterhagen Paulsen

    [obj,valid] = estimate(obj,varargin{:});
    nObj        = length(obj);
    calc        = cell(1,nObj);
    for ii = 1:nObj
        if valid(ii)
            calc{ii} = getCalculated(obj(ii));
        end
    end
    
end
