package com.moneyai

import com.moneyai.model.*
import com.moneyai.service.MoneyOperationService
import com.moneyai.utils.JWTGenerator
import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import kotlinx.datetime.toLocalDateTime
import java.time.LocalDateTime
import java.util.*

fun Application.configureMoneyOperationRouting(userRepo: UserRepo, moneyOperationService: MoneyOperationService) {
    routing {
        route("/v1/data/money-operation") {
            post {
                val req = call.receive<MoneyOperationRequest>()
                val userId = JWTGenerator.parseToken(req.token)

                if (userId == null) {
                    call.respond(HttpStatusCode.Forbidden, "Invalid token.")
                    return@post
                }

                val user = userRepo.find(User(id = userId, googleId = null, googleRefreshToken = null), false)
                if (user == null) {
                    call.respond(HttpStatusCode.BadRequest, "User with id: '$userId' wasn't found.")
                    return@post
                }

                val moneyOperationReq = MoneyOperation(
                    id = UUID.fromString(req.id),
                    date = kotlinx.datetime.Clock.System.now().toLocalDateTime(kotlinx.datetime.TimeZone.UTC),
                    category = req.category,
                    amount = req.amount,
                    description = req.description,
                    currency = req.currency,
                    isExpense = req.isExpense,
                    user = user
                )

                call.respond(HttpStatusCode.OK, moneyOperationService.add(moneyOperationReq))
            }
        }
    }
}