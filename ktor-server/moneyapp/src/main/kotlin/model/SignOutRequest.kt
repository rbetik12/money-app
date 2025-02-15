package com.moneyai.model

import kotlinx.serialization.Serializable

@Serializable
class SignOutRequest : ITokenRequest() {
    override val token: String = ""
}