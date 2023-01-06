function obj = convertEach(obj,freq,methods,varargin)
% Syntax:
%
% obj = convert(obj,freq,methods,varargin)
%
% Description:
% 
% Convert the frequency of the data of the nb_modelData object. Both
% the data property will be transformed to the wanted frequency.
% 
% Caution: The shift property is not handle correctly, so de-trending
% cannot be used in this case!
%
% Input:
% 
% - See the documentation of nb_ts.convertEach.
%
% - 'options' : Provide this as one of the optional inputs, and the 
%               convertion of the frequency will be applied to 
%               options.data and not the dataOrig property. 
%               
% Output:
% 
% - See the documentation of nb_ts.convertEach.
% 
% See also:
% nb_ts.convert
%
% Written by Kenneth S. Paulsen 

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        methods = '';
    end

    [value,varargin] = nb_parseOneOptionalSingle('options',false,true,varargin{:});
    
    if value
        if isempty(obj.options.data)
            error([mfilename ':: The data of the model is empty, so cannot convert the frequency.']) 
        end
        obj.preventSettingData = false;
        obj.options.data       = convertEach(obj.options.data,freq,methods,varargin{:});
        obj.options.shift      = convert(obj.options.shift,freq); % Does not support de-trending in this case, but we just make it not provide an error here
        obj.options.shift      = expand(obj.options.shift,'',obj.options.data.endDate + 2,'zeros','off');
        obj.preventSettingData = true;
    else
        if isempty(obj.dataOrig)
            error([mfilename ':: The data of the model is empty, so cannot convert the frequency.']) 
        end
        obj.dataOrig = convertEach(obj.dataOrig,freq,methods,varargin{:});
    end
    
end
