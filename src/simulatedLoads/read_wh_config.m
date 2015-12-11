function config  = read_wh_config( filename )

if (nargin == 0)
    filename = 'DEWH_para.ini';
end

[ config ] = read_config_file( filename );

if isfield(config, 'S')
    config.Sets = zeros(config.S ,4);
    for s=1:config.S                             %% The detials of each set
        sField = num2str(s, 'S%d');
        config.Sets(s,:) = config.(sField);
        config = rmfield(config,sField);
    end
end

old_key = 'Key_S'; new_key = 'Choose_S';
if isfield(config, old_key)
    config.(new_key) = config.(old_key);
    config = rmfield(config, old_key);
end

end

