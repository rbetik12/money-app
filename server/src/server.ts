import express, { Express, Request, Response } from "express";
const { DataTypes, Model } = require('sequelize');
import dotenv from "dotenv";
import { sequelize } from './config/database';
import UserDb from './models/db/user';
import MoneyOperationDb from './models/db/money-operations';

dotenv.config();

const app: Express = express();
const port = process.env.PORT || 3000;

app.get("/", (req: Request, res: Response) => {
  res.send("Express + TypeScript Server");
});

const writeUser = async () => {
  try {
    // Create a new user
    const newUser = await UserDb.create({
      email: 'testuser@example.com',
    });

    console.log('User created:', newUser.toJSON());
  } catch (error) {
    console.error('Error creating user:', error);
  }
}

const readUser = async () => {
    try {
        const users = await UserDb.findAll();
        console.log('All users:', users.map(user => user.toJSON()));
    } catch (error) {
        console.error('Error fetching users:', error);
    }
}

app.listen(port, async () => {
  console.log(`[server]: Server is running at http://localhost:${port}`);

  await UserDb.sync({ force: true });
  await MoneyOperationDb.sync({ force: true });
  await sequelize.sync({ force: true });
  console.log('[server]: All models were synchronized successfully.');

  await writeUser();
  readUser();
});