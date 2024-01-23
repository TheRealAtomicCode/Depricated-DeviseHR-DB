const fs = require('fs');
const { Pool } = require('pg');

const sqlFilePaths = [
  // ! scripts and types
  './Database/Scripts/drop_scripts.sql',
  // ! tables
  './Database/Models/Types.sql',
  './Database/Models/Operators.sql',
  './Database/Models/Notes.sql',
  './Database/Models/Companies.sql',
  './Database/Models/Roles.sql',
  './Database/Models/Users.sql',
  './Database/Models/Hierarchies.sql',
  './Database/Models/Absence_Types.sql',
  './Database/Models/Working_Patterns.sql',
  './Database/Models/Contracts.sql',
  './Database/Models/Discarded_Contracts.sql',
  './Database/Models/Absences.sql',
  './Database/Models/Terms.sql',
  // ! functions
  './Database/Functions/edit_user_roles.sql',
  './Database/Functions/edit_subordinates.sql',
  './Database/Functions/update_last_contract_end_date.sql',
  // './Database/Functions/add_absence.sql',
  // ! triggers
  './Database/Triggers/update_previous_contract_end_date_on_insert.sql',
  './Database/Triggers/check_leave_duration.sql',
  // ! final scripts
  './Database/Scripts/insert_absence_types.sql',
]; // Replace with the paths to your SQL files

const connectionString =
  'postgres://postgres:890899000@localhost:5432/DeviseHR'; // Replace with your PostgreSQL connection details

const pool = new Pool({
  connectionString: connectionString,
});

async function runSqlFiles(filePaths) {
  try {
    const client = await pool.connect();

    for (const filePath of filePaths) {
      const sql = fs.readFileSync(filePath, 'utf8');
      await client.query(sql);
      console.log(`SQL file ${filePath} executed successfully.`);
    }

    client.release();
    console.log('All SQL files executed successfully.');
  } catch (error) {
    console.error('Error executing SQL files:', error);
  } finally {
    pool.end(); // Close the connection pool
  }
}

runSqlFiles(sqlFilePaths);
