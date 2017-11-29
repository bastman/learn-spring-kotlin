package com.example.demo.config

import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.databind.SerializationFeature
import com.fasterxml.jackson.module.kotlin.jacksonObjectMapper
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class Jackson {
    @Bean
    fun objectMapper(): ObjectMapper = defaultMapper()

    companion object {
        fun defaultMapper(): ObjectMapper
                = jacksonObjectMapper()
                .findAndRegisterModules()
                .disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS)
    }
}