package com.example.demo.api.ping

import com.example.demo.api.ApiConfig.Companion.API_BASE_URL
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import java.time.Instant

data class PingResponse(val ping: String)

@RestController
class PingController {

    @GetMapping("$API_BASE_URL/ping")
    fun getPing() = PingResponse(ping = "PING :) today is ${Instant.now()}")
}