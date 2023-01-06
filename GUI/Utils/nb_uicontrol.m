function obj = nb_uicontrol(varargin)
% Syntax:
%
% obj = nb_uicontrol(varargin)
%
% Description:
%
% Prevent edit box from wrapping the text, instead add horizontal  
% scrollbar. It will also only add vertical scrollbar if needed
% 
% Input:
% 
% - See uicontrol
% 
% Output:
% 
% - See uicontrol
%
% Examples:
%
% f  = figure
% ui = nb_uicontrol(...
%        'units','normal',...
%        'position',[0.1,0.1,0.8,0.8],...
%        'style','edit',...
%        'max',3,...
%        'parent',f)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Create a MATLAB uicontrol object
    obj = uicontrol(varargin{:});
    
    % Fix the horizontal scrollbar problem
    try
        if strcmpi(get(obj,'style'),'edit')
            jScrollPane = findjobj(obj);
            set(jScrollPane,'VerticalScrollBarPolicy',20);
            set(jScrollPane,'HorizontalScrollBarPolicy',30);
            jViewPort   = jScrollPane.getViewport;
            jEditbox    = jViewPort.getComponent(0);
            jEditbox.setWrapping(false);  % do *NOT* use set(...)!!!
        end
    catch %#ok<CTCH>
        warning('nb_uicontrol:findjobj','The findjobj method didn''t work. Edit boxed may be little bit hard to read at times.')
    end

end
