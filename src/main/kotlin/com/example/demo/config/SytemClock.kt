package com.example.demo.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import java.time.Clock

@Configuration
class SytemClock {
    @Bean
    fun clock(): Clock = Clock.systemUTC()
}