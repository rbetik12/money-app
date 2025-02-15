package com.moneyai

import com.moneyai.db.MoneyOperationTable
import com.moneyai.db.UserTable
import io.ktor.server.application.*
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.transactions.transaction

fun Application.configureDatabases() {
    Database.connect(
        "jdbc:postgresql://localhost:5432/mydb",
        user = "myuser",
        password = "mypassword"
    )

    transaction {
        SchemaUtils.create(UserTable)
        SchemaUtils.create(MoneyOperationTable)
    }
}