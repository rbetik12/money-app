package com.moneyai

import com.auth0.jwt.JWT
import com.auth0.jwt.algorithms.Algorithm
import com.moneyai.model.ITokenRequest
import io.ktor.client.*
import io.ktor.client.engine.apache.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.server.application.*
import io.ktor.server.auth.*
import io.ktor.server.auth.jwt.*
import io.ktor.server.plugins.contentnegotiation.*
import io.ktor.server.plugins.cors.routing.*
import io.ktor.server.plugins.requestvalidation.*
import io.ktor.server.plugins.statuspages.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.server.sessions.*
import java.sql.Connection
import java.sql.DriverManager

fun Application.configureSecurity() {
}

fun Application.configureRequestValidation() {
    install(RequestValidation) {
        validate<ITokenRequest> { request ->
            if (request.token.isBlank()) {
                ValidationResult.Invalid("ID token cannot be blank")
            } else {
                ValidationResult.Valid
            }
        }
    }

    install(StatusPages) {
        exception<RequestValidationException> { call, cause ->
            call.respond(HttpStatusCode.BadRequest, cause.reasons.joinToString())
        }
    }
}

