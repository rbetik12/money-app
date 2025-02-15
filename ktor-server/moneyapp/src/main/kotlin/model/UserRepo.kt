package com.moneyai.model

interface UserRepo {
    suspend fun allUsers(): List<User>
    suspend fun add(user: User): User
    suspend fun find(user: User, useGoogleId: Boolean): User?
    suspend fun update(user: User): Boolean
    suspend fun remove(user: User): Boolean
}