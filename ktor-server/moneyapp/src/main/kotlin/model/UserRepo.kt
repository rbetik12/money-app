package com.moneyai.model

import com.moneyai.db.UserEntity
import java.util.*

interface UserRepo {
    suspend fun allUsers(): List<User>
    suspend fun add(user: User): User
    suspend fun find(user: User, useGoogleId: Boolean): User?
    suspend fun update(user: User): Boolean
    suspend fun remove(user: User): Boolean
    suspend fun findUserById(id: UUID): UserEntity?
}