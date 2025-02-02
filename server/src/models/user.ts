const { DataTypes, Model, InferAttributes, InferCreationAttributes, CreationOptional } = require('sequelize');
const { sequelize } = require('../config/database');

// @ts-ignore
class User extends Model<InferAttributes<User>, InferCreationAttributes<User>> {
    declare id: string;
    declare google_id: string | null;
    declare google_refresh_token: string | null;
}

User.init(
    {
        id: {
            type: DataTypes.UUID,
            defaultValue: DataTypes.UUIDV4,
            primaryKey: true,
            allowNull: false,
        },
        google_id: {
            type: DataTypes.STRING,
            allowNull: true,
            unique: true,
        },
        google_refresh_token: {
            type: DataTypes.STRING,
            allowNull: true,
            unique: true,
        },
        createdAt: DataTypes.DATE,
        updatedAt: DataTypes.DATE,
    },
    {
        tableName: 'users',
        timestamps: true,
        sequelize
    }
);

export default User;
