const bcrypt = require('bcrypt');
const Client = require('pg').Client;

async function seed() {
  async function hashPassword(password) {
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);
    return hashedPassword;
  }

  const firstName = 'Sudo';
  const lastName = 'User';
  const email = 'sudo@devisehr.com';
  const plainPassword = 'password123'; // Replace with the actual plain password

  const hashedPassword = await hashPassword(plainPassword);

  const user = {
    first_name: firstName,
    last_name: lastName,
    email: email,
    password_hash: hashedPassword,
    is_terminated: false,
    user_role: 1,
    // Other user data...
  };

  const client = new Client({
    user: 'postgres',
    host: 'localhost',
    database: 'DeviseHR',
    password: '890899000',
    port: 5432,
  });
  client.connect();
  async function insertUser(user) {
    try {
      const opquery = `
      INSERT INTO Operators (first_name, last_name, email, password_hash, profile_picture, is_terminated, user_type, refresh_tokens, is_verified, added_by)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
    `;

      const opvalues = [
        user.first_name,
        user.last_name,
        user.email,
        user.password_hash,
        user.profile_picture,
        user.is_terminated,
        user.user_role,
        user.refresh_tokens,
        true,
        1,
      ];

      await client.query(opquery, opvalues);

      const companiesquery = `
  INSERT INTO companies (name, licence_number, phone_number, expiration_date, added_by_operator, max_users_allowed, account_number, annual_leave_start_date)
  VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
  RETURNING id;
`;

      const companyValues = [
        'DeviseHR',
        '222222',
        '2222222',
        '2024-12-31T23:59:59Z',
        1,
        20,
        '22222',
        '1970-01-01',
      ];

      const company2Values = [
        'DeviseMD',
        '222221',
        '2222223',
        '2024-12-31T23:59:59Z',
        1,
        20,
        '22221',
        '1970-01-01',
      ];

      const { rows } = await client.query(
        companiesquery,
        companyValues
      );
      let companyId = rows[ 0 ].id;

      const userQuery = `
  INSERT INTO users (first_name, last_name, email, added_by_user, added_by_operator, user_type, password_hash, is_verified, company_id, annual_leave_start_date)
  VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10);
`;

      const userValues = [
        'user1',
        'HR',
        'user1@devisehr.com',
        20,
        1,
        1,
        hashedPassword,
        true,
        companyId,
        '1970-01-01',
      ];

      await client.query(userQuery, userValues);
      console.log('User inserted successfully 1 company 1.');

      const user2Query = `
  INSERT INTO users (first_name, last_name, email, added_by_user, added_by_operator, user_type, password_hash, is_verified, company_id, annual_leave_start_date)
  VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10);
`;

      const user2Values = [
        'user2',
        'hr',
        'user2@devisehr.com',
        20,
        1,
        1,
        hashedPassword,
        true,
        companyId,
        '1970-01-01',
      ];

      await client.query(user2Query, user2Values);
      console.log('User inserted successfully 2 company 2.');

      const roo = await client.query(companiesquery, company2Values);

      companyId = roo.rows[ 0 ].id;

      const user3Query = `
  INSERT INTO users (first_name, last_name, email, added_by_user, added_by_operator, user_type, password_hash, is_verified, company_id, annual_leave_start_date)
  VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10);
`;

      const user3Values = [
        'user1',
        'md',
        'user3@devisehr.com',
        20,
        1,
        1,
        hashedPassword,
        true,
        companyId,
        '1970-01-01',
      ];

      await client.query(user3Query, user3Values);
      console.log('User inserted successfully 3 company 3.');

      const user4Query = `
      INSERT INTO users (first_name, last_name, email, added_by_user, added_by_operator, user_type, password_hash, is_verified, company_id, annual_leave_start_date)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10);
    `;

      const user4Values = [
        'user2',
        'md',
        'user4@devisehr.com',
        20,
        1,
        1,
        hashedPassword,
        true,
        companyId,
        '1970-01-01',
      ];

      await client.query(user4Query, user4Values);
      console.log('User inserted successfully 3 company 3.');
    } catch (error) {
      console.error('Error inserting user:', error);
    } finally {
      client.end();
    }
  }

  // Call the insertUser function with the prepared user object
  insertUser(user);
}

seed();
