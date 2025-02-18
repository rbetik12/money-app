package com.moneyai.model

import kotlinx.serialization.Serializable

@Serializable
class MoneyOperationRequestAI : ITokenRequest() {
    override val token: String = ""
    val text: String = ""
    val expenseCategories: List<String> = emptyList()
    val incomeCategories: List<String> = emptyList()
}