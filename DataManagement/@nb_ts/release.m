function obj = release(obj,num)
% Syntax:
%
% obj = release(obj,num)
%
% Description:
%
% Get a specific realease from a real-time dataset.
% 
% Caution : cleanRealTime should be ran to secure that this method does
%           not throw an error.
%
% Input:
% 
% - obj : An object of class nb_ts representing real-time data.
% 
% - num : An integer larger than 0 with the release number.
%
% Output:
% 
% - obj : An object of class nb_ts.
%
% See also:
% nb_ts.cleanRealTime, nb_readExcelMorePages, nb_fetchRealTimeFromFame
% nb_ts.getRelease
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        num = 1;
    end
    
    if ~nb_isScalarInteger(num)
        error([mfilename ':: The num input must be a scalar integer >0.'])
    end
    if num < 1
        error([mfilename ':: The num input must be a scalar integer >0.'])
    end
    
    if ~isUpdateable(obj)
        error([mfilename ':: The object does not represent real-time data.'])
    end
    
    if ~isRealTime(obj)
        error([mfilename ':: The object does not represent a updateable real-time dataset.'])
    end
    
    % This is the trick. As we here need to remove the adding of the 
    % methods called to the links input, so we in the end only add the 
    % extMethod method instead!
    old = obj.updateable;
    obj.updateable = 0;
    
    % Loop each vintage to get release
    dataT = obj.data;
    if num > obj.numberOfDatasets
        error([mfilename ':: The num (realease) can not be greater than the number of pages (datasets) of the obj.'])
    end
    dataOut   = dataT(:,:,num);
    dataIsnan = isnan(dataOut);
    for ii = 1:obj.numberOfVariables
        validInd            = find(~dataIsnan(:,ii),1);
        startInd            = find(dataIsnan(validInd+1:end,ii),1);
        ind                 = validInd + startInd;
        dataPages           = dataT(ind:end,ii,num+1:end);
        dataPages           = permute(dataPages,[1,3,2]);
        dataOut(ind:end,ii) = diag(dataPages);
    end
    
    % Update new properties
    obj.data             = dataOut;
    
    % Then we reset the updateable property so we add the extMethod if
    % needed
    obj.updateable = old;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        % We here rename the sourceType to stop it using specific merging
        % for real-time data in merge and append methods.
        links     = obj.links;
        type      = {links.subLinks.sourceType};
        type      = strrep(type,'realdb','releasedb');
        type      = strrep(type,'nbrealdb','nbreleasedb');
        [links.subLinks.sourceType] = deal(type{:});
        obj.links = links;
        obj       = obj.addOperation(@release,{num});
        
    end
    
end
