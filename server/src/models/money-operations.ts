import User from "./user";

const { DataTypes, Model, InferAttributes, InferCreationAttributes, CreationOptional } = require('sequelize');
const { sequelize } = require('../config/database');

// @ts-ignore
class MoneyOperation extends Model<InferAttributes<User>, InferCreationAttributes<User>> {
  declare id: string;
  declare date: Date;
  declare category: string;
  declare amount: number;
  declare description: string;
  declare currency: string;
  declare isExpense: boolean;
  declare userId: string;
}

MoneyOperation.init(
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      primaryKey: true,
    },
    date: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    category: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    amount: {
      type: DataTypes.DOUBLE,
      allowNull: false,
    },
    description: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    currency: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    isExpense: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
    },
    userId: {
      type: DataTypes.UUID,
      allowNull: false,
      references: {
        model: User,
        key: 'id',
      },
      onUpdate: 'CASCADE',
      onDelete: 'CASCADE',
    },
  },
  {
    sequelize,
    tableName: 'money_operations',
    timestamps: true,
  }
);

export default MoneyOperation;
