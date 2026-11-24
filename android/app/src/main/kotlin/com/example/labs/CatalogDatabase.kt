package com.example.labs

import android.content.Context
import androidx.room.Dao
import androidx.room.Database
import androidx.room.Entity
import androidx.room.PrimaryKey
import androidx.room.Query
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.Upsert
import kotlinx.coroutines.flow.Flow

@Entity(tableName = "catalog_snapshot")
data class CatalogSnapshot(
    @PrimaryKey val id: Int = 1,
    val json: String,
    val updatedAt: Long,
)

@Entity(tableName = "drink_notes")
data class DrinkNote(
    @PrimaryKey val drinkKey: String,
    val favorite: Boolean = false,
    val photoName: String? = null,
) {
    fun toMessage() = mapOf("favorite" to favorite, "photoName" to photoName)
}

@Dao
interface CatalogDao {
    @Query("SELECT json FROM catalog_snapshot WHERE id = 1 AND updatedAt >= :appUpdatedAt")
    suspend fun readCatalog(appUpdatedAt: Long): String?

    @Query("SELECT json FROM catalog_snapshot WHERE id = 1 AND updatedAt >= :appUpdatedAt")
    fun observeCatalog(appUpdatedAt: Long): Flow<String?>

    @Upsert
    suspend fun saveCatalog(snapshot: CatalogSnapshot)

    @Query("SELECT * FROM drink_notes")
    suspend fun readNotes(): List<DrinkNote>

    @Query("SELECT * FROM drink_notes WHERE drinkKey = :drinkKey")
    suspend fun readNote(drinkKey: String): DrinkNote?

    @Upsert
    suspend fun saveNote(note: DrinkNote)
}

@Database(entities = [CatalogSnapshot::class, DrinkNote::class], version = 1, exportSchema = false)
abstract class CatalogDatabase : RoomDatabase() {
    abstract fun catalogDao(): CatalogDao

    companion object {
        @Volatile private var instance: CatalogDatabase? = null

        fun open(context: Context): CatalogDatabase = instance ?: synchronized(this) {
            instance ?: Room.databaseBuilder(
                context.applicationContext,
                CatalogDatabase::class.java,
                "bubble-tea-catalog.db",
            ).build().also { instance = it }
        }
    }
}
