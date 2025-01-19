import express, { Express, Request, Response } from "express";
const { DataTypes, Model } = require('sequelize');
import dotenv from "dotenv";
const {OAuth2Client} = require('google-auth-library');
const jwt = require('jsonwebtoken');
import { sequelize } from './config/database';
import UserDb from './models/db/user';
import MoneyOperationDb from './models/db/money-operations';

dotenv.config();
const app: Express = express();
app.use(express.json())
const port = process.env.PORT || 3000;

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

app.post('/v1/auth/google/signin', async (req: any, res: any) => {
    const { idToken, refreshToken } = req.body;

    if (!idToken || !refreshToken) {
        return res.status(400).json({ error: 'ID token or refresh token is missing' });
    }

    try {
        const client = new OAuth2Client();
        const ticket = await client.verifyIdToken({
            idToken,
            requiredAudience: process.env.GOOGLE_CLIENT_ID!
        });

        const payload = ticket.getPayload();

        if (!payload) {
            return res.status(403).json({ error: 'Invalid token payload' });
        }

        console.log(`User info payload: ${JSON.stringify(payload)}`);

        res.json({
            message: 'Token is valid',
            user: {
                id: payload.sub,
                email: payload.email,
                name: payload.name,
                picture: payload.picture,
            },
        });
    } catch (err) {
        console.error('Token validation error:', err);
        res.status(403).json({ error: 'Invalid or expired token' });
    }
});

app.listen(port, async () => {
    console.log(`[server]: Server is running at http://localhost:${port}`);

    await UserDb.sync({ force: true });
    await MoneyOperationDb.sync({ force: true });
    await sequelize.sync({ force: true });
    console.log('[server]: All models were synchronized successfully.');

    await writeUser();
    readUser();
});