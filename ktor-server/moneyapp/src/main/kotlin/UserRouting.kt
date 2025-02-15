package com.moneyai

import com.moneyai.model.*
import com.moneyai.service.UserService
import com.moneyai.utils.GoogleAuthVerifier
import com.moneyai.utils.JWTGenerator
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
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
        route("/v1/auth/signout") {
            post {
                val request = call.receive<SignOutRequest>()
                val userId = JWTGenerator.parseToken(request.token)
                if (userId != null) {
                    userService.deleteCredentials(userId)
                    call.respond(HttpStatusCode.OK)
                } else {
                    call.respond(HttpStatusCode.BadRequest, "Invalid token.")
                }
            }
        }
    }
}
