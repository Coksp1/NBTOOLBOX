function obj = convertEach(obj,freq,methods,varargin)
% Syntax:
%
% obj = convertEach(obj,freq,method,varargin)
%
% Description:
% 
% Convert the frequency of each series of the nb_ts object. 
%
% Caution: If you want to apply same convertion method to all series use
% nb_ts.convert instead.
% 
% Input:
% 
% - obj     : An object of class nb_ts.
% 
% - freq    : The new freqency of the data. As an integer:
% 
%             > 1   : yearly
%             > 2   : semi annually
%             > 4   : quarterly
%             > 12  : monthly
%             > 52  : weekly
%             > 365 : daily
% 
% - methods : The methods to use to convert each series. As a 1 x 
%             numberOfVariables cell array. Set to '' to use default. 
%             See the method input to the nb_ts.convert to get information
%             on the supported method you can use to convert the series.
% 
% Optional input:
%
% - Same as for the nb_ts.convert method. Will be applied to all series.
%
% Output:
% 
% - obj : An nb_ts object converted to wanted frequency.
% 
% See also:
% nb_ts.convert
%
% Written by Kenneth S. Paulsen                                   

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    obj.isBeingMerged = true;

    if nb_isOneLineChar(methods)
        obj = convert(obj,freq,methods,varargin{:});
    elseif iscellstr(methods)
    
        methods = methods(:);
        if length(methods) ~= obj.numberOfVariables
            error([mfilename ':: The methods input must be a cellstr with length ' int2str(obj.numberOfVariables)])
        end
        converted = cell(1,obj.numberOfVariables);
        for ii = 1:obj.numberOfVariables
            objOne        = window(obj,'','',obj.variables(ii));
            converted{ii} = convert(objOne,freq,methods{ii},varargin{:});
        end
        obj = [converted{:}];
        
    else
        error([mfilename ':: The methods input must be a cellstr'])
    end
    obj.isBeingMerged = false;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@convertEach,[{freq,methods},varargin]);
        
    end
    
end
