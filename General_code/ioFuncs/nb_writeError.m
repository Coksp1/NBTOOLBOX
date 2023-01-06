function nb_writeError(Err,fileToWrite,extra)
% Syntax:
%
% nb_writeError(Err,fileToWrite,extra)
%
% Description:
%
% Write error message to file.
% 
% Input:
% 
% - Err         : A MException object.
% 
% - fileToWrite : Either a file identifier or the name of the file to write
%                 the error message to. As a string.
%
% - extra       : A N x M char with extra information on the error. Will
%                 be added first in the report written to the file.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        extra = '';
    end

    doClose = false;
    if ischar(fileToWrite)
        fileToWrite = fopen(fileToWrite,'a');
        doClose     = true;
    end
    if isempty(Err)
        report = [{extra};
                  {'---------------------------------------------------------------------------'};{''}];
    else
        report = getReport(Err,'extended','hyperLinks','off');
        report = regexp(report,'\n','split')';
        if ~isempty(extra)
            report = [{extra};{''};report;
                      {'---------------------------------------------------------------------------'};{''}];
        end
    end
    report = nb_makeWritable(report);
    nb_cellstr2file(report,fileToWrite,true);
    
    if doClose 
        fclose(fileToWrite);
        fclose('all');
    end
    
end
