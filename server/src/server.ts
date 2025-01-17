import express, { Express, Request, Response } from "express";
const { DataTypes, Model } = require('sequelize');
import dotenv from "dotenv";
import { sequelize } from './config/database';
import User from './models/user';

dotenv.config();

const app: Express = express();
const port = process.env.PORT || 3000;

app.get("/", (req: Request, res: Response) => {
  res.send("Express + TypeScript Server");
});

app.listen(port, async () => {
  console.log(`[server]: Server is running at http://localhost:${port}`);

  await User.sync({ force: true });
  await sequelize.sync({ force: true });
  console.log('All models were synchronized successfully.');
});