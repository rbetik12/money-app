import User from './models/user'
const jwt = require('jsonwebtoken');

export function deserializeToken(token: String): User | null {
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET!) as User;
        return decoded;
    } catch (error) {
        console.error('Token verification failed:', error);
        return null;
    }
}