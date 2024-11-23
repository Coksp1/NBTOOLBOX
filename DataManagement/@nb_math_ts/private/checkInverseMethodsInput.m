function [d0,t] = checkInverseMethodsInput(obj,initialValues,periods,startAtNaN)
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isempty(initialValues)
        if isempty(periods)
            initialValues = repmat(100,[obj.dim1,obj.dim2,obj.dim3]); 
        else
            if periods == 1
                initialValues = repmat(100,[obj.dim1,obj.dim2,obj.dim3]); 
            else
                error([mfilename ':: When the periods input is not equal to 1 the initialValues must be provided.'])
            end
        end
    end

    if isa(initialValues,'nb_math_ts')
        
        if isempty(initialValues)
            error('The initialValues input cannot be a empty nb_math_ts object.')
        end
        
        if initialValues.startDate > obj.startDate
            error(['The initialValues input must have a start date (',...
                toString(initialValues.startDate) ') that is before '...
                'the start date of this object (' toString(obj.startDate) ').'])
        end
        if startAtNaN
            initEnd = initialValues.getRealEndDate('nb_date','all');
            if isempty(periods)
                needed = initEnd;
            else
                needed = initEnd - (periods - 1);
            end
            if initialValues.startDate > needed
                error([mfilename ':: The initialValues input must start at ' toString(needed) '.'])
            end
            t  = (needed - obj.startDate) + 1;
            d0 = double(window(initialValues,needed,initEnd));
        else
            neededS = getRealStartDate(obj,'nb_date','any');
            if isempty(periods)
                needed = obj.getRealStartDate('nb_date','all');
            else
                needed = obj.getRealStartDate('nb_date','all') + (periods - 1);
            end
            if initialValues.endDate < needed
                error(['The initialValues input must have at least observation until ' toString(needed) '.'])
            end
            d0 = double(window(initialValues,neededS,needed));
            t  = (neededS - obj.startDate) + 1; 
        end
        
    elseif isnumeric(initialValues)
        if startAtNaN
            error('The startAtNaN is not supported when initialValues is not given as a nb_math_ts object.')
        end
        d0 = initialValues;
        t  = 1;
    else
        error('The initialValues input must be a double or nb_math_ts object!')
    end

    if size(d0,2) ~= obj.dim2
        error('The ''initialValues'' has not the same number of columns as the given object.')
    elseif size(d0,3) ~= obj.dim3
        error('The ''initialValues'' has not the same number of pages as the given object.')
    end
    if isempty(periods)
        if size(d0,1) < 1
            error('The ''initialValues'' must have at least on row.')
        end
    else
        if size(d0,1) < periods
            error(['The ''initialValues'' must has the same number of rows ',...
                'as the periods input indicates (I.e. ' int2str(periods) '.).'])
        end
    end
    
end
