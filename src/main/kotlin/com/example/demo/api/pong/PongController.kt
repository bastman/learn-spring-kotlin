package com.example.demo.api.pong


import com.example.demo.api.ApiConfig.Companion.API_BASE_URL
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import java.time.Instant

data class PongRequest(val pong: String)
data class PongResponse(val id: Int, val pong: String, val modifiedAt: Instant)

@RestController
class PongController {

    @PostMapping("$API_BASE_URL/pong/{id}")
    fun postPong(
            @RequestParam id: Int,
            @RequestBody payload: PongRequest
    ): PongResponse =
            PongResponse(
                    id = id,
                    pong = payload.pong.toUpperCase(),
                    modifiedAt = Instant.now()
            )
}