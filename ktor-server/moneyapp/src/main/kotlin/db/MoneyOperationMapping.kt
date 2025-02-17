package com.moneyai.db

import com.moneyai.model.MoneyOperation
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toInstant
import kotlinx.datetime.toJavaInstant
import org.jetbrains.exposed.dao.UUIDEntity
import org.jetbrains.exposed.dao.UUIDEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.UUIDTable
import org.jetbrains.exposed.sql.kotlin.datetime.datetime
import java.util.*

object MoneyOperationTable : UUIDTable("money_operations") {
    val date = datetime("date")
    val category = varchar("category", 255)
    val amount = double("amount")
    val description = varchar("description", 255)
    val currency = varchar("currency", 3)
    val isExpense = bool("is_expense")
    val user = reference("user_id", UserTable)
}

class MoneyOperationEntity(id: EntityID<UUID>) : UUIDEntity(id) {
    companion object : UUIDEntityClass<MoneyOperationEntity>(MoneyOperationTable) {
        fun toModel(entity: MoneyOperationEntity) = MoneyOperation(
            id = entity.id.value,
            date = entity.date,
            category = entity.category,
            amount = entity.amount,
            description = entity.description,
            currency = entity.currency,
            isExpense = entity.isExpense
        )
    }

    var date by MoneyOperationTable.date
    var category by MoneyOperationTable.category
    var amount by MoneyOperationTable.amount
    var description by MoneyOperationTable.description
    var currency by MoneyOperationTable.currency
    var isExpense by MoneyOperationTable.isExpense
    var user by UserEntity referencedOn MoneyOperationTable.user
}
