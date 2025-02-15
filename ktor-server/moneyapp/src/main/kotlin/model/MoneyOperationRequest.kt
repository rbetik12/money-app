package com.moneyai.model

import kotlinx.serialization.Serializable

@Serializable
class MoneyOperationRequest : ITokenRequest() {
    override val token: String = ""
    val id: String = ""
    val currency: String = ""
    val amount: Double = 0.0
    val description: String = ""
    val category: String = ""
    val isExpense: Boolean = false
}