import { Sequelize } from 'sequelize';

// Initialize Sequelize (adjust for your database settings)
export const sequelize = new Sequelize('mydb', 'myuser', 'mypassword', {
  host: 'localhost',
  dialect: 'postgres',
});
