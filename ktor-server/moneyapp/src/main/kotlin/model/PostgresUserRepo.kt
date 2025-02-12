package com.moneyai.model

import com.moneyai.db.UserDAO
import com.moneyai.db.UserTable
import com.moneyai.db.daoToModel
import com.moneyai.db.suspendTransaction
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.SqlExpressionBuilder.firstValue
import org.jetbrains.exposed.sql.deleteWhere
import java.util.UUID
import kotlin.coroutines.suspendCoroutine

class PostgresUserRepo : UserRepo {
    override suspend fun allUsers(): List<User> = suspendTransaction {
        UserDAO.all().map(::daoToModel)
    }

    override suspend fun add(user: User): Unit = suspendTransaction {
        UserDAO.new {
            googleId = user.googleId
            googleRefreshToken = user.googleRefreshToken
        }
    }

    override suspend fun remove(user: User): Boolean = suspendTransaction {
        val rows = UserTable.deleteWhere { UserTable.id eq user.id }
        rows > 0
    }
}