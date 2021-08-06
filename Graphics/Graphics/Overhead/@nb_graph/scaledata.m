function dataOut = scaledata(dataIn,minValNew,maxValNew,minValOld,maxValOld)
% Syntax:
%
% dataOut = nb_graph.scaledata(dataIn,minValNew,maxValNew,...
%                     minValOld,maxValOld)
%
% Description:
%
% Rescale the dataseries
%
% Input:
%
% - dataIn    : A double
%
% - minValNew : New min value of the data
%
% - maxValNew : New max value of the data 
%
% - minValOld : Old min value of the data
%
% - maxValOld : Old max value of the data
% 
% Output:
%
% - dataOut   : The input data rescaled
%
% Examples:
%
% See also:
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [numOfPeriods,numVar] = size(dataIn);

    meanOld = minValOld + (maxValOld - minValOld)/2;
    meanNew = minValNew + (maxValNew - minValNew)/2;
    dataOut = dataIn - repmat(meanOld,numOfPeriods,numVar);

    scaleFactor = (maxValNew - minValNew)./(maxValOld - minValOld);
    dataOut     = dataOut.*repmat(scaleFactor,numOfPeriods,numVar) + repmat(meanNew,numOfPeriods,numVar);

end
