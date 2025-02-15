package com.moneyai.service

import com.moneyai.db.MoneyOperationEntity
import com.moneyai.db.suspendTransaction
import com.moneyai.model.MoneyOperation
import com.moneyai.model.MoneyOperationRepo
import com.moneyai.model.UserRepo

class MoneyOperationService(private val userRepo: UserRepo) {
    private val moneyOpRepo = MoneyOperationRepo()

    suspend fun add(op: MoneyOperation): MoneyOperation {
        val user = userRepo.findUserById(op.user.id!!)
        return moneyOpRepo.add(op, user!!)
    }
}