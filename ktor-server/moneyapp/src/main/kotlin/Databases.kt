package com.moneyai

import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import org.jetbrains.exposed.sql.*

fun Application.configureDatabases() {
    Database.connect(
        "jdbc:postgresql://localhost:5432/mydb",
        user = "myuser",
        password = "mypassword"
    )
}