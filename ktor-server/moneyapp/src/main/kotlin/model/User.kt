package com.moneyai.model

import com.moneyai.utils.UUIDSerializer
import kotlinx.serialization.Serializable
import java.util.UUID

@Serializable
data class User(
    @Serializable(with = UUIDSerializer::class)
    val id: UUID?,
    val googleId: String?,
    var googleRefreshToken: String?,
)