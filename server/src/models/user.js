const { DataTypes, Model } = require('sequelize');
const { sequelize } = require('../config/database');

const User = sequelize.define(
  'User',
  {
    id: {
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4, // Automatically generate UUIDs
      primaryKey: true,
      allowNull: false,
    },
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true, // Ensure email is unique
      validate: {
        isEmail: true, // Validates email format
      },
    },
  },
  {
    tableName: 'users', // Name of the table
    timestamps: true,    // Automatically adds createdAt and updatedAt
  }
);

// the defined model is the class itself
console.log(User === sequelize.models.User); // true

module.exports = User;
