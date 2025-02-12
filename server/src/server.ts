import express, { Express, Request, Response } from "express";
import dotenv from "dotenv";
const {OAuth2Client} = require('google-auth-library');
const jwt = require('jsonwebtoken');
import OpenAI from "openai";
import { v4 as uuidv4 } from "uuid";

import { sequelize } from './config/database';
import { addMoneyOperation, deleteUserCredentails, updateOrCreateUserOnGoogleSignIn } from "./db";
import { deserializeToken } from "./utils";
import MoneyOperation from "./models/money-operations";
import User from "./models/user";

dotenv.config();
const app: Express = express();
app.use(express.json())
const port = process.env.PORT || 3000;

const openai = new OpenAI({
    apiKey: process.env.OPENAI_KEY,
});

const parseToken = (token: string): User | null  => {
    if (!token) {
        console.error('Token is missing')
        return null;
    }

    let payload = deserializeToken(token);
    if (!payload) {
        console.error('Invalid payload')
        return null;
    }

    return payload;
}

app.post('/v1/data/money-operation', async (req: any, res: any) => {
    console.debug(req.body)
    let request = req.body
    const token = req.body.token;

    console.debug(token)
    let payload = parseToken(token);

    if (!payload) {
        return res.status(403).json({ error: 'Invalid token' });
    }

    let op = new MoneyOperation()
    op.id = request["id"]
    op.currency = request["currency"]
    op.amount = Number(request["amount"])
    op.description = request["description"]
    op.category = request["category"]
    op.date = request["date"]
    op.isExpense = request["isExpense"] == "true"
    op.userId = payload.id

    let moneyOp = await addMoneyOperation(op);
    if (moneyOp === null) {
        console.error('Creating money op error');
        return res.status(400).json({ error: 'Creating money op error' });
    }
})

app.post('/v1/data/money-operation-text', async (req: any, res: any) => {
    let request = req.body
    const token = req.body.token;
    let payload = parseToken(token);

    if (!payload) {
        return res.status(403).json({ error: 'Invalid token' });
    }

    let prompt = request["text"]

    try {
        const completion = await openai.chat.completions.create({
            model: "gpt-4o-mini",
            messages: [
                { role: "system", content: "Extract spend category type (Food, Transport, Shopping, Service, Restaraunt), amount of money that was spent to it, description of the expense (if given), in which currency it was given (if no currency were given use RSD as default) or income description, category (salary, dividend) from the given text and return it as a JSON. JSON must not be formatted for markdown, just pure JSON. JSON must contain only array or operations, don't split them on income and expense or any other categories. Income or expense must be marked with isExpense field." },
                { role: "user", content: prompt },
            ],
            store: true,
        });

        const moneyOperationsRaw = JSON.parse(completion.choices[0]?.message?.content!);
        console.debug(completion.choices[0]?.message?.content!);
        let moneyOperations : MoneyOperation[] = []
        moneyOperationsRaw.forEach((element: any) => {
            let op = new MoneyOperation()
            op.id = uuidv4();
            op.currency = element["currency"]
            op.amount = element["amount"]
            op.description = element["description"]
            op.category = element["category"]
            op.date = request["date"]
            op.isExpense = element["isExpense"] == true
            op.userId = payload.id

            moneyOperations.push(op);
        });

        for (let i = 0; i < moneyOperations.length; i++) {
            console.log(moneyOperations[i]);
            let moneyOp = await addMoneyOperation(moneyOperations[i]);
            if (moneyOp === null) {
                console.error('Creating money op error');
            }
        }

        return res.status(200).json(moneyOperations);
    } catch (err) {
        console.error('gpt error:', err);
        res.status(400).json({ error: err });
    }
})

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
    await sequelize.sync({ force: false });

    console.log(`[server]: Server is running at http://localhost:${port}`);
});