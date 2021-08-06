function obj = var(obj,dim,outputType)
% Syntax:
%
% obj = var(obj,flag,dim,outputType)
% 
% Description:
%
% Calculate the variance of each timeseries. The result 
% will be an object of class nb_math_ts where all the non-nan 
% values of all the timeseries are beeing set to their var.
% 
% The output can also be set to be a double only consisting of the 
% var values of the data.
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
% - dim        : The dimension to take the var over
% 
% - outputType : - 'nb_math_ts': The result will be an object
%                  of class nb_math_ts where all the non-nan 
%                  values of all the timeseries are beeing set to 
%                  their var. 
% 
%                - 'double': Get the var values as doubles, 
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
%         timeseries are beeing set to their var. Or a double 
%         with the var values.  
% 
% Examples:
% 
% obj = var(obj)
% 
%     same as
% 
%     obj = var(obj,0,0,'nb_math_ts')
% 
% 
% Output as a double (matrix)
% 
% double = var(obj,0,0,'double')
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        outputType = 'nb_math_ts';
        if nargin < 2
            dim = 1;
        end
    end

    % I cannot vectorize here because the function var made by
    % matlab does not handle nan values as wanted.
    switch lower(outputType)

        case 'nb_math_ts'

            switch dim

                case 1

                    for ii = 1:obj.dim2

                        for jj = 1:obj.dim3

                            isNotNan                 = ~isnan(obj.data(:,ii,jj));
                            obj.data(isNotNan,ii,jj) = var(obj.data(isNotNan,ii,jj));

                        end

                    end

                case 2

                    for ii = 1:obj.dim1

                        for jj = 1:obj.dim3

                            isNotNan                 = ~isnan(obj.data(ii,:,jj));
                            obj.data(ii,isNotNan,jj) = var(obj.data(ii,isNotNan,jj));

                        end

                    end

                case 3

                    for ii = 1:obj.dim2

                        for jj = 1:obj.dim1

                            isNotNan                 = ~isnan(obj.data(jj,ii,:));
                            obj.data(jj,ii,isNotNan) = var(obj.data(jj,ii,isNotNan));

                        end

                    end

                otherwise

                    error([mfilename ':: Unsupported dimension ' int2str(dim)])

            end

        case 'double'

            switch dim

                case 1

                    varValues = nan(1,obj.dim2,obj.dim3);
                    for ii = 1:obj.dim2

                        for jj = 1:obj.dim3

                            isNotNan            = ~isnan(obj.data(:,ii,jj));
                            varValues(1,ii,jj) = var(obj.data(isNotNan,ii,jj));

                        end

                    end

                case 2

                    varValues = nan(obj.dim1,1,obj.dim3);
                    for ii = 1:obj.dim1

                        for jj = 1:obj.dim3

                            isNotNan            = ~isnan(obj.data(ii,:,jj));
                            varValues(ii,1,jj) = var(obj.data(ii,isNotNan,jj));

                        end

                    end

                case 3

                    varValues = nan(obj.dim1,obj.dim2,1);
                    for ii = 1:obj.dim2

                        for jj = 1:obj.dim1

                            isNotNan            = ~isnan(obj.data(jj,ii,:));
                            varValues(jj,ii,1) = var(obj.data(jj,ii,isNotNan));

                        end

                    end

                otherwise

                    error([mfilename ':: Unsupported dimension ' int2str(dim)])

            end    

            obj = varValues;

        otherwise

            error([mfilename ':: Non supported output type; ' outputType])

    end

end
