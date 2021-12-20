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
% nb_math_ts object(s). The data of the object is normally of class 
% double, but may also be of class logical. Use
% nb_math_ts.getClassOfData to find the class of the data of the 
% object.
% 
% Input:
% 
% - obj         : An object of class nb_math_ts.
%
% Optional input:
%
% - 'func'             : Either a function handle or a one line char with   
%                        the name of a function (may be user defined in  
%                        both cases). If not provided the function 
%                        @(x)x will be used.
%
% - 'frequency'        : If the operator should act on the data of the 
%                        object, as it was on another frequency, you set 
%                        this option to that frequency. Either 1 (yearly),  
%                        2 (semi-annually), 4 (quarterly), 12 (monthly), 
%                        52 (weekly) or 365 (daily).
%
%                        Caution: It will be applied to the obj input as 
%                                 well as all optional inputs being a 
%                                 nb_math_ts object.
%
%                        Caution: The method applied when converting to a
%                                 higher frequency is 'none', and to a 
%                                 lower frequency is 'discrete'. See the
%                                 nb_math_ts.convert method for more on
%                                 these methods.
% 
% - 'interpolateDate' : See the nb_math_ts.convert method for more on this
%                       option. Default is 'start'.
%
% - varargin          : Optional inputs given as extra inputs to the 
%                       function func. May be of any class. nb_math_ts 
%                       objects are converted to a matrix with elements   
%                       of class double or logical.
%
% Output:
% 
% - varargout : All output from the provided function which results in
%               either a double or logical with the same size as obj 
%               input will be converted to a nb_math_ts object. The 
%               rest will be given as return by the func function when 
%               applied to the data of the object.
%
% Examples:
%
% d       = nb_math_ts.rand('2012Q1',10,3);
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
            extra         = {'includeLast'};
        else
            if strcmpi(interpolateDate,'start')
                convertMethod = 'first';
            else
                convertMethod = 'discrete';
            end
            extra = {};
        end 
        obj = convert(obj,freq,convertMethod,'interpolateDate',interpolateDate,extra{:});
        for ii = 1:length(varargin)
            if isa(varargin{ii},'nb_math_ts')
                varargin{ii} = convert(varargin{ii},freq,convertMethod,'interpolateDate',interpolateDate,extra{:});
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
        if isa(varargin{ii},'nb_math_ts')
            varargin{ii} = varargin{ii}.data;
        end
    end
    
    try
        [varargout{1:nargout}] = func(obj.data, varargin{:});
    catch Err
        nb_error([mfilename ':: Calling the function ' strFunc ' on the data of the ' class(obj) ' object failed.'],Err);
    end
    
    % Convert to nb_dataSource object(s)
    siz = size(obj.data);
    for ii = 1:length(varargout)    
        if nb_sizeEqual(varargout{ii},siz) && any(strcmpi(class(varargout{ii}),{'double','logical','nb_distribution'}))
            temp          = obj;
            temp.data     = varargout{ii};
            if ~isempty(freq)
                switch lower(convertMethod)
                    case 'none'
                        if strcmpi(interpolateDate,'start')
                            revertMethod = 'first';
                        else
                            revertMethod = 'discrete';
                        end
                        temp = convert(temp,oldFreq,revertMethod,'interpolateDate',interpolateDate);
                    case {'discrete','first'}
                        temp = convert(temp,oldFreq,'none','interpolateDate',interpolateDate,'includeLast');
                end
                temp = expand(temp,oldStart,oldEnd,'nan','off');
            end
            varargout{ii} = temp;
        end
    end
    
    if ~isempty(freq)
        warning('on','nb_ts:convert:noOptionIncludeLastWhenDiscrete');
        warning('on','nb_ts:convert:noOptionIncludeLastWhenFirst')
    end
       
end
