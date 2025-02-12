package com.moneyai.model

interface UserRepo {
    suspend fun allUsers(): List<User>
    suspend fun add(user: User)
    suspend fun remove(user: User): Boolean
}