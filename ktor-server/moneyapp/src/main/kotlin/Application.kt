package com.moneyai

import com.moneyai.model.PostgresUserRepo
import com.moneyai.service.MoneyOperationService
import com.moneyai.service.UserService
import io.ktor.server.application.*

fun main(args: Array<String>) {
    io.ktor.server.netty.EngineMain.main(args)
}

fun Application.module() {
    configureRequestValidation()
    configureDatabases()
    configureSecurity()
    configureHTTP()
    configureSerialization()
    configureRouting(UserService())
    configureMoneyOperationRouting(PostgresUserRepo(), MoneyOperationService(PostgresUserRepo()))
}
