package com.example.labs

import android.content.Context
import android.graphics.BitmapFactory
import android.net.Uri
import androidx.room.withTransaction
import java.io.File
import java.io.IOException
import java.util.UUID
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.NonCancellable
import kotlinx.coroutines.withContext

internal class DrinkPhotos(private val context: Context, private val database: CatalogDatabase) {
    private val directory = File(context.filesDir, "drink-photos")
    private val dao = database.catalogDao()

    suspend fun attach(drinkKey: String, uri: Uri): DrinkNote = withContext(Dispatchers.IO) {
        directory.mkdirs()
        val file = File(directory, "${UUID.randomUUID()}.image")
        var saved = false
        try {
            val input = context.contentResolver.openInputStream(uri)
                ?: throw IOException("Cannot open selected image")
            input.use {
                file.outputStream().use { output ->
                    val buffer = ByteArray(DEFAULT_BUFFER_SIZE)
                    var size = 0
                    while (true) {
                        val count = input.read(buffer)
                        if (count == -1) break
                        size += count
                        if (size > MAX_BYTES) throw IOException("Photo exceeds 10 MiB")
                        output.write(buffer, 0, count)
                    }
                }
            }
            val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
            BitmapFactory.decodeFile(file.path, bounds)
            if (bounds.outWidth <= 0 || bounds.outHeight <= 0) {
                throw IOException("Unsupported photo")
            }
            withContext(NonCancellable) {
                updatePhoto(drinkKey, file.name).also { saved = true }
            }
        } finally {
            if (!saved) file.delete()
        }
    }

    suspend fun remove(drinkKey: String): DrinkNote = withContext(Dispatchers.IO) {
        updatePhoto(drinkKey, null)
    }

    suspend fun read(name: String): ByteArray = withContext(Dispatchers.IO) {
        require(PHOTO_NAME.matches(name))
        File(directory, name).readBytes()
    }

    private suspend fun updatePhoto(drinkKey: String, name: String?): DrinkNote {
        val (previous, updated) = database.withTransaction {
            val previous = dao.readNote(drinkKey) ?: DrinkNote(drinkKey)
            val updated = previous.copy(photoName = name)
            dao.saveNote(updated)
            previous to updated
        }
        previous.photoName?.let { File(directory, it).delete() }
        return updated
    }

    companion object {
        private const val MAX_BYTES = 10 * 1024 * 1024
        private val PHOTO_NAME = Regex("[a-f0-9-]{36}\\.image")
    }
}
