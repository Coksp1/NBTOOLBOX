function obj = max(obj,dim,outputType)
% Syntax:
%
% obj = max(obj,dim,outputType)
%
% Description:
%
% Calculate the max values of each timeseries. The result 
% will be an object of class nb_math_ts where all the non-nan 
% values of all the timeseries are beeing set to their max.
% 
% The output can also be set to be a double only consisting of the 
% max values of the data.
% 
% Input:
% 
% - obj        : An object of class nb_math_ts
% 
% - dim        : The dimension to find the max over
% 
% - outputType : - 'nb_math_ts': The result will be an object
%                  of class nb_math_ts where all the non-nan 
%                  values of all the timeseries are beeing set to 
%                  their max.  
% 
%                - 'double': Get the max values as doubles, 
%                  where each column of the double matches the
%                  same column of the data property of the 
%                  nb_math_ts object. If the object consist of more 
%                  pages the double will also consist of more 
%                  pages.
% 
% Output:
% 
% - obj : The object itself where all the non-nan values of all the
%         timeseries are beeing set to their max. Or a double with 
%         the max values.  
% 
% Examples:
% 
% obj = max(obj)
% 
%     same as
% 
%     obj = max(obj,1,'nb_math_ts')
% 
% 
% Output as a double (matrix)
% 
% double = max(obj,1,'double')
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        outputType = 'nb_math_ts';
    end

    switch outputType

        case 'nb_math_ts'

            switch dim

                case 1

                    isNan    = isnan(obj.data);
                    obj.data = repmat(max(obj.data,[],1),obj.dim1,1);
                    obj.data(isNan) = nan;

                case 2

                    isNan    = isnan(obj.data);
                    obj.data = repmat(max(obj.data,[],1),[1,obj.dim2,1],1);
                    obj.data(isNan) = nan;

                case 3

                    isNan    = isnan(obj.data);
                    obj.data = repmat(max(obj.data,[],3),[1,1,obj.dim3],1);
                    obj.data(isNan) = nan;

                otherwise

                    error([mfilename ':: Unsupported dimension ' int2str(dim)])
            end

        case 'double'

            obj = max(obj.data,[],dim);

        otherwise

            error([mfilename ':: Non supported output type; ' outputType])    

    end

end
