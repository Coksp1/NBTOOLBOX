function nb_startup(type,silent)
% Syntax:
%
% nb_startup(type,silent)
%
% Description:
%
% Start up function of the NB toolbox.
%
% Input:
%
% - type        : With this input you can specify which
%                 functionalities you want
%
%                 'all'      : Add all the functionalities.
%
%                 'dg'       : Only add the data managment and graphics 
%                              functions and classes.
%
%                 'full'     : Will add all the functionalities of the
%                              toolbox except the GUI part. 
%
%                 'g'        : Only add the basic plot functions and
%                              classes.
%
%                 'gui'      : Add all the functionalities. Same as 'all'.
%
% - silent      : If you give 'silent' it will not print anything
%                 on the screen.
%
% Output:
%
% - All the wanted function and classes added to the MATLAB path.
%
% Examples:
%
% nb_startup
% nb_startup('fg')
% nb_startup('full','silent')
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        silent = '';
        if nargin < 1
            type = 'all';
        end
    end

    warning('off','MATLAB:handle_graphics:Canvas:RenderingException');
    
    % Get the rest
    environment = mfilename('fullpath');
    ind         = strfind(environment,filesep);
    environment = environment(1:ind(end)-1);
    switch lower(type)
        
        case {'all','gui'}

            allFolders = {''};
            allFolders = [allFolders getBasicGraphics()];
            allFolders = [allFolders getOverheadGraphicsAndDataManagement()];
            allFolders = [allFolders getFullfill()];
            allFolders = [allFolders getGUI()];
            allFolders = strcat(environment,allFolders);
            
        case 'full'

            allFolders = {''};
            allFolders = [allFolders getBasicGraphics()];
            allFolders = [allFolders getOverheadGraphicsAndDataManagement()];
            allFolders = [allFolders getFullfill()];
            allFolders = strcat(environment,allFolders);
        
        case 'g'

            allFolders = {''};
            allFolders = [allFolders getBasicGraphics()];
            allFolders = strcat(environment,allFolders);

        case 'dg'

            allFolders = {''};
            allFolders = [allFolders getBasicGraphics()];
            allFolders = [allFolders getOverheadGraphicsAndDataManagement()];
            allFolders = strcat(environment,allFolders);   
            
        otherwise

            error([mfilename ':: The type input cannot take the value' type])
    end

    % Add all the folders to the MATLAB search path
    nb_addpath(allFolders);

    % Turn off some warnings
    warning('off','MATLAB:Figure:SetPosition');
    warning('off','MATLAB:Figure:SetOuterPosition');
    
    if ~strcmpi(silent,'silent')
        disp('============================================================================')
        disp('NB Toolbox version 1.0')
        disp('============================================================================')
        disp(' ')
        if strcmpi(type,'gui')
            disp('You have successfully added NB toolbox, you can start up')
            disp('DAG by writing nb_GUI in the command window.')
        else
            disp('You have successfully added NB toolbox.')
        end
        disp(' ')
        disp('Documentation can be found here:')
        disp([' ' environment '\Documentation\DAG.pdf'])
        disp([' ' environment '\Documentation\NB Toolbox.pdf'])
        disp(' ')
        disp('Examples can be found here:')
        disp([' ' environment '\Examples'])
        disp(' ')
        disp('If you have problems with the code or discover any bugs you can contact ')
        disp('Kenneth Sæterhagen Paulsen (kennethspaulsen@yahoo.com)')
        disp(' ')
        disp('============================================================================')
    end

end

%------------------------------------------------------------------
% Sub function for adding sub folders to a cellstr array
%------------------------------------------------------------------
function allFolders = addSubFolders(folders,allFolders)

    for ii = 1:size(folders,2)
            
        s          = dir(folders{ii});
        f          = {s.name};
        ind1       = nb_contains(f,'.');
        ind2       = nb_contains(f,'@');
        ind3       = nb_contains(f,'+');
        ind4       = nb_contains(f,'private');
        f          = f(ind1 & ind2 & ind3 & ind4);
        f          = strcat([folders{ii} '\'],f);
        allFolders = [allFolders f]; %#ok
        if ~isempty(f) 
            allFolders = addSubFolders(f,allFolders);
        end
        
    end

end

function folders = getBasicGraphics()

    folders = {'\Graphics\Graphics\Utils',...
               '\Graphics\Graphics\Basic',...
               '\Graphics\Graphics\Basic\EditCallbackClasses'};

end

function folders = getOverheadGraphicsAndDataManagement()

    folders = {'\DataManagement',...
               '\DatesCode',...
               '\General_code\cellFuncs',...
               '\General_code\charFuncs',...
               '\General_code\classes',...
               '\General_code\doubleFuncs',...
               '\General_code\ioFuncs',...
               '\General_code\otherFuncs',...
               '\General_code\structFuncs',...
               '\Graphics\Graphics\Overhead',...
               '\Graphics\Export_fig'};

end

function folders = getFullfill()

    folders = {'\Econometrics',...
               '\Econometrics\calendars',...
               '\Econometrics\diagnostics',...
               '\Econometrics\distributions',...
               '\Econometrics\estimation',...
               '\Econometrics\estimation\estimators',...
               '\Econometrics\forecasting',...
               '\Econometrics\models',...
               '\Econometrics\parallel',...
               '\Econometrics\utils',...
               '\Econometrics\solvers',...
               '\Econometrics\optimizers',...
               '\GUI\Utils'};
    
end

function folders = getGUI()

    folders = {'\GUI',...
               '\GUI\Data',...
               '\GUI\Data\DataMethods',...
               '\GUI\Graphics',...
               '\GUI\Others',...
               '\GUI\Pictures'};

end