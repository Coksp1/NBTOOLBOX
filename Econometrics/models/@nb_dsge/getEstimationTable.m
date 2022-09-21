function latexTable = getEstimationTable(obj,varargin)
% Syntax:
%
% latexTable = getEstimationTable(obj)
% latexTable = getEstimationTable(obj,'preamble',false)
%
% Description:
%
% Get latex table of estimated parameters.
% 
% Input:
% 
% - obj         : A nb_dsge object.
% 
% % Optional input:
%
% - 'preamble'  : Give 0 if you don't want to include the preamble in the 
%                 returned output. Default is to include the preamble,  
%                 i.e. 1.
%
% - 'filename'  : Provide a file name to write the latex code to tex file.
%
% - 'writePDF'  : Give true (1) to write PDF using pdflatex. In this case
%                 the tex file is deleted! 'preamble' must be set to true 
%                 in this case! 
%
% - 'precision' : Default is '%8.2f'. For more see second input to num2str.
%
% - 'lookUp'    : Either a N x 3 cell array, or a file that can be run
%                 by eval to create a variable lookUp that is a N x 3
%                 cell array. The first column must list the names of the
%                 estimated parameters, the second column the latex name,
%                 and the third the description of the estimated parameter.
%
%                 Caution: The latex name is enclosed in $$, i.e. 
%                          interpreted in math mode, but description is
%                          not!
%
% Output:
% 
% - latexTable : A one line char with the latex table code.
%
% See also:
% num2str
%
% Written by Kenneth Sæterhagen Paulsen
% Inspired by code written by Thor Andreas Aursland

