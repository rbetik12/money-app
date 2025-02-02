import { sequelize } from './config/database';
import MoneyOperation from './models/money-operations';
import User from './models/user'

export async function updateOrCreateUserOnGoogleSignIn(id: String, refreshToken: String): Promise<User | null> {
    const user: User = await User.findOne({
        where: {
            google_id: id
        }
    });

    if (user !== null) {
        const [affectedRows] = await User.update(
            { google_refresh_token: refreshToken },
            {
                where: { id: user.id },
            }
        );

        if (affectedRows === 0) {
            console.log('No user found to update.');
            return null;
        }

        return await User.findOne({
            where: { id: user.id },
        });
    }
    else {
        const newUser = await User.create({
            google_id: id,
            google_refresh_token: refreshToken
        });

        return newUser;
    }

    return null;
}

export async function addMoneyOperation(op: MoneyOperation): Promise<MoneyOperation | null> {
    try {
        return await MoneyOperation.create(op)
    } catch (e: any) {
        console.error(`Error in creating MoneyOperation: ${e.message}`)
        return null
    }
}

export async function deleteUserCredentails(user: User): Promise<boolean> {
    const [affectedRows] = await User.update(
        {
            google_refresh_token: null
        },
        {
            where: { id: user.id },
        }
    );

    if (affectedRows === 0) {
        console.error('No user found to update credentials.');
        return false;
    }

    return true;
}
