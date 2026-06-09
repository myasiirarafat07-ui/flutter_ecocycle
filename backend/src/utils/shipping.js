// Perhitungan ongkos kirim antar-warga (tanpa jasa kurir komersial).
// Ongkir = BASE + jarak_terjauh(km) * PER_KM + total_berat(kg) * PER_KG,
// dibulatkan ke kelipatan ROUND_TO, minimal MIN_FEE.
// Jika lokasi pembeli/penjual tidak tersedia → fallback FALLBACK_FEE.
//
// Konstanta ini DICERMINKAN di Flutter (lib/constants/shipping.dart) agar
// estimasi di layar checkout sama dengan nilai otoritatif backend.
const SHIP_BASE_FEE = 3000;
const SHIP_PER_KM = 2000;
const SHIP_PER_KG = 1000;
const SHIP_MIN_FEE = 3000;
const SHIP_FALLBACK_FEE = 10000;
const SHIP_ROUND_TO = 500;

const EARTH_RADIUS_KM = 6371;

function toRad(deg) {
  return (deg * Math.PI) / 180;
}

function isCoord(v) {
  return typeof v === 'number' && Number.isFinite(v);
}

/** Jarak Haversine (km) antara dua titik koordinat. */
function haversineKm(aLat, aLng, bLat, bLng) {
  const dLat = toRad(bLat - aLat);
  const dLng = toRad(bLng - aLng);
  const lat1 = toRad(aLat);
  const lat2 = toRad(bLat);
  const h =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLng / 2) ** 2;
  return 2 * EARTH_RADIUS_KM * Math.asin(Math.sqrt(h));
}

/**
 * Hitung ongkir.
 * @param {{lat:number,lng:number}|null} buyer lokasi pembeli.
 * @param {Array<{lat:number,lng:number,weightKg:number}>} legs per-penjual:
 *   koordinat penjual + total berat barang dari penjual tsb.
 * @returns {{ cost:number, distanceKm:number, totalWeightKg:number, fallback:boolean }}
 */
function calcShipping(buyer, legs) {
  const totalWeightKg = legs.reduce(
    (sum, l) => sum + (Number(l.weightKg) || 0),
    0,
  );

  const hasBuyer = buyer && isCoord(buyer.lat) && isCoord(buyer.lng);
  const distances = [];
  if (hasBuyer) {
    for (const l of legs) {
      if (isCoord(l.lat) && isCoord(l.lng)) {
        distances.push(haversineKm(buyer.lat, buyer.lng, l.lat, l.lng));
      }
    }
  }

  if (distances.length === 0) {
    return {
      cost: SHIP_FALLBACK_FEE,
      distanceKm: 0,
      totalWeightKg,
      fallback: true,
    };
  }

  const distanceKm = Math.max(...distances);
  const raw =
    SHIP_BASE_FEE + distanceKm * SHIP_PER_KM + totalWeightKg * SHIP_PER_KG;
  const rounded = Math.round(raw / SHIP_ROUND_TO) * SHIP_ROUND_TO;
  return {
    cost: Math.max(SHIP_MIN_FEE, rounded),
    distanceKm,
    totalWeightKg,
    fallback: false,
  };
}

module.exports = {
  SHIP_BASE_FEE,
  SHIP_PER_KM,
  SHIP_PER_KG,
  SHIP_MIN_FEE,
  SHIP_FALLBACK_FEE,
  SHIP_ROUND_TO,
  haversineKm,
  calcShipping,
};
