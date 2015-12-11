function unitIDs = db_get_wh_unitIds
%Set preferences with setdbprefs.
setdbprefs('DataReturnFormat', 'numeric');
setdbprefs('NullNumberRead', 'NaN');
setdbprefs('NullStringRead', 'null');


%Make connection to database.  Note that the password has been omitted.
%Using JDBC driver.
conn = database('WaterHeaters', 'sw_waterheaters', 'unb.sql.2015', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', '131.202.14.241', 'PortNumber', 1433, 'AuthType', 'Server');

%Read data from database.
unitIDs = fetch(conn, ['SELECT 	WaterHeaters.WaterHeaterID'...
    ' FROM 	WaterHeaters.Simulation.WaterHeaters ']);

% curs = fetch(curs);
% close(curs);
% 
% %Assign data to output variable
% unitIDs = curs.Data;

%Close database connection.
close(conn);

%Clear variables
clear curs conn