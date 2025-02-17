package com.moneyai.model

import com.moneyai.utils.DateSerializer
import com.moneyai.utils.UUIDSerializer
import kotlinx.datetime.LocalDateTime
import kotlinx.serialization.Serializable
import java.util.*

@Serializable
data class MoneyOperation(
    @Serializable(with = UUIDSerializer::class)
    val id: UUID,
    val date: LocalDateTime,
    val category: String,
    val amount: Double,
    val description: String,
    val currency: String,
    val isExpense: Boolean
)
