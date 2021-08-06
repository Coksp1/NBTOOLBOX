function obj = sum(obj,dim)
% Syntax:
%
% obj = sum(obj,dim)
%
% Description:
%
% Takes the sum of the object data in the wanted dimension
% 
% Input:
% 
% obj : An object of class nb_math_ts
% 
% dim : The dimension to sum over, returns:
% 
%       - dim = 1 : An nb_math_ts object with all the variables set
%                   to their cross observation sum
% 
%       - dim = 2: An nb_math_ts object with all variables set to 
%                  their cross variable sum (Take the sum over the 
%                  varibales)
% 
%       - dim = 3: An nb_math_ts with only on page, representing 
%                  the sum over all pages.
% 
% Caution : All sums ignore nan values. (If all values is not nan.)
% 
% Output:
% 
% - obj : An nb_math_ts object representing the sum. 
%         (Keeps the dimension)
% 
% Examples:
% 
% obj = sum(obj,1)
% obj = sum(obj,2)
% obj = sum(obj,3)
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        dim = 2;
    end

    dat      = obj.data;
    isNaNAll = isnan(dat);
    isNaN2   = any(isNaNAll);
    isNaN3   = any(squeeze(isNaN2),1);
    foundNaN = any(isNaN3,2);

    switch dim

        case 1

            if ~foundNaN

                sumOfData = sum(obj.data,1);

            else

                sumOfData = nan(obj.dim1,1,obj.dim3);
                for ii = 1:obj.dim3

                    for jj = 1:obj.dim2

                        dataTemp           = obj.data(jj,:,ii);
                        isNaNTemp          = isNaNAll(jj,:,ii);
                        dataTemp           = sum(dataTemp(~isNaNTemp),2);
                        sumOfData(1,jj,ii) =  dataTemp;

                    end

                end

            end

            obj.data = repmat(sumOfData,[obj.dim1, 1, 1]);

        case 2

            if ~foundNaN

                sumOfData = sum(obj.data,2);

            else

                sumOfData = nan(obj.dim1,1,obj.dim3);
                for ii = 1:obj.dim1

                    for jj = 1:obj.dim1

                        dataTemp           = obj.data(jj,:,ii);
                        isNaNTemp          = isNaNAll(jj,:,ii);
                        dataTemp           = sum(dataTemp(~isNaNTemp),2);
                        sumOfData(jj,1,ii) = dataTemp;

                    end

                end

            end

            obj.data = repmat(sumOfData,[1, obj.dim2, 1]);

        case 3

            if ~foundNaN

                sumOfData = sum(obj.data,3);

            else

                sumOfData = nan(obj.dim1,obj.dim2,1);
                for ii = 1:obj.dim1

                    for jj = 1:obj.dim2

                        dataTemp           = obj.data(ii,jj,:);
                        isNaNTemp          = isNaNAll(ii,jj,:);
                        dataTemp           = sum(dataTemp(~isNaNTemp),3);
                        sumOfData(ii,jj,1) =  dataTemp;

                    end

                end

            end

            obj.data = repmat(sumOfData,[1, 1, obj.dim3]);

        otherwise

            error([mfilename ':: It is not possible to take the sum of the ' int2str(dim) ' dimension.'])

    end

end
