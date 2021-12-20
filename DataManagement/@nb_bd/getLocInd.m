function [loc,ind,dataOut,numberOfDatasets] = getLocInd(dataIn)
% Syntax:
%
% [loc,ind,dataOut,numberOfDatasets] = getLocInd(dataIn)
%
% Description:
%
% Given a n x n double of data, return the locations of data as a sparse 
% logical, the indicator with information if missing values is stored
% as a 1/0, and the data as a vector with no missing values.
% 
% Input:
% 
% - data             : A n x n double with the data.
% 
% Output:
% 
% - loc              : A n x n sparse logical with information of the 
%                      positions.
%
% - ind              : A 1 x 1 logical. 1 if observations are stored as a 1
%                      and missing values as a 0 in loc, and 0 otherwise.
%
% - dataOut          : A n x 1 double with only the data (no missing 
%                      values).
%
% - numberOfDatasets : A 1 x 1 double. This is equal to the third
%                      dimension of the data as a sparse logical can only 
%                      be 2D. The third dimension is preserved by stacking 
%                      locations horizontally.
% 
% Examples:
%
% data = [1,2,3;1,NaN,4;5,NaN,7];
% [loc,ind,dataOut,numberOfDatasets] = getLocInd(data)
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [s1,s2,s3,s4] = size(dataIn);
    if s4 > 1
        error([mfilename ' :: Data must be three-dimensional at most'])
    end
    
    numberOfDatasets = s3;
    
    obs        = ~isnan(dataIn);
    if s3 > 1
        obs = reshape(obs,[s1,s2*s3]);
    end
    numOnes = sum(obs,'all');
    if numOnes > 0.5 * numel(obs)
        ind = 0;
        loc = sparse(~obs);
    else
        ind = 1;
        loc = sparse(obs);
    end
    
    dataVec = dataIn(:);
    dataOut = dataVec(~isnan(dataVec));    
end
