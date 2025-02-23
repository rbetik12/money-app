package com.moneyai

import com.moneyai.model.*
import com.moneyai.service.MoneyOperationService
import com.moneyai.utils.JWTGenerator
import com.moneyai.utils.MoneyOperationAIParser
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
                    isExpense = req.isExpense
                )

                call.respond(HttpStatusCode.OK, moneyOperationService.add(moneyOperationReq, user))
            }
            put {
                val req = call.receive<MoneyOperationRequest>()
                val userId = JWTGenerator.parseToken(req.token)

                if (userId == null) {
                    call.respond(HttpStatusCode.Forbidden, "Invalid token.")
                    return@put
                }

                val user = userRepo.find(User(id = userId, googleId = null, googleRefreshToken = null), false)
                if (user == null) {
                    call.respond(HttpStatusCode.BadRequest, "User with id: '$userId' wasn't found.")
                    return@put
                }

                val dbop = moneyOperationService.find(UUID.fromString(req.id))

                if (dbop == null) {
                    call.respond(HttpStatusCode.BadRequest, "Money operation with id: '${req.id}' wasn't found.")
                    return@put
                }

                val moneyOperationReq = MoneyOperation(
                    id = UUID.fromString(req.id),
                    date = dbop.date,
                    category = req.category,
                    amount = req.amount,
                    description = req.description,
                    currency = req.currency,
                    isExpense = req.isExpense
                )

                call.respond(HttpStatusCode.OK, moneyOperationService.update(moneyOperationReq, user))
            }
        }
        route("/v1/data/money-operation/{id}/{userToken}") {
            delete {
                val token = call.parameters["userToken"]
                if (token == null) {
                    call.respond(HttpStatusCode.BadRequest, "Token is required.")
                    return@delete
                }

                val id = call.parameters["id"]
                if (id == null) {
                    call.respond(HttpStatusCode.BadRequest, "Operation id is required.")
                    return@delete
                }

                moneyOperationService.delete(UUID.fromString(id))
                call.respond(HttpStatusCode.OK)
            }
        }
        route("/v1/data/money-operation/all/{userToken}") {
            get {
                val token = call.parameters["userToken"]
                if (token == null) {
                    call.respond(HttpStatusCode.BadRequest, "Token is required.")
                    return@get
                }

                val userId = JWTGenerator.parseToken(token)
                if (userId == null) {
                    call.respond(HttpStatusCode.Forbidden, "Invalid token.")
                    return@get
                }

                val user = userRepo.find(User(id = userId, googleId = null, googleRefreshToken = null), false)
                if (user == null) {
                    call.respond(HttpStatusCode.BadRequest, "User with id: '$userId' wasn't found.")
                    return@get
                }

                call.respond(HttpStatusCode.OK, moneyOperationService.all(user))
            }
        }
        route("/v1/data/money-operation/ai") {
            post {
                val req = call.receive<MoneyOperationRequestAI>()
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

                val operations = MoneyOperationAIParser.parse(req.text, req.expenseCategories, req.incomeCategories)
                for (operation in operations) {
                    moneyOperationService.add(operation, user)
                }

                call.respond(HttpStatusCode.OK, operations)
            }
        }
    }
}