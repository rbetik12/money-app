package com.moneyai.service

import com.moneyai.model.PostgresUserRepo
import com.moneyai.model.User
import com.moneyai.model.UserRepo
import java.util.*

class UserService {
    private val repo: UserRepo = PostgresUserRepo()

    suspend fun getAllUsers(): List<User> {
        return repo.allUsers()
    }

    suspend fun createOrUpdateUser(user: User, useGoogleId: Boolean): User {
        return repo.find(user, useGoogleId)?.also {
            repo.update(User(id = it.id, googleId = user.googleId, googleRefreshToken = user.googleRefreshToken))
        } ?: repo.add(user)
    }

    suspend fun deleteCredentials(userId: UUID) {
        val user = repo.find(User(id = userId, googleRefreshToken = null, googleId = null), false)
        if (user != null) {
            user.googleRefreshToken = null
            repo.update(user)
        }
    }
}