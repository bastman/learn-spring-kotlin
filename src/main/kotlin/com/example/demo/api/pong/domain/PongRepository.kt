package com.example.demo.api.pong.domain

import com.github.benmanes.caffeine.cache.Caffeine
import mu.KLogging
import org.springframework.stereotype.Component
import java.time.Duration
import java.time.Instant
import java.util.concurrent.TimeUnit

data class PongRepositoryItem(val id: Int, val pong: String, val modifiedAt: Instant)

typealias RepositoryItem = PongRepositoryItem
typealias RepositoryCache = com.github.benmanes.caffeine.cache.Cache<String, RepositoryItem>

@Component
class PongRepository {

    private val cache: RepositoryCache by lazy {
        val expiry = Duration.ofDays(3)

        Caffeine
                .newBuilder()
                .maximumSize(1_000_000)
                .expireAfterWrite(expiry.seconds, TimeUnit.SECONDS)
                .build<String, RepositoryItem>()
    }

    fun put(item: RepositoryItem) {
        val cacheKey = cacheKey(item.id)
        cache.put(cacheKey, item)

        logger.info { "add item to repository. cacheKey=$cacheKey item=$item" }
    }

    fun get(itemId: Int): RepositoryItem? {
        val cacheKey = cacheKey(itemId)

        val item = cache.getIfPresent(cacheKey)
        if (item != null) {
            logger.info { "CACHE HIT: cacheKey=$cacheKey" }
        } else {
            logger.info { "CACHE MISS: cacheKey=$cacheKey" }
        }

        return item
    }

    fun PongRepository.cacheKey(itemId: Int) = "$itemId"

    companion object : KLogging()
}




