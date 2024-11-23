function portraitPDF(filename,append)
% Syntax:
%
% portraitPDF(filename)
%
% Description:
%
% Fit a croped pdf into a A4 sized paged pdf document using LaTeX.  
% 
% Input:
% 
% - filename : A string with the name of the pdf file. With or without 
%              extension.
% 
% - append   : A string with the name of the pdf file to append to. Assumed
%              to be located in the same folder as filename!
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    [p,n,e] = fileparts(filename);
    if ~isempty(e)
        if ~strcmpi(e,'.pdf')
            error([mfilename ':: The provided file must be a PDF'])
        end
    else
        e = '.pdf';
    end
    pdfFile       = [n, e];
    pdfFileForTex = pdfFile;
    
    if ~isempty(p)
        old = cd(p);
    end
    
    code = '\\documentclass{article}\r\n';

    code = char(code,'\\usepackage{graphicx}\r\n');
    code = char(code,'\\usepackage{mathtools}\r\n');
    code = char(code,'\\usepackage{amsmath}\r\n');
    code = char(code,'\\usepackage{amssymb}\r\n');
    code = char(code,'\\usepackage{pifont}\r\n');
    code = char(code,'\\usepackage{fancyvrb}\r\n');
    code = char(code,'\\usepackage{color}\r\n');
    code = char(code,'\\usepackage{algorithm}\r\n');
    code = char(code,'\\usepackage{algorithmic}\r\n');
    code = char(code,'\\usepackage[latin1]{inputenc}\r\n');
    code = char(code,'\\usepackage[english]{babel}\r\n');
    code = char(code,'\\usepackage[T1]{fontenc}\r\n');
    code = char(code,'\\usepackage[margin=0.5in]{geometry}\r\n');

    code = char(code,'\\usepackage{booktabs, multicol, multirow}\r\n');
    code = char(code,'\\usepackage{float}\r\n');
    code = char(code,'\\usepackage{framed,lipsum}\r\n');
    code = char(code,'\\floatstyle{boxed}\r\n');
    code = char(code,'\\restylefloat{table}\r\n');

    code = char(code,'\\begin{document}\r\n');

    code = char(code,'\\pagenumbering{gobble}\r\n');

    code = char(code,'\\begin{figure}[p]\r\n');
    code = char(code,'\\begin{center}\r\n');
    code = char(code,['   \\includegraphics[width=\\textwidth]{' pdfFileForTex '}\r\n']);
    code = char(code,'\\end{center}\r\n');
    code = char(code,'\\end{figure}\r\n');

    code = char(code,'\\end{document}\r\n');

    % Write code to .tex file
    file    = 'temp';
    texFile = 'temp.tex';
    writer  = fopen(texFile,'w+');

    % Write the .tex file used by MixTex
    for ii = 1:size(code,1)
        fprintf(writer,strtrim(code(ii,:)));
    end

    % Close file writer object 
    fclose(writer);
    fclose('all');
    
    % Compile code
    evalc('dos(''pdflatex temp.tex temp.pdf'')');
    if exist('temp.pdf','file') == 0
       error([mfilename ':: Cannot find pdflatex on your computer. You need to install MiKTeX 2.9 or a newer version.']) 
    end
    
    % Delete .tex file and other temporary files
    evalc(['dos(''del ', file ,'.tex'')']);
    evalc(['dos(''del ', file ,'.aux'')']);
    evalc(['dos(''del ', file ,'.log'')']);
    evalc(['dos(''del ', file ,'.nav'')']);
    evalc(['dos(''del ', file ,'.out'')']);
    evalc(['dos(''del ', file ,'.snm'')']);
    evalc(['dos(''del ', file ,'.toc'')']);
    evalc(['dos(''del ', file ,'.bbl'')']);
    evalc(['dos(''del ', file ,'.blg'')']);
    evalc(['dos(''del ', file ,'.tex.bak'')']);

    % Append to existing PDF
    if nargin>1
        
        [~,n,e] = fileparts(append);
        copyfile([n,e],'temp2.pdf','f');
        options = ['-q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOUTPUTFILE="', n,e, '" -f "temp2.pdf" "temp.pdf"'];
        try
            % Convert to pdf using ghostscript
            [status, message] = ghostscript(options);
        catch Err
            rethrow(Err);
        end
        
        if status
            error([mfilename ':: Error while using ghostscript:: ' message])
        end
        
        % Delete temporary pdf files
        dos('del temp2.pdf');
        dos('del temp.pdf');
        
    else
        % Delete old pdf and rename new
        dos(['del ' pdfFile]);
        movefile([file,'.pdf'],pdfFile,'f');
    end
    
    if ~isempty(p)
        cd(old);
    end
        
end
