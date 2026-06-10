// Helper paginasi: baca ?page= & ?limit= dari query, kembalikan nilai aman.
// limit dibatasi agar tidak membebani server; default 12.
function parsePaging(query, { defaultLimit = 12, maxLimit = 50 } = {}) {
  let page = Number(query.page);
  let limit = Number(query.limit);

  if (!Number.isFinite(page) || page < 1) page = 1;
  page = Math.floor(page);

  if (!Number.isFinite(limit) || limit < 1) limit = defaultLimit;
  limit = Math.min(Math.floor(limit), maxLimit);

  const offset = (page - 1) * limit;
  return { page, limit, offset };
}

module.exports = { parsePaging };
