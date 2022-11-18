function defaultColors = nb_defaultColors(number,isNB)
% Syntax:
%
% defaultColors = nb_defaultColors()
% defaultColors = nb_defaultColors(number,isNB)
%
% Description:
%
% Gets the default colors used by the NB toolbox.
%
% To change the default colors set the environment variable 'defaultColors' 
% to the name of a .m file (fully specified path!) that creates a variable 
% defaultColors. This variable must havae size N x 3, and be a double 
% array.
%
% Example;
% setenv('C:\yourDefaultColors.m')
% 
% Where the file is on the format;
%
% defaultColors = [
%   0,  0,  0; 
%   0.8,0.8,0.8
% ];
%
% Output:
% 
% defaultColors : A n x 3 double with the RGB colors.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c)  2019, Norges Bank

    if nargin < 2
        isNB = false;
        if nargin < 1
            number = [];
        end
    end

    file = getenv('defaultColors');
    if isempty(file)
    
        defaultColors = [[34 89 120]/255;   % Deep blue
                         [205 140 65]/255;  % Orange
                         [150 90 150]/255;  % Purple
                         [120 165 125]/255; % Green
                         [221 34 45]/255;   % Red
                         [73 180 223]/255;  % Light blue
                         [195 185 150]/255; % Sand
                         [176 222 241]/255; % Wate blue
                         [164 172 177]/255; % Cool grey
                         [0 125 130]/255;   % Turquoise
                         [180 115 150]/255; % Pink
                         [0 0 0]/255;       % Black
                         [245 239 5]/255;   % Yellow
                         [128 0 64]/255;    % Burgundy
                         [129 179 0]/255;   % Dark green
                         [0,184,128]/255;   % Turquise
                         [243,128,102]/255; % Deep pink
                         [255,210,0]/255;   % Light orange
                         [128, 0,0]/255;    % Dark red
                         [57 129 0]/255;    % Light green
                         [230,60, 128]/255; % Pink
                         [102,77,51]/255;   % Brown
                         [77,77,77]/255;    % Dark grey
                         [200 110 200]/255; % Light Purple
                         [230,102,25]/255;  % Orange/Red
                         [89,225,45]/255;   % Turquise/Green
                         [77,128,77]/255;   % Sea green
                         [90 114 166]/255;  % Blue
                         [211,203,0]/255;   % Mustard
                         ];
                     
    else
        [p,~,e] = fileparts(file);
        if isempty(p)
            error(['The file stored in the environment variable ''defaultColors''',...
                   ' is not a fully specified path; ' file]);
        end
        if ~strcmpi(e,'.m')
            error(['The file stored in the environment variable ''defaultColors''',...
                   ' must include extension .m; ' file]);
        end
        try
            run(file)
        catch Err
            nb_error(['The file stored in the environment variable ',...
                '''defaultColors'' produced an error;'],Err)
        end
        if ~exist('defaultColors','var') 
            error(['The file stored in the environment variable ''defaultColors''',...
                   ' did not create a variable defaultColors; ' file]);
        end
        if ~isnumeric(defaultColors)
            error(['The file stored in the environment variable ''defaultColors''',...
                   ' did not create a variable defaultColors that is a double; ' file]);
        end
        if size(defaultColors,2) ~= 3
            error(['The file stored in the environment variable ''defaultColors''',...
                   ' did not create a variable defaultColors with 3 columns with',...
                   ' the RGB codes; ' file]);
        end
        if any(defaultColors(:) < 0) || any(defaultColors(:) > 1)
            error(['The file stored in the environment variable ''defaultColors''',...
                   ' did not create a variable defaultColors with only numbers',...
                   ' between 0 and 1; ' file]);
        end
        
    end
                 
    if isempty(number)
        number = size(defaultColors,1);
    end                   
    rep           = ceil(number/size(defaultColors,1));
    defaultColors = repmat(defaultColors,[rep,1,1]);
    defaultColors = defaultColors(1:number,:);   
    
    if isNB
        old           = defaultColors;
        defaultColors = cell(number,1);
        for ii = 1:min(8,number)
            defaultColors{ii} = ['nbcolor', int2str(ii)]; 
        end
        for ii = 9:length(defaultColors)
            defaultColors{ii} = old(ii,:);
        end
    end
        
end
