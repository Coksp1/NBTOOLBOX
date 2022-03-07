function uih = nb_uitable(obj,varargin)
% Syntax:
%
% nb_uitable(obj,varargin)
%
% Description:
%
% Add a nb_uitable object to a button panel.
% 
% Input:
% 
% - obj      : An nb_buttonPanel object.
%
% - varargin : Optional inputs given to the MATLAB uicontrol 
%              function.
%
%              Extra properties :
%
%              - 'button' : The name of the button the nb_uitable element
%                           should be associated with. Default is the
%                           first element in the buttonNames property.
% 
% Output:
% 
% The wanted nb_uitable added to one of the panels. 
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
    uih = nb_uitable(obj.panel(ind),optStruct{:},opt{:});

end
