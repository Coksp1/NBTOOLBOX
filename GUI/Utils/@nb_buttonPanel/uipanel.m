function uih = uipanel(obj,varargin)
% Syntax:
%
% uipanel(obj,varargin)
%
% Description:
%
% Add a uipanel object to a button panel.
% 
% Input:
% 
% - obj      : A nb_buttonPanel object.
%
% - varargin : Optional inputs given to the MATLAB uipanel 
%              function.
%
%              Extra properties :
%
%              - 'button' : The name of the button the uipanel element
%                           should be associated with. Default is the
%                           first element in the buttonNames property.
% 
% Output:
% 
% The wanted uipanel added to one of the panels. 
%
% Written by Kenneth Sæterhagen Paulsen        

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    opt          = varargin;
    indS         = cellfun(@isstruct,opt);
    optStruct    = opt(indS);
    opt          = opt(~indS);
    [button,opt] = nb_parseOneOptional('button',obj.buttonNames{1},opt{:});
    indB         = strcmpi(button,obj.buttonNames);
    if ~any(indB)
        error([mfilename ':: The ' button ' is not an element of the buttonNames property.'])
    end
    uih = uipanel(obj.panels(indB),optStruct{:},opt{:});

end
