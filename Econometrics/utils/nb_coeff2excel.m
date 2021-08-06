function nb_coeff2excel(filename)

    [p,n,e] = fileparts(filename);
    if isempty(p)
        fn = n;
    else
        fn = [p,filesep,n];
    end
    
    l = load(filename);
    c = struct2cell(l);
    f = fieldnames(l);
    d = [f,c];
    xlswrite([fn,'.xlsx'],d);

end
