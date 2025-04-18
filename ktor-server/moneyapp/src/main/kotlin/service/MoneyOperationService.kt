package com.moneyai.service

import com.moneyai.db.MoneyOperationEntity
import com.moneyai.db.suspendTransaction
import com.moneyai.model.MoneyOperation
import com.moneyai.model.MoneyOperationRepo
import com.moneyai.model.User
import com.moneyai.model.UserRepo
import java.util.*

class MoneyOperationService(private val userRepo: UserRepo) {
    private val moneyOpRepo = MoneyOperationRepo()

    suspend fun add(op: MoneyOperation, user: User): MoneyOperation {
        val userEntity = userRepo.findUserById(user.id!!)
        return moneyOpRepo.add(op, userEntity!!)
    }

    suspend fun update(op: MoneyOperation, user: User): MoneyOperation {
        val userEntity = userRepo.findUserById(user.id!!)
        return moneyOpRepo.update(op, userEntity!!)
    }

    suspend fun find(id: UUID): MoneyOperation? {
        return moneyOpRepo.find(id)
    }

    suspend fun all(user: User): List<MoneyOperation> {
        return moneyOpRepo.all(user)
    }

    suspend fun delete(id: UUID) {
        moneyOpRepo.delete(id)
    }
}