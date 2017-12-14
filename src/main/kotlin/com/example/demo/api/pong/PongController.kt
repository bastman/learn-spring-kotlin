package com.example.demo.api.pong

import com.example.demo.api.ApiConfig.Companion.API_BASE_URL
import com.example.demo.api.common.EntityNotFoundException
import com.example.demo.api.pong.domain.PongRepository
import com.example.demo.api.pong.domain.RepositoryItem
import org.springframework.web.bind.annotation.*
import java.time.Instant

data class PongRequest(val pong: String)
data class PongResponse(val id: Int, val pong: String, val modifiedAt: Instant)

@RestController
class PongController(private val repo: PongRepository) {

    @PostMapping("$API_BASE_URL/pong/{id}")
    fun postPong(
            @RequestParam id: Int,
            @RequestBody payload: PongRequest
    ): PongResponse
            = RepositoryItem(id = id, pong = payload.pong.toUpperCase(), modifiedAt = Instant.now())
            .also { repo.put(it) }
            .toPongResponse()

    @GetMapping("$API_BASE_URL/pong/{id}")
    fun getPong(@RequestParam id: Int): PongResponse {
        val repoItem = repo.get(itemId = id)

        return if (repoItem != null) {
            repoItem.toPongResponse()
        } else {
            throw EntityNotFoundException("Pong with id=$id not found!")
        }
    }
}

private fun RepositoryItem.toPongResponse()
        = PongResponse(id = id, pong = pong.toUpperCase(), modifiedAt = modifiedAt)

