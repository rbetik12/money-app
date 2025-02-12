package com.moneyai.db

import com.moneyai.model.User
import kotlinx.coroutines.Dispatchers
import org.h2.util.Task
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

class UserDAO(id: EntityID<UUID>) : UUIDEntity(id) {
    companion object : UUIDEntityClass<UserDAO>(UserTable)

    var googleId by UserTable.googleId
    var googleRefreshToken by UserTable.googleRefreshToken
}

suspend fun <T> suspendTransaction(block: Transaction.() -> T): T =
    newSuspendedTransaction(Dispatchers.IO, statement = block)

fun daoToModel(dao: UserDAO) = User(
    id = dao.id.value,
    dao.googleId,
    dao.googleRefreshToken
)