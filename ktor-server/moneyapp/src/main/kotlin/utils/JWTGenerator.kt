package com.moneyai.utils

import io.ktor.util.*
import com.auth0.jwt.JWT
import com.auth0.jwt.algorithms.Algorithm
import com.moneyai.model.User
import java.util.*

object JWTGenerator {
    private val secret = System.getenv("JWT_SECRET_KEY")
    private val algorithm = Algorithm.HMAC256(secret)

    fun generateToken(user: User): String {
        return JWT.create()
            .withSubject("Authentication")
            .withIssuer("moneyai")
            .withClaim("id", user.id.toString())
            .sign(algorithm)
    }
}