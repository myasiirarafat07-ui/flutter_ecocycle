// Faktor konversi dampak lingkungan. Estimasi sederhana — mudah diubah.
// Mengolah/mendaur ulang 1 kg limbah diasumsikan mengurangi 2.5 kg emisi CO2e
// (termasuk metana dari limbah organik/kotoran yang gagal terbentuk).
const CO2E_PER_WASTE_KG = 2.5;

/** Total emisi CO2e (kg) yang dikurangi dari total limbah terdaur ulang. */
function wasteToCo2e(totalWasteKg) {
  return Number(totalWasteKg || 0) * CO2E_PER_WASTE_KG;
}

module.exports = {
  CO2E_PER_WASTE_KG,
  wasteToCo2e,
};
