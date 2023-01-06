function [uih,uiht] = uipanel(obj,varargin)
% Syntax:
%
% uipanel(obj,varargin)
% [uih,uiht] = uipanel(obj,varargin)
%
% Description:
%
% Add a uipanel object to a row panel.
% 
% Caution : The 'position' input may be given with nan values at some
%           elements. The nan values will then be filled with default
%           values. The default values will depend on the 'column'
%           option.
%
% Input:
% 
% - obj      : An nb_rowPanel object.
%
% - varargin : Optional inputs given to the MATLAB uicontrol 
%              function.
%
%              Prohibited properties : 
%
%              - 'parent' (set to obj.parent), 
%                'units' (Set to 'normalized')
%
%              Extra properties :
%
%              - 'title'  : If given as a non-empty string a uicontrol 
%                           (text) object is automatically added to the 
%                           left of the default location of the added
%                           uicontrol object. Not valid if 'column'
%                           is set to 1.
%
%              - 'column' : 1,2,3. Defualt is 2. If 'position' is given
%                           it will trumpf this option.
% 
% Output:
% 
% - uih     : A uipanel object.
%
% - uiht    : A uicontrol object or empty. If the 'title' input is used 
%             the output is uicontrol object, otherwise it is empty.
%
% Written by Kenneth Sæterhagen Paulsen        

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    opt          = varargin;
    indS         = cellfun(@isstruct,opt);
    optStruct    = opt(indS);
    opt          = opt(~indS);
    kk           = obj.numberOfElements - length(obj.children2);
    [column,opt] = nb_parseOneOptional('column',2,opt{:});
    switch column
        case 1
            defaultPos = [obj.start1Column, obj.height2Column*(kk-1) + obj.spaceY*kk + obj.extraY1Column, obj.width1Column, obj.height1Column];
        case 2
            defaultPos = [obj.start2Column, obj.height2Column*(kk-1) + obj.spaceY*kk, obj.width2Column, obj.height2Column];
        case 3
            defaultPos = [obj.start3Column, obj.height2Column*(kk-1) + obj.spaceY*kk, obj.width3Column, obj.height2Column];
        otherwise
            error([mfilename ':: Wrong input given to ''column''.'])
    end
    
    [position,opt] = nb_parseOneOptional('position',defaultPos,opt{:});
    [title,opt]    = nb_parseOneOptional('title','',opt{:});

    if isnan(position(1))
        position(1) = defaultPos(1);
    end
    if isnan(position(2))
        position(2) = defaultPos(2);
    end
    if isnan(position(3))
        position(3) = defaultPos(3);
    end
    if isnan(position(4))
        position(4) = defaultPos(4);
    end

    uih = uipanel(obj.panel,optStruct{:},...
        'units',    'normalized',...
        'position', position,...
        opt{:});

    obj.(['children' int2str(column)]) = [obj.(['children' int2str(column)]),{uih}];
    
    % Title uicontrol
    uiht = [];
    if ~isempty(title) && column ~= 1
        uiht = uicontrol(...
              'units',                  'normalized',...
              'position',               [obj.start1Column, obj.height2Column*(kk-1) + obj.spaceY*kk + obj.extraY1Column, obj.width1Column, obj.height1Column],...
              'parent',                 obj.panel,...
              'style',                  'text',...
              'horizontalAlignment',    'left',...
              'string',                 title);
        obj.children1 = [obj.children1,{uiht}];
    end
    
end
