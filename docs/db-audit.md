# Audit Kolom Database EcoCycle

Tanggal: 2026-06-09. Sumber skema: `database/ecocycle_pdm.sql`, `backend/database/product_schema.sql`, dan migrasi idempotent di `backend/src/config/seed.js`. Status dinilai dari pemakaian di `backend/src/**` dan `lib/**`.

Legenda: ✅ dipakai · ⚠️ ditulis tapi tak dibaca / longgar · ❌ benar-benar mati (tak ditulis & tak dibaca)

## users
| Kolom | Status | Catatan |
|---|---|---|
| user_id, full_name, email, phone_number, password_hash, address | ✅ | inti auth/profil |
| latitude, longitude | ✅ | lokasi penjual → ongkir |
| profile_photo | ✅ | foto profil (base64) |
| eco_points, total_waste_kg, co2_offset_kg, green_transactions | ✅ | statistik dampak & poin |
| account_status | ✅ | cek 'ACTIVE' saat login/middleware |
| is_premium | ⚠️ | disimpan & dikembalikan API, tapi UI tidak memakainya |
| created_at, updated_at | ✅ | created_at = "member since" |
| **trees_planted** | ❌ | tak pernah ditulis maupun dibaca di backend/Flutter |

## sellers
| Kolom | Status | Catatan |
|---|---|---|
| seller_id, user_id, seller_name | ✅ | |
| **seller_description** | ❌ | tak pernah dipakai |
| **is_verified** | ⚠️ | hanya ditulis `0` saat buat seller, tak pernah dibaca |

## products
| Kolom | Status | Catatan |
|---|---|---|
| product_id, seller_id, product_category_id, product_name, description, price, stock | ✅ | |
| waste_kg, weight_kg | ✅ | dampak + ongkir |
| image_url | ✅ | foto utama/thumbnail |
| rating, sold_count | ✅ | |
| created_at | ✅ | |
| **unit_name** | ⚠️ | selalu ditulis `'unit'`, tak pernah dibaca |
| **product_status** | ⚠️ | selalu ditulis `'ACTIVE'`, tak difilter (hapus = DELETE keras) |

## product_images (baru, Phase 3)
| Kolom | Status |
|---|---|
| image_id, product_id, image_path, sort_order, created_at | ✅ |

## orders
| Kolom | Status | Catatan |
|---|---|---|
| order_id, user_id, order_code, shipping_address, shipping_method | ✅ | |
| order_status | ✅ | DIPROSES/DIKIRIM/SELESAI |
| subtotal, shipping_cost, total_amount | ✅ | |
| created_at, updated_at | ✅ | updated_at dipakai sejak Phase 1 |
| **discount** | ⚠️ | selalu `0` (model tanpa diskon); diteruskan ke UI tapi tak pernah > 0 |

## order_items
| Kolom | Status |
|---|---|
| semua kolom | ✅ |

## payments
| Kolom | Status | Catatan |
|---|---|---|
| payment_id, order_id, payment_method, payment_status, paid_at, created_at | ✅ | |
| **paid_amount** | ⚠️ | ditulis (= total) saat buat order, tak pernah dibaca |

## notifications
| Kolom | Status | Catatan |
|---|---|---|
| semua kolom | ✅ | is_read dipakai penuh |
| related_order_id | ⚠️ | dipakai (deep-link) tapi **tanpa FK constraint** → bisa orphan |

## product_categories
| Kolom | Status | Catatan |
|---|---|---|
| product_category_id, category_name | ✅ | |
| description | ⚠️ | data referensi (di-seed), tak ditampilkan |

## carts, cart_items, wishlists, payment_methods, point_transactions
Semua kolom ✅ dipakai (lihat cartController, wishlistController, paymentMethodController, pointController/orderController).

---

## Rekomendasi

**Aman dihapus (benar-benar mati / write-only, tak ada konsumen):**
- `users.trees_planted` — mati total.
- `sellers.seller_description` — mati total.
- `sellers.is_verified` — write-only.
- `products.unit_name` — write-only.
- `payments.paid_amount` — write-only (nilai = total_amount, bisa direkonstruksi).

**Pertimbangkan dipertahankan (longgar tapi punya alasan):**
- `products.product_status` — berguna untuk soft-delete/nonaktif produk ke depan (saat ini hapus = DELETE keras). Rekomendasi: **pakai**, bukan hapus — filter `product_status='ACTIVE'` di list & ubah delete jadi set 'INACTIVE'.
- `orders.discount` — sisakan untuk kemungkinan promo desa; atau hapus bila yakin tak akan ada diskon.
- `users.is_premium`, `product_categories.description` — murah, kemungkinan dipakai nanti.

**Perbaikan integritas:**
- Tambah FK `notifications.related_order_id → orders(order_id) ON DELETE SET NULL` agar tak ada notifikasi yatim.

> Tidak ada `DROP COLUMN` yang dijalankan tanpa persetujuan. Setelah disetujui, perubahan diterapkan lewat migrasi baru + idempotent di `seed.js`.

## Tindak lanjut (disetujui & diterapkan)
Diterapkan via `database/migrations/cleanup_unused_columns.sql` + `seed.js > cleanupSchema` (idempotent):
- ✂️ Hapus `users.trees_planted`, `sellers.seller_description`, `orders.discount` (kolom + backend + UI).
- 🔗 Tambah FK `notifications.related_order_id → orders(order_id) ON DELETE SET NULL` (nol-kan orphan dulu).

Tidak diambil (sengaja dipertahankan): `sellers.is_verified`, `products.unit_name`, `payments.paid_amount`, `products.product_status` (soft-delete ditunda), `users.is_premium`, `product_categories.description`.
