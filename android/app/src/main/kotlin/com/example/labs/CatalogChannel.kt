package com.example.labs

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.util.Log
import androidx.room.withTransaction
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.Job
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.launch

internal class CatalogChannel(private val activity: Activity, messenger: BinaryMessenger) {
    private val context = activity.applicationContext
    private val appUpdatedAt by lazy {
        @Suppress("DEPRECATION")
        context.packageManager.getPackageInfo(context.packageName, 0).lastUpdateTime
    }
    private val database by lazy { CatalogDatabase.open(context) }
    private val dao by lazy { database.catalogDao() }
    private val photos by lazy { DrinkPhotos(context, database) }
    private val scope = MainScope()
    private val methods = MethodChannel(messenger, "bubble_tea/catalog")
    private val updates = EventChannel(messenger, "bubble_tea/catalog_updates")
    private var catalogJob: Job? = null
    private var pendingPhoto: Pair<String, MethodChannel.Result>? = null

    init {
        methods.setMethodCallHandler(::handle)
        updates.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                catalogJob?.cancel()
                catalogJob = scope.launch {
                    dao.observeCatalog(appUpdatedAt).distinctUntilChanged()
                        .catch { error -> events.error("catalog", error.message, null) }
                        .collect { json -> if (json != null) events.success(true) }
                }
            }

            override fun onCancel(arguments: Any?) {
                catalogJob?.cancel()
            }
        })
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "readCatalog" -> reply(result) { dao.readCatalog(appUpdatedAt) }
            "refreshCatalog" -> reply(result) {
                refreshCatalog(context)
                null
            }
            "readNotes" -> reply(result) {
                dao.readNotes().associate { it.drinkKey to it.toMessage() }
            }
            "setFavorite" -> reply(result) {
                val key = drinkKey(call)
                val favorite = requireNotNull(call.argument<Boolean>("favorite"))
                database.withTransaction {
                    val note = dao.readNote(key) ?: DrinkNote(key)
                    note.copy(favorite = favorite).also { dao.saveNote(it) }.toMessage()
                }
            }
            "pickPhoto" -> pickPhoto(call.argument<String>("drinkKey"), result)
            "readPhoto" -> reply(result) { photos.read(requireNotNull(call.arguments as? String)) }
            "removePhoto" -> reply(result) { photos.remove(drinkKey(call)).toMessage() }
            else -> result.notImplemented()
        }
    }

    private fun drinkKey(call: MethodCall): String =
        requireNotNull(call.argument<String>("drinkKey")).also { require(it.isNotBlank()) }

    private fun reply(result: MethodChannel.Result, action: suspend () -> Any?) {
        scope.launch {
            try {
                result.success(action())
            } catch (error: CancellationException) {
                throw error
            } catch (error: Exception) {
                Log.w("BubbleTeaCatalog", "Catalog operation failed", error)
                result.error("catalog", error.message, null)
            }
        }
    }

    private fun pickPhoto(drinkKey: String?, result: MethodChannel.Result) {
        if (drinkKey.isNullOrBlank() || pendingPhoto != null) {
            result.error("picker", "Missing drink or picker already open", null)
            return
        }
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT)
            .addCategory(Intent.CATEGORY_OPENABLE)
            .setType("image/*")
        pendingPhoto = drinkKey to result
        try {
            @Suppress("DEPRECATION")
            activity.startActivityForResult(intent, PICK_PHOTO)
        } catch (error: ActivityNotFoundException) {
            pendingPhoto = null
            result.error("picker", error.message, null)
        }
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != PICK_PHOTO) return false
        val (drinkKey, result) = pendingPhoto ?: return true
        pendingPhoto = null
        val uri = data?.data
        if (resultCode == Activity.RESULT_OK && uri != null) {
            reply(result) { photos.attach(drinkKey, uri).toMessage() }
        } else {
            result.success(null)
        }
        return true
    }

    fun close() {
        pendingPhoto?.second?.success(null)
        pendingPhoto = null
        methods.setMethodCallHandler(null)
        updates.setStreamHandler(null)
        scope.cancel()
    }

    companion object {
        private const val PICK_PHOTO = 5046
    }
}