% Copyright (c)  2019, Norges Bank

    if ~isscalar(obj)
        error('The input obj must be scalar nb_dsge object.')
    end
    if ~isestimated(obj)
        error('The input object is not estimated.')
    end
    
    [preamble,varargin]  = nb_parseOneOptional('preamble',true,varargin{:});
    [filename,varargin]  = nb_parseOneOptional('filename','',varargin{:});
    [precision,varargin] = nb_parseOneOptional('precision',[],varargin{:});
    [lookUp,varargin]    = nb_parseOneOptional('lookUp',{},varargin{:});
    if nb_isOneLineChar(lookUp)
        eval(lookUp);
        if ~iscell(lookUp)
            error(['When ''lookUp'' is a one line char the script must ',...
                   'return a variable lookUp that is a cell with 3 columns.']);
        end
        if size(lookUp,2) ~= 3
            error(['When ''lookUp'' is a one line char the script must ',...
                   'return a variable lookUp that is a cell with 3 columns.']);
        end
    elseif ~iscell(lookUp)
        error('The ''lookUp'' input must be a cell with 3 columns.');
    else
        if size(lookUp,2) ~= 3
            error('The ''lookUp'' input must be a cell with 3 columns.');
        end
    end
    if isempty(precision)
        precision = '%8.2f';
    else
        if ~ischar(precision)
            error([mfilename ':: The precision input must be of the type %8.6f.'])
        end
        precision(isspace(precision)) = '';
        if ~strncmp(precision(1),'%',1)||~all(isstrprop(precision([2,4]),'digit'))||...
           ~isstrprop(precision(end),'alpha')
            error([mfilename ':: The precision input must be of the type %8.6f.'])
        end
    end
    
    paramNames = obj.parameters.name(obj.results.estimationIndex);
    paramMode  = obj.results.beta(obj.results.estimationIndex);
    paramStd   = obj.results.stdBeta;
    priorInfo  = obj.estOptions.prior;
    nParam     = length(paramNames);

    % Get start part of latex code.
    if preamble
        start = [  ...
                    '\\documentclass{article} \r\n' ...
                    '\\usepackage{booktabs} \r\n' ...
                    '\\usepackage{multirow} \r\n' ...
                    '\\begin{document}  \r\n' ...
                ];
    else
        start = '';
    end
    
    start = [start,  ...
                '\\begin{tabular}{l l c c c c c} \r\n' ...
                '\\multicolumn{1}{l}{} & \\multicolumn{1}{l}{} & \\multicolumn{3}{c}{Prior} & \\multicolumn{2}{c}{Posterior} \\\\ \r\n' ...
                '\\cmidrule(lr){3-5} \\cmidrule(lr){6-7} \r\n' ...
                'Param. & Descr. & Distr. & Mean & S.d. & Mode & Std. Err. \\\\ \r\n' ...
                '\\midrule \\\\  \r\n' ...
            ];

    % Get all rows of estimated parameters    
    latexTable = cell(1,nParam);
    for ii = 1:nParam
        
        % Get prior mean and std
        priorFunc = func2str(priorInfo{ii,3});
        if strcmpi(priorFunc,'nb_distribution.truncated_pdf')
            priorShape  = priorInfo{ii,4}{1,1};
            priorName   = priorShape;
            priorParams = priorInfo{ii,4}{1,2};
            lb          = priorInfo{ii,4}{1,3};
            ub          = priorInfo{ii,4}{1,4};
            if ~isempty(ub) || ~isempty(lb)
               priorName = [priorName, '[' num2str(lb) ',' num2str(ub) ']']; %#ok<AGROW>
           end
        else
            priorFunc   = strrep(priorFunc,'nb_distribution.','');
            priorShape  = strrep(priorFunc,'_pdf','');
            priorName   = priorShape;
            priorParams = priorInfo{ii,4};
            lb          = [];
            ub          = [];
        end
        temp_distribution = nb_distribution('type',       priorShape,...
                                            'parameters', priorParams,...
                                            'lowerBound', lb,...
                                            'upperBound', ub);
        priorMean = mean(temp_distribution);
        priorStd  = std(temp_distribution);

        % Look up latex name and description
        name = paramNames{ii};
        desc = '-empty-';
        if ~isempty(lookUp)
            loc = find(strcmp(paramNames{ii},lookUp(:,1)));
            if ~isempty(loc)
                name = strrep(lookUp{loc,2},'\','\\');
                desc = strrep(lookUp{loc,3},'\','\\');
            end
        end
        
        % Create row of this parameter in the table
        temp_row = ['$' name '$' ...
                    ' & ' desc ' ' ...
                    ' & $' priorName '$' ...
                    ' & $' num2str(priorMean,precision) '$' ...
                    ' & $' num2str(priorStd,precision) '$' ... 
                    ' & $' num2str(paramMode(ii,1),precision) '$' ...
                    ' & $' num2str(paramStd(ii,1),precision) '$ \\\\ \r\n'];

        latexTable{ii} = temp_row;

    end

    % Put all together
    latexTable = strcat(latexTable{:});
    latexTable = [start, latexTable, '\\end{tabular} \r\n']; 
    if preamble
        latexTable = [latexTable, '\r\n\\end{document}'];
    end

    % Write tex file
    if ~isempty(filename)
        
        writePDF = nb_parseOneOptional('writePDF',false,varargin{:});
        if writePDF 
            if ~preamble
                error('If you set ''writePDF'' to true, ''preamble'' must also be set to true!')
            end
        end
        
        [p,filename] = fileparts(filename);
        if ~isempty(p)
            filename = strcat(p,filesep,filename);
        end
        writer = fopen([filename '.tex'],'w+');
        fprintf(writer,latexTable);

        % Close file writer object 
        fclose(writer);
        fclose('all');
        close all
        
        if writePDF
           
            % Write to pdf
            dos(['pdflatex ' filename '.tex ' filename '.pdf']);

            % Delete .tex file and other temporary files
            dos(['del ' filename '.tex']);
            dos(['del ' filename '.aux']);
            dos(['del ' filename '.log']);
            dos(['del ' filename '.nav']);
            dos(['del ' filename '.out']);
            dos(['del ' filename '.snm']);
            dos(['del ' filename '.toc']);
            
        end
    
    end
    
    
    
end