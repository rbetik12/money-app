package com.moneyai.model

import kotlinx.serialization.Serializable

@Serializable
abstract class ITokenRequest {
    abstract val token: String
}