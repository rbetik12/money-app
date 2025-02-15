package com.moneyai.model

import com.moneyai.db.MoneyOperationEntity
import com.moneyai.db.UserEntity
import com.moneyai.db.suspendTransaction
import org.jetbrains.exposed.dao.id.EntityID
import java.util.UUID

class MoneyOperationRepo {
    suspend fun find(id: UUID): MoneyOperation? = suspendTransaction {
        MoneyOperationEntity.findById(id)?.let(MoneyOperationEntity::toModel)
    }

    suspend fun add(op: MoneyOperation, userEntity: UserEntity): MoneyOperation = suspendTransaction {
        MoneyOperationEntity.new(id = op.id) {
            date = op.date
            category = op.category
            amount = op.amount
            description = op.description
            currency = op.currency
            isExpense = op.isExpense
            user = userEntity
        }.let(MoneyOperationEntity::toModel)
    }
}