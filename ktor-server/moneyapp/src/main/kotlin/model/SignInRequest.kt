package com.moneyai.model

import kotlinx.serialization.Serializable

@Serializable
data class SignInRequest(
    val idToken: String,
    val refreshToken: String
)
