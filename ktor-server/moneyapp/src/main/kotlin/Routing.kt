package com.moneyai

import com.auth0.jwt.JWT
import com.auth0.jwt.algorithms.Algorithm
import com.moneyai.db.UserDAO
import com.moneyai.model.SignInRequest
import com.moneyai.model.SignOutRequest
import com.moneyai.model.User
import com.moneyai.model.UserRepo
import com.moneyai.service.UserService
import com.moneyai.utils.GoogleAuthVerifier
import com.moneyai.utils.JWTGenerator
import io.ktor.client.*
import io.ktor.client.engine.apache.*
import io.ktor.http.*
import io.ktor.serialization.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.server.application.*
import io.ktor.server.auth.*
import io.ktor.server.auth.jwt.*
import io.ktor.server.plugins.contentnegotiation.*
import io.ktor.server.plugins.cors.routing.*
import io.ktor.server.plugins.requestvalidation.RequestValidation
import io.ktor.server.plugins.requestvalidation.ValidationResult
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.server.sessions.*
import java.sql.Connection
import java.sql.DriverManager
import java.util.*

fun Application.configureRouting(userService: UserService) {
    routing {
        route("/v1/users") {
            get {
                call.respond(userService.getAllUsers())
            }
            post {
                call.respond(userService.createOrUpdateUser(call.receive(), useGoogleId = false))
            }
        }
        route("/v1/auth/google/signin") {
            post {
                val request = call.receive<SignInRequest>()
                val payload = GoogleAuthVerifier.verifyIdToken(request.idToken)

                if (payload != null) {
                    val user = userService.createOrUpdateUser(
                        User(
                            id = UUID.randomUUID(),
                            googleId = payload.subject,
                            googleRefreshToken = request.refreshToken
                        ),
                        useGoogleId = true
                    )
                    call.respond(HttpStatusCode.OK, JWTGenerator.generateToken(user))
                } else {
                    call.respond(HttpStatusCode.Forbidden, "Invalid ID token.")
                }
            }
        }
    }
}
