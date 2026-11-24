package com.example.labs

import android.content.Context
import android.util.Log
import androidx.work.CoroutineWorker
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import java.io.FileNotFoundException
import java.io.IOException
import java.util.concurrent.TimeUnit
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONException

internal suspend fun refreshCatalog(context: Context) = withContext(Dispatchers.IO) {
    val json = context.assets.open("flutter_assets/assets/data/drinks.json")
        .bufferedReader().use { it.readText() }
    val drinks = JSONArray(json)
    val keys = mutableSetOf<String>()
    for (index in 0 until drinks.length()) {
        val drink = drinks.getJSONObject(index)
        val name = drink.get("name") as? String
        if (name.isNullOrBlank() || !keys.add(name) ||
            drink.get("description") !is String || drink.get("imagePath") !is String ||
            drink.get("price") !is Number ||
            listOf("nameRu", "descriptionRu").any { !drink.isNull(it) && drink.get(it) !is String }
        ) {
            throw JSONException("Invalid drink at index $index")
        }
    }
    CatalogDatabase.open(context).catalogDao().saveCatalog(
        CatalogSnapshot(json = json, updatedAt = System.currentTimeMillis()),
    )
    json
}

class CatalogRefreshWorker(context: Context, parameters: WorkerParameters) :
    CoroutineWorker(context, parameters) {
    override suspend fun doWork(): Result = try {
        refreshCatalog(applicationContext)
        Log.i(TAG, "Catalog saved to Room")
        Result.success()
    } catch (error: JSONException) {
        Log.e(TAG, "Invalid bundled catalog", error)
        Result.failure()
    } catch (error: FileNotFoundException) {
        Log.e(TAG, "Bundled catalog is missing", error)
        Result.failure()
    } catch (error: IOException) {
        Log.w(TAG, "Unable to read catalog, will retry", error)
        Result.retry()
    }

    companion object {
        private const val TAG = "BubbleTeaCatalog"
        private const val WORK_NAME = "bubble-tea-catalog-refresh"

        fun schedule(context: Context) {
            val request = PeriodicWorkRequestBuilder<CatalogRefreshWorker>(15, TimeUnit.MINUTES)
                .build()
            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                WORK_NAME,
                ExistingPeriodicWorkPolicy.KEEP,
                request,
            )
        }
    }
}
