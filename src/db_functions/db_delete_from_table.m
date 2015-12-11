function [ deleted_ids] = db_delete_from_table( conn, db_table_name, id_column,  id_range )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

if ischar(id_range)
    % number of rows
    sqlQuery =['SELECT COUNT(*) AS count FROM ' db_table_name ' ;'];
    rows1 = fetch(conn, sqlQuery);
    
    % deletion
    sqlQuery = ['DELETE FROM ' db_table_name ' WHERE ' id_column ' ' id_range '; '];
    curs = exec(conn, sqlQuery);
    if (~isempty(curs.Message))
        deleted_ids = 0;
    end
    
    % number of rows
    sqlQuery =['SELECT COUNT(*) AS count FROM ' db_table_name ' ;'];
    rows2 = fetch(conn, sqlQuery);

    % number of rows deleted
    deleted_ids = rows1.count - rows2.count;
else
    if (isnumeric(id_range))
        deleted_ids = length(id_range);
        partialSqlQuery = sprintf('DELETE FROM %s WHERE %s = %%d;', db_table_name, id_column);
        for i = 1:length(id_range)
            sqlQuery = sprintf(partialSqlQuery, id_range(i));
            curs = exec(conn, sqlQuery);
            if (~isempty(curs.Message))
                deleted_ids = deleted_ids - 1;
            end
        end
    end
end


end

