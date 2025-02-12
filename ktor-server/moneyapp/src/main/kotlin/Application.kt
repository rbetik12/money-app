package com.moneyai

import com.moneyai.model.PostgresUserRepo
import io.ktor.server.application.*

fun main(args: Array<String>) {
    io.ktor.server.netty.EngineMain.main(args)
}

fun Application.module() {
    configureDatabases()
    configureSecurity()
    configureHTTP()
    configureSerialization(PostgresUserRepo())
    configureRouting()
}
