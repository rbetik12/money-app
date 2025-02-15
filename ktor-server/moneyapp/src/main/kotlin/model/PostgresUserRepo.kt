package com.moneyai.model

import com.moneyai.db.UserEntity
import com.moneyai.db.UserTable
import com.moneyai.db.suspendTransaction
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.deleteWhere
import java.util.*

class PostgresUserRepo : UserRepo {
    override suspend fun allUsers(): List<User> = suspendTransaction {
        UserEntity.all().map(UserEntity::toModel)
    }

    override suspend fun add(user: User): User = suspendTransaction {
        UserEntity.new {
            googleId = user.googleId
            googleRefreshToken = user.googleRefreshToken
        }.let(UserEntity::toModel)
    }

    override suspend fun remove(user: User): Boolean = suspendTransaction {
        val rows = UserTable.deleteWhere { UserTable.id eq user.id }
        rows > 0
    }

    override suspend fun find(user: User, useGoogleId: Boolean): User? = suspendTransaction {
        if (useGoogleId) {
            UserEntity.find { UserTable.googleId eq user.googleId }.firstOrNull()?.let(UserEntity::toModel)
        } else {
            UserEntity.find { UserTable.id eq user.id }.firstOrNull()?.let(UserEntity::toModel)
        }
    }

    override suspend fun update(user: User): Boolean = suspendTransaction {
        val userToUpdate = UserEntity.find { UserTable.id eq user.id }.firstOrNull() ?: return@suspendTransaction false
        userToUpdate.apply {
            googleId = user.googleId
            googleRefreshToken = user.googleRefreshToken
        }
        true
    }

    override suspend fun findUserById(id: UUID): UserEntity? = suspendTransaction {
        UserEntity.find { UserTable.id eq id }.firstOrNull()
    }
}