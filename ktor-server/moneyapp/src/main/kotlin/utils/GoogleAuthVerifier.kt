package com.moneyai.utils

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier
import com.google.api.client.http.javanet.NetHttpTransport
import com.google.api.client.json.JsonFactory
import com.google.api.client.json.gson.GsonFactory

object GoogleAuthVerifier {
    private val verifier = GoogleIdTokenVerifier.Builder(
        NetHttpTransport(), GsonFactory.getDefaultInstance()
    ).setAudience(listOf(System.getenv("GOOGLE_CLIENT_ID_WEB"), System.getenv("GOOGLE_CLIENT_ID_IOS"))).build()

    fun verifyIdToken(idTokenString: String): GoogleIdToken.Payload? {
        try {
            val idToken: GoogleIdToken? = verifier.verify(idTokenString)
            if (idToken == null) {
                println("Invalid ID token.")
                return null
            }
            return idToken.payload
        } catch (e: Exception) {
            println("Exception verifying ID token: $e")
            return null
        }
    }
}