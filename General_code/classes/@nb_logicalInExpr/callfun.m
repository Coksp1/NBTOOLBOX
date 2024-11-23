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
% - obj         : An object of class nb_logicalInExpr.
%
% Optional input:
%
% - 'func'            : Either a function handle or a one line char with   
%                       the name of a function (may be user defined in  
%                       both cases). If not provided the function 
%                       @(x)x will be used.
%
% - 'frequency'       : Any
% 
% - 'interpolateDate' : Any
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

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    [func,varargin] = nb_parseOneOptional('func',@(x)x,varargin{:});
    [~,varargin]    = nb_parseOneOptional('frequency',[],varargin{:});
    [~,varargin]    = nb_parseOneOptional('interpolateDate','start',varargin{:});
    
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
       
end
