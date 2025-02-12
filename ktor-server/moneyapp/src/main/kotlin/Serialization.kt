package com.moneyai

import com.moneyai.model.User
import com.moneyai.model.UserRepo
import io.ktor.http.*
import io.ktor.serialization.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.server.application.*
import io.ktor.server.plugins.contentnegotiation.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun Application.configureSerialization(repository: UserRepo) {
    install(ContentNegotiation) {
        json()
    }
    routing {
        route("/v1/data/users") {
            get {
                val users = repository.allUsers()
                call.respond(users)
            }

            post {
                try {
                    val task = call.receive<User>()
                    repository.add(task)
                    call.respond(HttpStatusCode.NoContent)
                } catch (ex: IllegalStateException) {
                    call.respond(HttpStatusCode.BadRequest)
                } catch (ex: JsonConvertException) {
                    call.respond(HttpStatusCode.BadRequest)
                }
            }
        }
    }
}
