function [ insertion_keys ] = db_insert_into_table( conn, db_table_name, db_column_specs)
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here
insertion_keys = 0;

tableContents = struct2dataset(db_column_specs);
[num_of_rows, num_of_columns] = size(tableContents);

% construct the SQL INSERT INTO statement
db_column_names = get(tableContents,'VarNames');
sqlInsertQuery = ['INSERT INTO [', db_table_name, '] (', strjoin(db_column_names, ', '), ') VALUES '];

% sending several values at a time has ea limit (1000in MSSQL). So let's
% divide the number of entries to avoid errors from the server
maxNumRows = 500;
nBlocks = floor(num_of_rows / maxNumRows);
remainder = num_of_rows - (nBlocks * maxNumRows);

if (nBlocks > 0)
    sqlValuesEntries = cell(1,maxNumRows);
end
first_key = 0;
for i =1:nBlocks
    for j = 1:maxNumRows
        index = (i-1)*maxNumRows + j;
        valuesString =  toString(tableContents(index,:), num_of_columns);
        sqlValuesEntries{j} = ['(', strjoin(valuesString, ', '), ')'];
    end
    
    sqlQuery = [ sqlInsertQuery strjoin(sqlValuesEntries, ', ')];
    
    last_key = insertSql(conn, sqlQuery);
    if (first_key == 0)
        first_key = last_key - maxNumRows +1;
    end
    
end

if (remainder > 0)
    sqlValuesEntries = cell(1,remainder);
    for j =1:remainder
        index = nBlocks + j;
        valuesString =  toString(tableContents(index,:), num_of_columns);
        sqlValuesEntries{j} = ['(', strjoin(valuesString, ', '), ')'];
    end
    sqlQuery = [ sqlInsertQuery strjoin(sqlValuesEntries, ', ')];
    last_key = insertSql(conn, sqlQuery);
    if (first_key == 0)
        first_key = last_key - remainder + 1;
    end
end
insertion_keys = (first_key:last_key)';
end

function valuesString =  toString(db_column_values, n)
valuesString = cell(1,n);
for i = 1:n
    thisValue = db_column_values{1,i};
    if ischar(thisValue)
        fmtstr = ['''' '%s' ''''];
    else
        fmtstr = '%d';
        if ((thisValue - fix(thisValue)) ~= 0)
            fmtstr = '%f';
        end
    end
    valuesString{i} = sprintf(fmtstr,thisValue);
end % for
end

function insertion_keys = insertSql(conn, sqlQuery)
% insert data
    curs = exec(conn, sqlQuery);
    if (~isempty(curs.Message))
        error(curs.Message);
    end
    results = fetch(conn, 'SELECT SCOPE_IDENTITY() AS [key]');
    insertion_keys = results.key;
end