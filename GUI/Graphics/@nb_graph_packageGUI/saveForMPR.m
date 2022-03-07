function saveForMPR(gui,~,~)
% Syntax:
%
% saveForMPR(gui,~,~)
%
% Description:
%
% Part of DAG. Save text, PDFs and Excel file as needed for the MPR report.
% This method constructs and saves in subfolders of the chosen destination.
% Text is written lazily and user is notified what text files were updated.
% <Kapittel X> will be changed to whatever the name of the package is.
%
% Folder structure:
%
% PPR_folder (this is the one you choose)
% |
% |__Kapittel X Norsk
% |         |                                                                                                                               
% |         |_ PDFs
% |         |
% |         |_ Title and source   
% |         |
% |         |_ Tooltip
% |         |
% |         |_ Excel
% |
% |__Kapittel X Engelsk
%           |                 
%           |_ PDFs
%           |
%           |_ Title and source  
%           |
%           |_ Tooltip
% 
% Written by Per Bjarne Bye
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(gui.package.graphs)
        nb_errorWindow('The graph package is empty and cannot be saved.')
        return
    end
    
    % Get the file name
    pathname = uigetdir(nb_getLastFolder(gui));
    
    if isscalar(pathname)
        nb_errorWindow('Invalid save name selected.')
        return
    end
    
    nb_setLastFolder(gui,pathname);
    
    % Prompt user to choose template
    chooseTemplateWindow(gui,@()confirm(gui,pathname));
end

function confirm(gui,pathname)  

    nb_confirmWindow(['Are you sure you want to save the files to ',...
            'the folder ' pathname],@no,@(h,e)yes(h,e,gui,pathname));
end

function no(h,~)
    delete(get(h,'parent'));
end

function yes(h,~,gui,pathname)
 
    % Delete confirmation window
    delete(get(h,'parent'));

    % いいいいいい Make folders いいいいいい   
    
    chapter = gui.packageName;  
    
    % Norsk
    norfolder = [pathname,'\',chapter,' Norsk'];
    if ~exist(norfolder,'dir')
        succ = mkdir(norfolder);
        if ~succ
            nb_errorWindow(['Could not make the folder ' norfolder '.'])
            return
        end
    end
    
    % Engelsk
    engfolder = [pathname,'\',chapter,' Engelsk'];
    if ~exist(engfolder,'dir')
        succ = mkdir(engfolder);
        if ~succ
            nb_errorWindow(['Could not make the folder ' engfolder '.'])
            return
        end
    end    
    
    % PDFs
    pdffolderNor = [norfolder,'\PDFs'];
    if ~exist(pdffolderNor,'dir')
        succ = mkdir(pdffolderNor);
        if ~succ
            nb_errorWindow(['Could not make the folder ' pdffolderNor '.'])
            return
        end
    end
    
    pdffolderEng = [engfolder,'\PDFs'];
    if ~exist(pdffolderEng,'dir')
        succ = mkdir(pdffolderEng);
        if ~succ
            nb_errorWindow(['Could not make the folder ' pdffolderEng '.'])
            return
        end
    end
    
    % PDFs incl. text
    pdfIncFolderNor = [norfolder,'\PDFs incl. text'];
    if ~exist(pdfIncFolderNor,'dir')
        succ = mkdir(pdfIncFolderNor);
        if ~succ
            nb_errorWindow(['Could not make the folder ' pdfIncFolderNor '.'])
            return
        end
    end
    
    pdfIncFolderEng = [engfolder,'\PDFs incl. text'];
    if ~exist(pdfIncFolderEng,'dir')
        succ = mkdir(pdfIncFolderEng);
        if ~succ
            nb_errorWindow(['Could not make the folder ' pdfIncFolderEng '.'])
            return
        end
    end    
    
    % Tekstfiler
    % Check and creation of the textfolders are left to the writeText
    % function.

    % Excel
    exlfolder = [norfolder,'\Excel'];
    if ~exist(exlfolder,'dir')
        succ = mkdir(exlfolder);
        if ~succ
            nb_errorWindow(['Could not make the folder ' exlfolder '.'])
            return
        end
    end
    
    % いいいいいい Save files いいいいいい   

    %%% Write PDF files
    gui.package.writeSeparate(pdffolderNor,'norsk','pdf',[],0,gui.template,true,true,true);
    gui.package.writeSeparate(pdffolderEng,'english','pdf',[],0,gui.template,true,true,true);
    
    %%% Write PDFs incl. text
    gui.package.writeSeparateExtended(pdfIncFolderNor,'norsk','pdf',[],0,true,true);
    gui.package.writeSeparateExtended(pdfIncFolderEng,'english','pdf',[],0,true,true);
   
    %%% Write Text
    gui.package.writeText(norfolder,'norsk',[],true,false,true,true);
    gui.package.writeText(engfolder,'english',[],true,false,true,true);
    
    %%% Write Excel file
    gui.package.saveData([exlfolder,'\MPR_',nb_clock()],'both');
    
end
