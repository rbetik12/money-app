package com.moneyai.service

import com.moneyai.model.PostgresUserRepo
import com.moneyai.model.User
import com.moneyai.model.UserRepo

class UserService {
    private val repo: UserRepo = PostgresUserRepo()

    suspend fun getAllUsers(): List<User> {
        return repo.allUsers()
    }

    suspend fun createOrUpdateUser(user: User, useGoogleId: Boolean): User {
        return repo.find(user, useGoogleId)?.also {
            repo.update(user)
        } ?: repo.add(user)
    }
}