package com.moneyai.utils

import com.moneyai.model.MoneyOperation
import com.openai.client.OpenAIClient
import com.openai.client.okhttp.OpenAIOkHttpClient
import com.openai.models.ChatCompletionCreateParams
import com.openai.models.ChatModel
import kotlinx.datetime.toLocalDateTime
import kotlinx.serialization.Serializable
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json
import java.util.*

object MoneyOperationAIParser {
    private val client: OpenAIClient = OpenAIOkHttpClient.builder()
        .apiKey(System.getenv("OPENAI_KEY"))
        .build()

    @Serializable
    private data class MoneyOperationAIGenerated(
        val category: String,
        val amount: Double,
        val description: String,
        val currency: String,
        val isExpense: Boolean
    )

    fun parse(text: String, expenseCategoriesList: List<String>, incomeCategoriesList: List<String>): List<MoneyOperation> {
        val systemPrompt = "Extract spend category type ${expenseCategoriesList.joinToString(", ")}, amount of money that was spent to it, description of the expense (if given), in which currency it was given (EUR, USD or RSD) or income description, category ${incomeCategoriesList.joinToString(", ")} from the given text and return it as a JSON. JSON must contain only array or operations, don't split them on income and expense or any other categories. Income or expense must be marked with isExpense field. JSON fields order must be exactly like this (category, amount, description, currency, isExpense). JSON must not be formatted for markdown, just pure JSON."
        val params = ChatCompletionCreateParams.builder()
            .addUserMessage(text)
            .addSystemMessage(systemPrompt)
            .model(ChatModel.GPT_4_TURBO)
            .build()
        val chatCompletion = client.chat().completions().create(params)
        val result = chatCompletion.choices()[0].message().content().orElse("")

        try {
            val parsedResult = Json.decodeFromString<List<MoneyOperationAIGenerated>>(result)
            return parsedResult.map {
                MoneyOperation(
                    id = UUID.randomUUID(),
                    date = kotlinx.datetime.Clock.System.now().toLocalDateTime(kotlinx.datetime.TimeZone.UTC),
                    category = it.category,
                    amount = it.amount,
                    description = it.description,
                    currency = it.currency,
                    isExpense = it.isExpense
                )
            }
        } catch (e: Exception) {
            println("Failed to parse AI response: $result")
            return emptyList()
        }
    }
}