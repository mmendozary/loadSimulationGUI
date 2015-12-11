function readings = db_get_whunit_reading(unitID)
%Set preferences with setdbprefs.
setdbprefs('DataReturnFormat', 'dataset');
setdbprefs('NullNumberRead', 'NaN');
setdbprefs('NullStringRead', 'null');


%Make connection to database.  Note that the password has been omitted.
%Using JDBC driver.
conn = database('WaterHeaters', 'sw_waterheaters', 'unb.sql.2015', 'Vendor', 'MICROSOFT SQL SERVER', 'Server', '131.202.14.241', 'PortNumber', 1433, 'AuthType', 'Server');

%Read data from database.
readings = fetch(conn, ['SELECT 	Readings.dt'...
    ' ,	Readings.WaterFlowRate_Q AS Q'...
    ' ,	Readings.WaterTemperature_T AS T'...
    ' ,	Readings.InputPower AS P'...
    ' FROM 	 ( WaterHeaters.Simulation.Readings '...
    ' INNER JOIN WaterHeaters.Simulation.WaterHeaters '...
    ' ON 	Readings.WaterHeaterID = WaterHeaters.WaterHeaterID )'...
    ' WHERE 	Readings.WaterHeaterID = ' num2str(unitID,'%d')]);

% curs = fetch(curs);
% close(curs);
% 
% %Assign data to output variable
% readings = curs.Data;
readings.Properties.Units = {'time','m^3/sec','^oC','Watt'}
%Close database connection.
close(conn);

%Clear variables
clear curs conn