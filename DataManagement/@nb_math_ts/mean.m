function obj = mean(obj,dim,outputType)
% Syntax:
%
% obj = mean(obj,dim,outputType)
% 
% Description:
%
% Calculate the mean of each timeseries. The result 
% will be an object of class nb_math_ts where all the non-nan 
% values of all the timeseries are beeing set to their mean.
% 
% The output can also be set to be a double only consisting of the 
% mean values of the data.
% 
% Input:
% 
% - obj        : An object of class nb_math_ts
% 
% - dim        : The dimension to take the mean over
% 
% - outputType : - 'nb_math_ts': The result will be an object
%                  of class nb_math_ts where all the non-nan 
%                  values of all the timeseries are beeing set to 
%                  their mean. 
% 
%                - 'double': Get the mean values as doubles, 
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
%         timeseries are beeing set to their mean. Or a double 
%         with the mean values.  
% 
% Examples:
% 
% obj = mean(obj)
% 
%     same as
% 
%     obj = mean(obj,1,'nb_math_ts')
% 
% 
% Output as a double (matrix)
% 
% double = mean(obj,1,'double')
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        outputType = 'nb_math_ts';
        if nargin < 2
           dim = 1; 
        end
    end

    % I cannot vectorize here because the function mean made by
    % matlab does not handle nan values as wanted.
    switch lower(outputType)

        case 'nb_math_ts'

            switch dim

                case 1

                    for ii = 1:obj.dim2

                        for jj = 1:obj.dim3

                            isNotNan                 = ~isnan(obj.data(:,ii,jj));
                            obj.data(isNotNan,ii,jj) = mean(obj.data(isNotNan,ii,jj));

                        end

                    end

                case 2

                    for ii = 1:obj.dim1

                        for jj = 1:obj.dim3

                            isNotNan                 = ~isnan(obj.data(ii,:,jj));
                            obj.data(ii,isNotNan,jj) = mean(obj.data(ii,isNotNan,jj));

                        end

                    end

                case 3

                    for ii = 1:obj.dim2

                        for jj = 1:obj.dim1

                            isNotNan                 = ~isnan(obj.data(jj,ii,:));
                            obj.data(jj,ii,isNotNan) = mean(obj.data(jj,ii,isNotNan));

                        end

                    end

                otherwise

                    error([mfilename ':: Unsupported dimension ' int2str(dim)])

            end

        case 'double'

            switch dim

                case 1

                    meanValues = nan(1,obj.dim2,obj.dim3);
                    for ii = 1:obj.dim2

                        for jj = 1:obj.dim3

                            isNotNan            = ~isnan(obj.data(:,ii,jj));
                            meanValues(1,ii,jj) = mean(obj.data(isNotNan,ii,jj));

                        end

                    end

                case 2

                    meanValues = nan(obj.dim1,1,obj.dim3);
                    for ii = 1:obj.dim1

                        for jj = 1:obj.dim3

                            isNotNan            = ~isnan(obj.data(ii,:,jj));
                            meanValues(ii,1,jj) = mean(obj.data(ii,isNotNan,jj));

                        end

                    end

                case 3

                    meanValues = nan(obj.dim1,obj.dim2,1);
                    for ii = 1:obj.dim2

                        for jj = 1:obj.dim1

                            isNotNan            = ~isnan(obj.data(jj,ii,:));
                            meanValues(jj,ii,1) = mean(obj.data(jj,ii,isNotNan));

                        end

                    end

                otherwise

                    error([mfilename ':: Unsupported dimension ' int2str(dim)])

            end    

            obj = meanValues;

        otherwise

            error([mfilename ':: Non supported output type; ' outputType])

    end

end
