function [uih,uiht] = nb_gridcontainer(obj,varargin)
% Syntax:
%
% [uih,uiht] = nb_gridcontainer(obj,varargin)
%
% Description:
%
% Add a nb_gridcontainer object to a row panel.
% 
% Input:
% 
% - obj      : A nb_rowPanel object.
%
% - varargin : Optional inputs given to the nb_gridcontainer class.
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
% Output:
%
% - uih  : A nb_gridcontainer object.
%
% - uiht : A uicontrol object or empty. If the 'title' input is used 
%          the output is uicontrol object, otherwise it is empty.
%
% Written by Kenneth Sæterhagen Paulsen        

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    opt            = varargin;
    indS           = cellfun(@isstruct,opt);
    optStruct      = opt(indS);
    opt            = opt(~indS);
    kk             = obj.numberOfElements - length(obj.children2);
    [column,opt]   = nb_parseOneOptional('column',2,opt{:});
    defaultPos     = [obj.start1Column, obj.height2Column*(kk-1) + obj.spaceY*kk + obj.extraY1Column, obj.width1Column, obj.height1Column];
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

    uih = nb_gridcontainer(obj.panel,optStruct{:},...
        'units',    'normalized',...
        'position', position,...
        opt{:});

    obj.children2 = [obj.children2,{uih}];
    
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
