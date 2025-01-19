import express, { Express, Request, Response } from "express";
import dotenv from "dotenv";
const {OAuth2Client} = require('google-auth-library');
const jwt = require('jsonwebtoken');
import { sequelize } from './config/database';
import { deleteUserCredentails, updateOrCreateUserOnGoogleSignIn } from "./db";
import { deserializeToken } from "./utils";

dotenv.config();
const app: Express = express();
app.use(express.json())
const port = process.env.PORT || 3000;

app.post('/v1/auth/signout', async (req: any, res: any) => {
    const { token } = req.body;
    if (!token) {
        return res.status(400).json({ error: 'Token is missing' });
    }

    let payload = deserializeToken(token);
    if (!payload) {
        return res.status(400).json({ error: 'Invalid token' });
    }

    if (!deleteUserCredentails(payload)) {
        return res.status(400).json({ error: 'User was not found' });
    }

    return res.status(200)
});

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

        const user = await updateOrCreateUserOnGoogleSignIn(payload.sub, refreshToken);
        if (user === null) {
            console.error('User retrivieng error');
            return res.status(400).json({ error: 'User retrivieng error' });
        }
        const token = jwt.sign(JSON.stringify(user), process.env.JWT_SECRET!);

        res.send(token);
    } catch (err) {
        console.error('Token validation error:', err);
        res.status(403).json({ error: 'Invalid or expired token' });
    }
});

app.listen(port, async () => {
    console.log(`[server]: Server is running at http://localhost:${port}`);

    await sequelize.sync({ force: false });
});