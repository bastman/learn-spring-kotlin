package com.example.demo.api

import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Component

@Component
data class ApiConfig(
        @Value(value = "\${api.auth.enabled}") val authEnabled: Boolean
) {
    val title: String = "demo-service"
    val headerTraceId: String = "x-trace-id"
    val baseUrl = API_BASE_URL

    companion object {
        const val API_BASE_URL = "/api"
    }
}