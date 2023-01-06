function writeTex(obj,filename,varargin)
% Syntax:
%
% writeTex(obj,filename)
% writeTex(obj,filename,'inputName',inputValue,...)
%
% Description:
%
% Writes the object data to a LaTeX table saved to a .tex file.
%
% If the object consists of more pages (datasets) more tables will
% be created.
%
% Input:
% 
% - obj      : An object of class nb_ts
%
% - filename : The name of the saved .tex file. With or without the
%              extension.
%
% Optional input:
%
% See optional inputs to nb_ts.getCode.
%
% Output:
%
% A saved .tex file with the LaTeX table
%
% Examples:
%
% obj = nb_ts(rand(10,3),'','2012Q1',{'Var1','Var2','Var3'});
% obj.writeTex('test')
%
% See also:
% nb_ts, nb_ts.getCode
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Test the filename input
    %--------------------------------------------------------------
    if ischar(filename)
        
        ind = strfind(filename,'.');
        if isempty(ind)
            filename = [filename,'.tex'];
        else
            if ~strcmpi(filename(ind+1:end),'tex')
                error([mfilename ':: The file extension must be .tex, but is .' filename(ind+1:end)])
            end
        end
        
    else
        error([mfilename ':: The input filename must be a string.'])
    end

    % Get LaTeX code of table
    %--------------------------------------------------------------
    code = obj.getCode(1,varargin{:});
    
    % Write the LaTeX code to the .tex file
    %--------------------------------------------------------------
    writer = fopen(filename,'w+');
    for ii = 1:size(code,1)

        fprintf(writer,strtrim(code(ii,:)));
        
    end
    
    fclose(writer);
    fclose('all');
    
end
