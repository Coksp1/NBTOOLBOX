function message = nb_checkPreFix(postfix)
% Syntax:
%
% message = nb_checkPreFix(postfix)
%
% Description:
%
% Check the prefix for unsupported chars
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    message = '';
    ind     = regexp(postfix,'[!"@#��$%&/()=?`\^~�*-:;�|><{},]','once');
    if ~isempty(ind)
        message = ['Invalid postfix ''' postfix ''' provided. The postfix cannot contain [, !, ", @, #, �, �, $, '...
                   '%, &, /, (, ), =, ?, `, \, ^, ~, �, *, -, :, ;, �, |, >, <, {, }, ], and ,'];
        return
    end
    
    s = str2double(string(1,1));
    if ~isnan(s)
        message = 'The selected prefix cannot start with a number.';
        return
    end
    
end
