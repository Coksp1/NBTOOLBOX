function increment(obj,typeOfDensity,index,value,smoothing)
% Syntax:
%
% increment(obj,type,index,value,smoothing)
%
% Description:
%
% Increment the probability density at a selected point with a given value.
% Please note that the underlying object must be of type 'kernel'.
% 
% Input:
% 
% - obj           : An object of class nb_distribution.
%
% - typeOfDensity : Either 'pdf' or 'cdf'.
%
% - index         : The point in the domain of the distribution to 
%                   increment. See the property parameters.
%
% - value         : The value to increment the selected point in the 
%                   domain. Must be lower than a certain value, as the
%                   density at any point cannot be higher than 1.
%
% - smoothing     : > An integer : The number of elements to smmoth out in 
%                                  the neighbourhood of the selected point.  
%
%                   > 'kernel'   : Using a kernel smoother on the random
%                                  draws produced by the incremented
%                                  distribution. This will not reproduce
%                                  the selected points density, as much of 
%                                  its density will be smoothed out to the 
%                                  neighbourhood.
%
%                   > []         : No smoothing.
% 
% See also:
% nb_distribution.decrement, nb_distribution.convert
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1
        error([mfilename ':: This function only handles a scalar nb_distribution object.'])
    end

    if ~strcmpi(obj.type,'kernel')
        error([mfilename ':: To use this method the distribution must be of type ''kernel''. Please see the convert method.'])
    end
    
    if ~nb_iswholenumber(index) || index < 1
        error([mfilename ':: index input must be an integer greater than 0.'])
    end
    
    if not(isnumeric(value) && isscalar(value)) || index < 0
        error([mfilename ':: value input must be a scalar double with value greater than or equal to 0.'])
    end
    
    if strcmpi(typeOfDensity,'cdf')
        incrementCDF(obj,index,value,smoothing);
    else
        incrementPDF(obj,index,value,smoothing);
    end

end

%==========================================================================
function incrementPDF(obj,index,value,smoothing)

    xi    = obj.parameters{1};
    binsL = xi(2) - xi(1);
    f     = obj.parameters{2};
    s1    = size(f,1);
    if index > s1
        error([mfilename ':: index input is outside bounds.'])
    end

    if (value + f(index))*binsL > 1
        error([mfilename ':: Cannot increment a point to a value so it has higher propability than 1.'])
    end

    % Decrement the density at all other point. Here we decrement the other
    % point by the weight of their respective (current) density.
    others        = true(s1,1);
    others(index) = false;
    fOthers       = f(others);
    fOthers       = fOthers*binsL;
    fOthers       = fOthers/(1 - f(index)); % Scale so the weights sum to 1
    if abs(1 - sum(fOthers)) > 0.001
        fOthers = fOthers/sum(fOthers);
    end
    decrement     = -value.*fOthers;
    f(others)     = f(others) + decrement;

    % Increment the density at the selected point
    f(index)      = f(index) + value;

    % Assign it back to the object
    obj.parameters{2} = f;

    % Then we need to smooth out the density
    if isempty(smoothing)
        return
    elseif strcmpi(smoothing,'kernel')
        smoothDensity(obj,smoothing)
    elseif nb_iswholenumber(smoothing) && smoothing > 0
        smoothDensity(obj,{smoothing,index})
    else
        error([mfilename ':: the smoothing input has been given a wrong value'])
    end

end

%==========================================================================
function incrementCDF(obj,index,value,smoothing)
    error([mfilename ':: typeOfDensity set to ''cdf'' is not yet supported.'])
end
