function [LocationTable] = db_get_locations( conn )
%DB_GET_LOCATIONS Retrieves information on the locations already stored and
% configured in the database
% called as 
% [LocationTable] = DB_GET_LOCATIONS(  SQLConnection ); 
%  %
% Example 
%  Make connection to database.  Note that the password has been omitted.
%  Using JDBC driver.
%
%  SQLConnection = DATABASE('powerMeters', 'sql_user', '', ...
%     'Vendor', 'Microsoft SQL Server', 'AuthType', 'Server', ...
%     'Server', 'livingLabLM.ad.unb.ca', ...
%     'PortNumber', 1433);
%
%
%  LocationTable  = DB_GET_LOCATIONS( SQLConnection  );
%  % print addres and view in a web browser the first location in table
%   fprintf('%s\n', LocationTable.LocationAddress{1})
%   web(LocationTable.urlGoogleMaps{1})
%
%


% Julian Cardenas 2015

LocationTable = [];  

narginchk(1,1); % one or two function parameters required 

if ~isconnection(conn)
    err = MException('DB:connectionError', 'Invalid db connection.');
    throw(err);
end
sqlQuery = ['SELECT * FROM INFORMATION_SCHEMA.TABLES ' ... 
    ' WHERE TABLE_NAME = ''Locations'' '];
try
    db_specs = fetch(conn, sqlQuery);
    db_name = char(db_specs.TABLE_CATALOG);
    schema_name = char(db_specs.TABLE_SCHEMA);
catch e
    e.message
    e.stack
end
sqlQuery = sprintf([...
    'SELECT 	Locations.LocationID as Id'...
    ' ,	Locations.LocationAddress'...
    ' ,	Locations.Latitude'...
    ' ,	Locations.Longitude'...
    ' ,	Locations.ts as Created'...
    ' ,	Locations.GeographyPoint'...
    ' ,	Locations.urlGoogleMaps'...
    ' FROM 	[%s].[%s].[Locations] '],db_name, schema_name);
try
    LocationTable = fetch(conn, sqlQuery);
        
catch e
    e.message
    e.stack
end


end