function obj = kurtosis(obj,flag,dim,outputType)
% Syntax:
%
% obj = kurtosis(obj,flag,dim,outputType)
% 
% Description:
%
% Calculate the kurtosis of each timeseries. The result 
% will be an object of class nb_math_ts where all the non-nan 
% values of all the timeseries are beeing set to their kurtosis.
% 
% The output can also be set to be a double only consisting of the 
% kurtosis values of the data.
% 
% Input:
% 
% - obj        : An object of class nb_math_ts
% 
% - flag       : > 0 : normalises by N-1 (Default)
%                > 1 : normalises by N
% 
%                Where N is the sample length.
% 
% - dim        : The dimension to take the kurtosis over
% 
% - outputType : - 'nb_math_ts': The result will be an object
%                  of class nb_math_ts where all the non-nan 
%                  values of all the timeseries are beeing set to 
%                  their kurtosis. 
% 
%                - 'double': Get the kurtosis values as doubles, 
%                  where each column of the double matches the
%                  same column of the data property of the 
%                  nb_math_ts object. If the object consist of more 
%                  pages the double will also consist of more 
%                  pages.
%                  
% 
% Output:
% 
% - obj : The object itself where all the non-nan values of all the 
%         timeseries are beeing set to their kurtosis. Or a double 
%         with the kurtosis values.  
% 
% Examples:
% 
% obj = kurtosis(obj)
% 
%     same as
% 
%     obj = kurtosis(obj,0,0,'nb_math_ts')
% 
% 
% Output as a double (matrix)
% 
% double = kurtosis(obj,0,0,'double')
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 4
        outputType = 'nb_math_ts';
        if nargin < 3
            dim = 1;
            if nargin < 2
                flag = 0;
            end
        end
    end

    % I cannot vectorize here because the function kurtosis made by
    % matlab does not handle nan values as wanted.
    switch lower(outputType)

        case 'nb_math_ts'

            switch dim

                case 1

                    for ii = 1:obj.dim2

                        for jj = 1:obj.dim3

                            isNotNan                 = ~isnan(obj.data(:,ii,jj));
                            obj.data(isNotNan,ii,jj) = kurtosis(obj.data(isNotNan,ii,jj),flag,1);

                        end

                    end

                case 2

                    for ii = 1:obj.dim1

                        for jj = 1:obj.dim3

                            isNotNan                 = ~isnan(obj.data(ii,:,jj));
                            obj.data(ii,isNotNan,jj) = kurtosis(obj.data(ii,isNotNan,jj),flag,2);

                        end

                    end

                case 3

                    for ii = 1:obj.dim2

                        for jj = 1:obj.dim1

                            isNotNan                 = ~isnan(obj.data(jj,ii,:));
                            obj.data(jj,ii,isNotNan) = kurtosis(obj.data(jj,ii,isNotNan),flag,3);

                        end

                    end

                otherwise

                    error([mfilename ':: Unsupported dimension ' int2str(dim)])
            end

        case 'double'

            switch dim

                case 1

                    kurtosisValues = nan(1,obj.dim2,obj.dim3);
                    for ii = 1:obj.dim2

                        for jj = 1:obj.dim3

                            isNotNan                = ~isnan(obj.data(:,ii,jj));
                            kurtosisValues(1,ii,jj) = kurtosis(obj.data(isNotNan,ii,jj),flag,1);

                        end

                    end

                case 2

                    kurtosisValues = nan(obj.dim1,1,obj.dim3);
                    for ii = 1:obj.dim1

                        for jj = 1:obj.dim3

                            isNotNan                = ~isnan(obj.data(ii,:,jj));
                            kurtosisValues(ii,1,jj) = kurtosis(obj.data(ii,isNotNan,jj),flag,2);

                        end

                    end

                case 3

                    kurtosisValues = nan(obj.dim1,obj.dim2,1);
                    for ii = 1:obj.dim2

                        for jj = 1:obj.dim1

                            isNotNan                = ~isnan(obj.data(jj,ii,:));
                            kurtosisValues(jj,ii,1) = kurtosis(obj.data(jj,ii,isNotNan),flag,3);

                        end

                    end

                otherwise

                    error([mfilename ':: Unsupported dimension ' int2str(dim)])
            end

            obj = kurtosisValues;

        otherwise

            error([mfilename ':: Non supported output type; ' outputType])

    end

end
