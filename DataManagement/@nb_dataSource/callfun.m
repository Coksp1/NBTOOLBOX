function varargout = callfun(obj,varargin)
% Syntax:
%
% obj       = callfun(obj,'func',func)
% obj       = callfun(obj,another,'func',func)
% obj       = callfun(obj,varargin,'func',func)
% varargout = callfun(obj,varargin,'func',func)
%
% Description:
%
% Call a in-built or user defined function on the data of the 
% nb_dataSource object(s). The data of the object is normally of class 
% double, but may also be of class logical or nb_distribution. Use
% nb_dataSource.getClassOfData to find the class of the data of the 
% object.
% 
% Input:
% 
% - obj      : An object of class nb_dataSource.
%
% Optional input:
%
% - 'func'   : Either a function handle or a one line char with the name 
%              of a function (may be user defined in both cases). If not
%              provided the function @(x)x will be used.
% 
% - varargin : Optional inputs given as extra inputs to the function
%              func. May be of any class. nb_dataSource objects are
%              converted to a matrix with elements of class double, 
%              logical or nb_distribution.
%
% Output:
% 
% - varargout : All output from the provided function which results in
%               either a double, logical or nb_distribution with the
%               same size as obj input will be converted to a 
%               nb_dataSource object. The rest will be given as return
%               by the func function when applied to the data of the 
%               object.
%
% Examples:
%
% d       = nb_ts.rand('2012Q1',10,3);
% d1      = callfun(d,'func',@sin); % Same as d1 = sin(d) !
% d2      = callfun(d,d,'func','plus') % Same as d2 = d + d !
% [s1,s2] = callfun(d,'func',@size) % Same as [s1,s2] = size(d)
%
% See also:
% nb_dataSource.getClassOfData
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % When the object is updateable, we need to tell it to return
    % a spesific element of the given update, i.e. this is done
    % inside the update method.
    [returnElement,varargin]   = nb_parseOneOptional('returnElement',0,varargin{:});
    [numOutputs,varargin]      = nb_parseOneOptional('numOutputs',nargout,varargin{:});
    [func,varargin]            = nb_parseOneOptional('func',@(x)x,varargin{:});
    [freq,varargin]            = nb_parseOneOptional('frequency',[],varargin{:});
    [interpolateDate,varargin] = nb_parseOneOptional('interpolateDate','start',varargin{:});
    
    if ~isempty(freq)
        
        warning('off','nb_ts:convert:noOptionIncludeLastWhenDiscrete');
        warning('off','nb_ts:convert:noOptionIncludeLastWhenFirst');
        
        oldStart = obj.startDate;
        oldEnd   = obj.endDate;
        oldFreq  = obj.startDate.frequency;
        if freq > oldFreq
            convertMethod = 'none';
        else
            if strcmpi(interpolateDate,'start')
                convertMethod = 'first';
            else
                convertMethod = 'discrete';
            end
        end 
        obj.isBeingMerged = true;
        obj               = convert(obj,freq,convertMethod,'interpolateDate',interpolateDate,'includeLast');
        for ii = 1:length(varargin)
            if isa(varargin{ii},'nb_ts')
                varargin{ii}.isBeingMerged = true;
                varargin{ii}               = convert(varargin{ii},freq,convertMethod,'interpolateDate',interpolateDate,'includeLast');
            end
        end
        
    end
    
    if ischar(func)
        strFunc = func;
        func    = str2func(func);
    else
        strFunc = func2str(func);
    end
    
    for ii = 1:length(varargin)
        if isa(varargin{ii},'nb_dataSource')
            varargin{ii} = varargin{ii}.data;
        end
    end
    
    try
        [varargout{1:numOutputs}] = func(obj.data, varargin{:});
    catch Err
        nb_error([mfilename ':: Calling the function ' strFunc ' on the data of the ' class(obj) ' object failed.'],Err);
    end
    
    % Convert to nb_dataSource object(s)
    siz = size(obj.data);
    for ii = 1:length(varargout)    
        if nb_sizeEqual(varargout{ii},siz) && any(strcmpi(class(varargout{ii}),{'double','logical','nb_distribution'}))
            temp      = obj;
            temp.data = varargout{ii};
            if ~isempty(freq)
                switch lower(convertMethod)
                    case 'none'
                        if strcmpi(interpolateDate,'start')
                            revertMethod = 'first';
                        else
                            revertMethod = 'discrete';
                        end
                        temp = convert(temp,oldFreq,revertMethod,'interpolateDate',interpolateDate,'includeLast');
                    case {'discrete','first'}
                        temp = convert(temp,oldFreq,'none','interpolateDate',interpolateDate,'includeLast');
                end
                temp = expand(temp,oldStart,oldEnd,'nan','off');
            end
            temp.isBeingMerged = false;
            if obj.isUpdateable()
                % Add operation to the link property, so when the object 
                % is updated the operation will be done on the updated 
                % object
                temp = temp.addOperation(@callfun,[varargin,{'func',func,'returnElement',ii,'numOutputs',numOutputs,...
                        'frequency',freq,'interpolateDate',interpolateDate}]);
            end
            varargout{ii} = temp;
        end
    end
    
    if returnElement ~= 0
        varargout = varargout(returnElement);
    end
    
    if ~isempty(freq)
        warning('on','nb_ts:convert:noOptionIncludeLastWhenDiscrete');
        warning('on','nb_ts:convert:noOptionIncludeLastWhenFirst')
    end
    
end
