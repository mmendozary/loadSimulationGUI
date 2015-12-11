function [ config ] = read_config_file( filename )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
ini = IniConfig();
ini.ReadFile(filename);

sections = ini.GetSections();
config = struct;
for i = 1:ini.count_sections
    [keys, count_keys] = ini.GetKeys(sections{i});
    for j = 1:count_keys
       config.(keys{j}) = ini.GetValues(sections{i}, keys{j});
    end
end

end

