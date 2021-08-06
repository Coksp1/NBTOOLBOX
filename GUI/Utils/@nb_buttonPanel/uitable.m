function uih = uitable(obj,varargin)
% Syntax:
%
% uitable(obj,varargin)
%
% Description:
%
% Add a uitable object to a button panel.
%
% Input:
% 
% - obj      : A nb_buttonPanel object.
%
% - varargin : Optional inputs given to the MATLAB uitable 
%              function.
%
%              Extra properties :
%
%              - 'button' : The name of the button the uitable element
%                           should be associated with. Default is the
%                           first element in the buttonNames property.
% 
% Output:
% 
% The wanted uitable added to one of the panels. 
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
    uih = uitable(obj.panels(indB),optStruct{:},opt{:});

end
