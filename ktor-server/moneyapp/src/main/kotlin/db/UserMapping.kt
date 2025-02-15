package com.moneyai.db

import com.moneyai.model.User
import kotlinx.coroutines.Dispatchers
import org.jetbrains.exposed.dao.UUIDEntity
import org.jetbrains.exposed.dao.UUIDEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.UUIDTable
import org.jetbrains.exposed.sql.Transaction
import org.jetbrains.exposed.sql.transactions.experimental.newSuspendedTransaction
import java.util.*

object UserTable : UUIDTable("users") {
    val googleId = varchar("google_id", 255).nullable().uniqueIndex()
    val googleRefreshToken = varchar("google_refresh_token", 255).nullable().uniqueIndex()
}

class UserEntity(id: EntityID<UUID>) : UUIDEntity(id) {
    companion object : UUIDEntityClass<UserEntity>(UserTable) {
        fun toModel(entity: UserEntity) = User(
            id = entity.id.value,
            entity.googleId,
            entity.googleRefreshToken
        )
    }

    var googleId by UserTable.googleId
    var googleRefreshToken by UserTable.googleRefreshToken
}

suspend fun <T> suspendTransaction(block: Transaction.() -> T): T =
    newSuspendedTransaction(Dispatchers.IO, statement = block)