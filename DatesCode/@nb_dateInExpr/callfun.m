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
% Call a in-built or user defined function on the object.
% 
% Input:
% 
% - obj         : An object of class nb_dateInExpr.
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
%                                 nb_dateInExpr object.
% 
% - 'interpolateDate' : See the nb_dateInExpr.convert method for more on 
%                       this option. Default is 'start'.
%
% - varargin          : Optional inputs given as extra inputs to the 
%                       function func. May be of any class.
%
% Output:
% 
% - varargout : The output will be given as return by the func function  
%               when applied to the input objects.
%
% Examples:
%
% d1 = callfun(d,'func',@sin); % Same as d1 = sin(d) !
% d2 = callfun(d,d,'func','plus') % Same as d2 = d + d !
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    [func,varargin]            = nb_parseOneOptional('func',@(x)x,varargin{:});
    [freq,varargin]            = nb_parseOneOptional('frequency',[],varargin{:});
    [interpolateDate,varargin] = nb_parseOneOptional('interpolateDate','start',varargin{:});
    
    if ~isempty(freq)
        
        oldFreq = obj.date.frequency;
        obj     = convert(obj,freq,'','interpolateDate',interpolateDate);
        for ii = 1:length(varargin)
            if isa(varargin{ii},'nb_dateInExpr')
                varargin{ii} = convert(varargin{ii},freq,'','interpolateDate',interpolateDate);
            end
        end
        
    end
    
    if ischar(func)
        strFunc = func;
        func    = str2func(func);
    else
        strFunc = func2str(func);
    end
    
    try
        [varargout{1:nargout}] = func(obj, varargin{:});
    catch Err
        nb_error([mfilename ':: Calling the function ' strFunc ' on the data of the ' class(obj) ' object failed.'],Err);
    end
    
    % Convert to nb_dataSource object(s)
    for ii = 1:length(varargout)    
        if isa(varargout{ii},'nb_dateInExpr')
            temp = varargout{ii};
            if ~isempty(freq)
                temp = convert(temp,oldFreq,'','interpolateDate',interpolateDate);
            end
            varargout{ii} = temp;
        end
    end
       
end
